-- Copyright (c) Jérémie N'gadi
--
-- All rights reserved.
--
-- Even if 'All rights reserved' is very clear :
--
--   You shall not use any piece of this software in a commercial product / service
--   You shall not resell this software
--   You shall not provide any facility to install this particular software in a commercial product / service
--   If you redistribute this software, you must link to ORIGINAL repository at https://github.com/ESX-Org/esx-reborn
--   This copyright should appear in every part of the project code

M('events')
M('serializable')
M('cache')
M('ui.menu')

local Interact = M('interact')
local utils    = M("utils")
local camera   = M("camera")

module.Config  = run('data/config.lua', {vector3 = vector3})['Config']

module.isInGarageMenu    = false
module.inMarker          = false
module.CurrentAction     = nil
module.CurrentActionData = nil
module.spawnedVehicle    = nil
module.savedPosition     = nil
module.vehicleLoaded     = false

-----------------------------------------------------------------------------------
-- INIT
-----------------------------------------------------------------------------------

module.Init = function()
  local translations = run('data/locales/' .. Config.Locale .. '.lua')['Translations']
  LoadLocale('garages', Config.Locale, translations)

  Citizen.CreateThread(function()
    for k,v in pairs(module.Config.GarageEntrances) do
      local blip = AddBlipForCoord(v.Pos.x, v.Pos.y, v.Pos.z)

      SetBlipSprite (blip, 357)
      SetBlipDisplay(blip, 4)
      SetBlipScale  (blip, 0.75)
      SetBlipColour (blip, 3)
      SetBlipAsShortRange(blip, true)

      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString("Garage")
      EndTextCommandSetBlipName(blip)
    end
  end)

  request("garages:storeAllVehicles", function(result)
    if result then
      print(_U('garages:returned_vehicles_to_garages_client'))
    end
  end)

  for k, v in pairs(module.Config.GarageEntrances) do

    local key = 'garages:entrance:' .. tostring(k)

    Interact.Register({
      name         = key,
      location     = tostring(k),
      type         = 'marker',
      distance     = module.Config.DrawDistance,
      radius       = 2.0,
      pos          = v.Pos,
      size         = v.Size,
      mtype        = v.Type,
      color        = v.Color,
      rotate       = true,
      bobUpAndDown = false,
      faceCamera   = true,
      groundMarker = true
    })

    on('esx:interact:enter:' .. key, function(data)
      if data.name == key then
        module.CurrentActionData = {
          Location = data.location,
          Pos      = module.Config.GarageEntrances[data.location].Pos
        }

        Interact.ShowHelpNotification(_U('garages:press_to_retrieve'))

        module.CurrentAction = function()
          module.OpenGarageMenu(module.CurrentActionData)
        end

        if not module.inMarker then
          module.inMarker = true
        end
      end
    end)

    on('esx:interact:exit:' .. key, function(data)
      module.Exit()
    end)
  end

  for k, v in pairs(module.Config.GarageReturns) do

    local key = 'garages:return:' .. tostring(k)

    Interact.Register({
      name         = key,
      location     = tostring(k),
      type         = 'marker',
      distance     = module.Config.DrawDistance,
      radius       = 2.0,
      pos          = v.Pos,
      size         = v.Size,
      mtype        = v.Type,
      color        = v.Color,
      rotate       = true,
      bobUpAndDown = false,
      faceCamera   = true,
      groundMarker = true
    })

    on('esx:interact:enter:' .. key, function(data)
      if data.name == key then
        local ped = PlayerPedId()

        if IsPedSittingInAnyVehicle(ped) then
          local vehicle = GetVehiclePedIsIn(ped, false)

          if GetPedInVehicleSeat(vehicle, -1) == ped then

            Interact.ShowHelpNotification(_U('garages:press_to_store'))

            module.CurrentActionData = {
              Location = data.location,
              Pos      = module.Config.GarageReturns[data.location].Pos
            }

            module.CurrentAction = function()
              module.StoreVehicle(module.CurrentActionData)
            end

            if not module.inMarker then
              module.inMarker = true
            end
          end
        else
          Interact.ShowHelpNotification(_U('garages:must_be_in_vehicle'))
        end
      end
    end)

    on('esx:interact:exit:' .. key, function(data)
      module.Exit()
    end)
  end
end

-----------------------------------------------------------------------------------
-- MENU FUNCTIONS
-----------------------------------------------------------------------------------

module.OpenGarageMenu = function(data)
  local items = {}

  request('garages:getOwnedVehicles', function(vehicles)
    if vehicles then

      module.savedPosition = data.Pos

      DoScreenFadeOut(250)

      while not IsScreenFadedOut() do
        Citizen.Wait(0)
      end

      module.StartGarageRestriction()
      module.EnterGarage(data)

      module.isInGarageMenu = true

      for _,value in pairs(vehicles) do
        if value.stored == 1 and value.plate and value.sold == 0 then

          local name = GetDisplayNameFromVehicleModel(value.model)

          local vehicleData = {
            vehicleProps = value.vehicle,
            name         = name,
            model        = value.model,
            plate        = value.plate
          }

          if name == "CARNOTFOUND" then
            items[#items + 1] = {type = 'button', name = 'model_error', label = '[' .. _U('garages:model_error_label') .. ']', value = "CARNOTFOUND"}
          else
            items[#items + 1] = {type = 'button', name = name, label = name .. ' [' .. value.plate .. ']', value = {vehicleProps = value.vehicle, name = name, model = value.model, plate = value.plate}}
          end
        elseif value.stored == 0 then
          local name = GetDisplayNameFromVehicleModel(value.vehicle.model)
          local plate = utils.math.Trim(value.plate)

          local vehicleData = {
            name  = name,
            plate = plate
          }

          items[#items + 1] = {type = 'button', name = 'not_in_garage', label = name .. ' - [' .. _U('garages:not_in_garage_label') .. ']', value = vehicleData}
        end
      end

      items[#items + 1] = {name = 'exit', label = '>> ' .. _U('exit') .. ' <<', type = 'button'}
    else
      utils.ui.showNotification(_U('garages:no_vehicles'))
      return
    end

    module.garageMenu = Menu('garages.garage', {
      title = _U('garages:menu_title'),
      float = 'top|left', -- not needed, default value
      items = items
    })

    module.currentMenu = module.garageMenu

    module.garageMenu:on('item.click', function(item, index)
      if item.name == 'exit' then
        module.ExitGarage()
      elseif item.name == 'not_in_garage' then
        utils.ui.showNotification(_U('garages:not_in_garage', item.value.name, item.value.plate))
      elseif item.name == "model_error" then
        utils.ui.showNotification(_U('garages:model_error'))
      else
        if item.value.plate then
          module.commit(item.value.plate, item.value.model, item.value.vehicleProps, item.value.name, data)
        else
          utils.ui.showNotification(_U('garages:plate_error'))
        end
      end
    end)
  end)
end

module.OpenRetrievalMenu = function(plate, model, vehicleProps, name, data)
  local items = {}

  items[#items + 1] = {name = 'yes', label = '>> ' .. _U('yes') .. ' <<', type = 'button'}
  items[#items + 1] = {name = 'no', label = '>> ' .. _U('no') .. ' <<', type = 'button'}

  if module.garageMenu.visible then
    module.garageMenu:hide()
  end

  module.retrievalMenu = Menu('garages.retrieval', {
    title = _U('garages:retrieve_confirm', name),
    float = 'top|left', -- not needed, default value
    items = items
  })

  module.currentMenu = module.retrievalMenu

  module.retrievalMenu:on('destroy', function()
    module.garageMenu:show()
  end)

  module.retrievalMenu:on('item.click', function(item, index)
    if item.name == 'no' then
      module.DeleteDisplayVehicleInsideGarage()
      module.currentDisplayVehicle = nil

      module.retrievalMenu:destroy()

      module.currentMenu = module.garageMenu

      module.garageMenu:focus()
    elseif item.name == 'yes' then
      request("garages:removeVehicleFromGarage", function(success)
        if success then
          module.ExitGarageWithSelectedVehicle()

          while not IsScreenFadedOut() do
            Citizen.Wait(0)
          end

          FreezeEntityPosition(PlayerPedId(), false)

          SetEntityCoords(PlayerPedId(), module.Config.GarageSpawns[data.Location].Pos)

          Citizen.Wait(100)

          utils.game.createVehicle(model, module.Config.GarageSpawns[data.Location].Pos, module.Config.GarageSpawns[data.Location].Heading, function(vehicle)
            local ped = PlayerPedId()
            TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)

            utils.game.setVehicleProperties(vehicle, vehicleProps)
            SetVehicleNumberPlateText(vehicle, plate)
          end)

          Citizen.Wait(1000)
          SetEntityVisible(PlayerPedId(), true)
          DoScreenFadeIn(500)
          utils.ui.showNotification(_U('garages:retrieve_success'))
        else
          module.ExitGarage()

          utils.ui.showNotification(_U('garages:retrieve_failure'))
        end
      end, plate)
    end
  end)
end

-----------------------------------------------------------------------------------
-- LOGIC FUNCTIONS
-----------------------------------------------------------------------------------

module.EnterGarage = function(data)
  camera.start()
  module.mainCameraScene()
  camera.setPolarAzimuthAngle(250.0, 120.0)
  camera.setRadius(3.5)

  Citizen.CreateThread(function()
    local ped = PlayerPedId()
    --SetEntityCoords(ped, module.Config.GarageMenuLocation)
    SetEntityCoords(ped, module.Config.GarageSpawns[data.Location].Pos)
    FreezeEntityPosition(ped, true)
    SetEntityVisible(ped, false)
  end)

  Citizen.Wait(500)

  camera.setPolarAzimuthAngle(220.0, 120.0)
  camera.setRadius(3.5)
  emit('esx:identity:preventSaving', true)
  DoScreenFadeIn(250)
end

module.ExitGarage = function()
  DoScreenFadeOut(100)

  if module.retrievalMenu then
    module.retrievalMenu:destroy()
  end

  if module.garageMenu then
    module.garageMenu:destroy()
  end

  while not IsScreenFadedOut() do
    Citizen.Wait(0)
  end

  FreezeEntityPosition(PlayerPedId(), false)
  SetEntityVisible(PlayerPedId(), true)

  module.ReturnPlayer(module.savedPosition)
  camera.destroy()

  emit('esx:identity:preventSaving', false)

  module.isInGarageMenu = false

  Citizen.Wait(250)
  DoScreenFadeIn(500)
end

module.ExitGarageWithSelectedVehicle = function()

  DoScreenFadeOut(100)

  if module.retrievalMenu then
    module.retrievalMenu:destroy()
  end

  if module.garageMenu then
    module.garageMenu:destroy()
  end

  while not IsScreenFadedOut() do
    Citizen.Wait(0)
  end

  if module.currentDisplayVehicle then
    module.DeleteDisplayVehicleInsideGarage()
    module.currentDisplayVehicle = nil
    module.vehicleLoaded = false
  end

  camera.destroy()

  emit('esx:identity:preventSaving', false)
  module.isInGarageMenu = false
  module.Exit()
end

module.StartGarageRestriction = function()
  Citizen.CreateThread(function()
    while module.isInGarageMenu do
      Citizen.Wait(0)

      DisableControlAction(0, 75,  true)
      DisableControlAction(27, 75, true)
    end
  end)
end

module.showVehicleStats = function()
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(0)
      if module.vehicleLoaded then
        local playerPed = PlayerPedId()

        if IsPedSittingInAnyVehicle(playerPed) then
          local vehicle = GetVehiclePedIsIn(playerPed, false)

          if DoesEntityExist(vehicle) then
            local model            = GetEntityModel(vehicle, false)
            local hash             = GetHashKey(model)

            local topSpeed         = GetVehicleMaxSpeed(vehicle) * 3.6
            local acceleration     = GetVehicleModelAcceleration(model)
            local gears            = GetVehicleHighGear(vehicle)
            local capacity         = GetVehicleMaxNumberOfPassengers(vehicle) + 1

            local topSpeedStat     = (((topSpeed / module.Config.fastestVehicleSpeed) / 2) * module.Config.statSizeX)
            local accelerationStat = (((acceleration / 1.6) / 2) * module.Config.statSizeX)
            local gearStat         = tostring(gears)
            local capacityStat     = tostring(capacity)

            if topSpeedStat > 0.24 then
              topSpeedStat = 0.24
            end

            if accelerationStat > 0.24 then
              accelerationStat = 0.24
            end

            utils.ui.drawVehicleStats(module.Config.xoffset, module.Config.yoffset, module.Config.windowSizeX, module.Config.windowSizeY, module.Config.statOffsetX, module.Config.statSizeX, module.Config.statSizeY, topSpeedStat, accelerationStat, gearStat, capacityStat)
          end
        end
      else
        break
      end
    end
  end)
end

module.SetMouseIn = function(value)
  camera.setMouseIn(value)
end

module.commit = function(plate, model, vehicleProps, name, data)

  local playerPed = PlayerPedId()

  module.DeleteDisplayVehicleInsideGarage()

  utils.game.waitForVehicleToLoad(model)

  utils.game.createLocalVehicle(model, module.Config.GarageSpawns[data.Location].Pos, module.Config.GarageSpawns[data.Location].Heading, function(vehicle)
    module.currentDisplayVehicle = vehicle

    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)

    utils.game.setVehicleProperties(vehicle, vehicleProps)

    FreezeEntityPosition(vehicle, true)

    local model = GetEntityModel(vehicle)

    SetModelAsNoLongerNeeded(model)

    module.OpenRetrievalMenu(plate, model, vehicleProps, name, data)

    module.vehicleLoaded = true

    if module.Config.EnableVehicleStats then
      module.showVehicleStats()
    end
  end)
end

module.DeleteDisplayVehicleInsideGarage = function()
  local attempt = 0

  if module.currentDisplayVehicle and DoesEntityExist(module.currentDisplayVehicle) then
    while DoesEntityExist(module.currentDisplayVehicle) and not NetworkHasControlOfEntity(module.currentDisplayVehicle) and attempt < 100 do
      Citizen.Wait(100)
      NetworkRequestControlOfEntity(module.currentDisplayVehicle)
      attempt = attempt + 1
    end

    if DoesEntityExist(module.currentDisplayVehicle) and NetworkHasControlOfEntity(module.currentDisplayVehicle) then
      utils.game.deleteVehicle(module.currentDisplayVehicle)
      module.currentDisplayVehicle = nil
      module.vehicleLoaded = false
    end
  end
end

module.ReturnPlayer = function(pos)
  local ped = PlayerPedId()
  SetEntityCoords(ped, pos)

  Citizen.Wait(500)
  DoScreenFadeIn(250)
end

module.Exit = function()
  module.CurrentAction     = nil
  module.CurrentActionData = nil
  module.inMarker          = false

  Interact.StopHelpNotification()
end

module.StoreVehicle = function()
  local playerPed = PlayerPedId()

  if IsPedSittingInAnyVehicle(playerPed) then
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if DoesEntityExist(vehicle) then
      local plate        = utils.math.Trim(GetVehicleNumberPlateText(vehicle))
      local vehicleProps = utils.game.getVehicleProperties(vehicle)

      emitServer('garages:updateVehicle', plate, vehicleProps)
      request('garages:storeVehicleInGarage', function(result)
        if result then
          DoScreenFadeOut(250)

          while not IsScreenFadedOut() do
          Citizen.Wait(0)
          end

          utils.game.deleteVehicle(vehicle)

          Citizen.Wait(500)
          utils.ui.showNotification(_U('garages:store_success'))
          DoScreenFadeIn(250)
        else
          utils.ui.showNotification(_U('garages:do_not_own'))
        end
      end, plate)
    end
  end

  module.Exit()
end

-----------------------------------------------------------------------------------
-- CAMERA FUNCTIONS
-----------------------------------------------------------------------------------

function module.mainCameraScene()
  local ped       = PlayerPedId()
  local pedCoords = GetEntityCoords(ped)
  local forward   = GetEntityForwardVector(ped)

  camera.setRadius(1.25)
  camera.setCoords(pedCoords + forward * 1.25)
  camera.setPolarAzimuthAngle(utils.math.world3DtoPolar3D(pedCoords, pedCoords + forward * 1.25))

  camera.pointToBone(SKEL_ROOT)
end
