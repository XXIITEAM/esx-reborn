-- Copyright (c) Jérémie N'gadi
--
-- All rights reserved.
--
-- Even if 'All rights reserved' is very clear :
--
--   You shall not use any piece of this software in a commercial product / service
--   You shall not resell this software
--   You shall not provide any facility to install this particular software in a commercial product / service
--   If you redistribute this software, you must link to ORIGINAL repository at https://github.com/esx-framework/esx-reborn
--   This copyright should appear in every part of the project code

------------------------------------------------------------------------
----------                                                    ----------
--                              IMPORTS                               --
----------                                                    ----------
------------------------------------------------------------------------

M('events')
local Interact = M('interact')
local utils    = M("utils")
local camera   = M("camera")

------------------------------------------------------------------------
----------                                                    ----------
--                              VARIABLES                             --
----------                                                    ----------
------------------------------------------------------------------------

module.Config  = run('data/config.lua', {vector3 = vector3})['Config']

module.Frame = Frame('garages', 'https://cfx-nui-' .. __RESOURCE__ .. '/modules/__base__/garages/data/html/index.html', true)

module.Frame:on('load', function()
  module.Ready = true
end)

module.Ready                 = false
module.CharacterLoaded       = false
module.Mouse                 = {down = {}, pos = {x = -1, y = -1}}
module.IsInGarageMenu        = false
module.InMarker              = false
module.CurrentDisplayVehicle = nil
module.VehicleLoaded         = false
module.CurrentAction         = nil
module.CurrentActionData     = nil
module.CurrentMenu           = nil
module.CurrentVehicle        = nil
module.CurrentCategory       = nil
module.CurrentValue          = nil
module.CurrentLocation       = nil
module.OwnedVehicles         = {}
module.HasVehicles           = false

------------------------------------------------------------------------
----------                                                    ----------
--                                INIT                                --
----------                                                    ----------
------------------------------------------------------------------------

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
      garage       = v.Garage,
      rotate       = true,
      bobUpAndDown = false,
      faceCamera   = true,
      groundMarker = true
    })

    on('esx:interact:enter:' .. key, function(data)
      if data.name == key then
        module.CurrentActionData = {
          Location = data.location,
          Garage   = data.garage,
          Pos      = data.pos
        }

        Interact.ShowHelpNotification(_U('garages:press_to_retrieve'))

        module.CurrentAction = function()
          module.OpenGarageMenu(module.CurrentActionData)
        end

        if not module.InMarker then
          module.InMarker = true
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
      garage       = v.Garage,
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

            local plate = GetVehicleNumberPlateText(vehicle)
            local formattedPlate = module.FormatPlate(plate)
            Interact.ShowHelpNotification(_U('garages:press_to_store'))

            module.CurrentActionData = {
              Location = data.location,
              Garage   = data.garage,
              Pos      = data.pos,
              Garage   = data.garage,
              Plate    = formattedPlate,
              Vehicle  = vehicle
            }

            module.CurrentAction = function()
              module.StoreVehicle(module.CurrentActionData)
            end

            if not module.InMarker then
              module.InMarker = true
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

------------------------------------------------------------------------
----------                                                    ----------
--                                MENU                                --
----------                                                    ----------
------------------------------------------------------------------------

module.OpenGarageMenu = function(data)
  Interact.StopHelpNotification()

  local ped         = PlayerPedId()

  module.SavedPosition = GetEntityCoords(ped, true)

  request('vehicles:getOwnedVehicles', function(vehicles)
    if vehicles then
      while not module.Ready do
        Wait(100)
      end

      module.OwnedVehicles = {
        ["sedans"]         = {},
        ["compacts"]       = {},
        ["muscle"]         = {},
        ["sports"]         = {},
        ["sportsclassics"] = {},
        ["super"]          = {},
        ["suvs"]           = {},
        ["offroad"]        = {},
        ["motorcycles"]    = {}
      }

      for k,v in pairs(vehicles) do
        if k and v.category then
          local plate = tostring(k)
          local category = tostring(v.category)

          if v.stored == 1 and v.garage == data.Garage then
            if module.OwnedVehicles[category] then
              table.insert(module.OwnedVehicles[category], v)
            end
          end
        end
      end
      

      for k,_ in pairs(module.OwnedVehicles) do
        if #module.OwnedVehicles[k] >= 1 then
          module.HasVehicles = true
        end
      end

      module.Frame:postMessage({
        ["type"]           = "initData",
        ["sedans"]         = tonumber(#module.OwnedVehicles["sedans"]),
        ["compact"]        = tonumber(#module.OwnedVehicles["compacts"]),
        ["muscle"]         = tonumber(#module.OwnedVehicles["muscle"]),
        ["sports"]         = tonumber(#module.OwnedVehicles["sports"]),
        ["sportsclassics"] = tonumber(#module.OwnedVehicles["sportsclassics"]),
        ["super"]          = tonumber(#module.OwnedVehicles["super"]),
        ["suvs"]           = tonumber(#module.OwnedVehicles["suvs"]),
        ["offroad"]        = tonumber(#module.OwnedVehicles["offroad"]),
        ["motorcycles"]    = tonumber(#module.OwnedVehicles["motorcycles"])
      })
    end

    if module.HasVehicles then
      DoScreenFadeOut(500)
  
      while not IsScreenFadedOut() do
        Citizen.Wait(0)
      end
  
      camera.start()
  
      SetEntityCoords(ped, module.Config.GarageSpawns[data.Location].Pos)
      module.CurrentLocation = data.Location
      FreezeEntityPosition(ped, true)
      SetEntityVisible(ped, false)
  
      module.MainCameraScene()
  
      Citizen.Wait(500)
  
      camera.setPolarAzimuthAngle(250.0, 120.0)
      camera.setRadius(3.5)
  
      emit('esx:identity:preventSaving', true)
  
      module.IsInGarageMenu = true
      DoScreenFadeIn(500)
  
      module.Frame:postMessage({
        type = "open"
      })
  
      module.Frame:focus(true, true)
    else
      utils.ui.showNotification(_U('garages:no_vehicles_garage'))
    end
  end)
end

module.Frame:on('message', function(msg)
  if msg.action == 'garages.changesedans' then
    module.ChangeVehicle("sedans", msg.data.value)
  elseif msg.action == "garages.changecompact" then
    module.ChangeVehicle("compacts", msg.data.value)
  elseif msg.action == "garages.changemuscle" then
    module.ChangeVehicle("muscle", msg.data.value)
  elseif msg.action == "garages.changesports" then
    module.ChangeVehicle("sports", msg.data.value)
  elseif msg.action == "garages.changesportsclassics" then
    module.ChangeVehicle("sportsclassics", msg.data.value)
  elseif msg.action == "garages.changesuper" then
    module.ChangeVehicle("super", msg.data.value)
  elseif msg.action == "garages.changesuvs" then
    module.ChangeVehicle("suvs", msg.data.value)
  elseif msg.action == "garages.changeoffroad" then
    module.ChangeVehicle("offroad", msg.data.value)
  elseif msg.action == "garages.changemotorcycles" then
    module.ChangeVehicle("motorcycles", msg.data.value)
  elseif msg.action == "garages.changeTab" then
    module.DeleteDisplayVehicleInsideGarage()
    module.ClearAll()
    module.CurrentCategory = tostring(msg.data.value)
  elseif msg.action == "garages.exit" then
    module.ExitGarage()
  elseif msg.action == "garages.takeVehicle" then
    module.TakeVehicle()
  elseif msg.action == 'mouse.move' then
    module.MouseMove(msg)
  elseif msg.action == 'mouse.wheel' then
    module.MouseWheel(msg)
  elseif msg.action == 'mouse.in' then
    camera.setMouseIn(true)
  elseif msg.action == 'mouse.out' then
    camera.setMouseIn(false)
  end
end)

module.ClearAll = function()
  module.InMarker              = false
  module.IsInGarageMenu        = false
  module.InSellMarker          = false
  module.CurrentAction         = nil
  module.CurrentCategory       = nil
  module.CurrentVehicle        = nil
  module.CurrentValue          = nil
  module.CurrentPlate          = nil
  module.CurrentDisplayVehicle = nil
  module.VehicleLoaded         = false
  module.HasVehicles           = false
end

module.MouseMove = function(msg)
  local last = table.clone(module.Mouse)
  local data = table.clone(last)

  data.pos.x, data.pos.y = msg.data.x, msg.data.y

  if (last.x ~= -1) and (last.y ~= -1) then

    local offsetX = msg.data.x - last.pos.x
    local offsetY = msg.data.y - last.pos.y
    local data = {}
    data.down = {}

    if msg.data.leftMouseDown then
      data.down[0] = true
    else
      data.down[0] = false
    end

    if msg.data.rightMouseDown then
      data.down[2] = true
    else
      data.down[2] = false
    end

    data.direction = {left = offsetX < 0, right = offsetX > 0, up = offsetY < 0, down = offsetY > 0}
    emit('mouse:move:offset', offsetX, offsetY, data)
  end

  module.Mouse = data
end

module.MainCameraScene = function()
  local ped       = PlayerPedId()
  local pedCoords = GetEntityCoords(ped)
  local forward   = GetEntityForwardVector(ped)

  camera.setRadius(2.5)
  camera.setCoords(pedCoords + forward * 1.25)
  camera.setPolarAzimuthAngle(utils.math.world3DtoPolar3D(pedCoords, pedCoords + forward * 1.25))

  camera.pointToBone(SKEL_Head)
end

module.MouseWheel = function(msg)
  emit('mouse:wheel', msg.data)
end

module.ChangeVehicle = function(cat, val)
  if not module.Busy then
    module.Busy = true
    module.DeleteDisplayVehicleInsideGarage()
    module.CurrentDisplayVehicle = nil
    module.CurrentVehicle        = nil
    module.VehicleLoaded         = false

    local category = tostring(cat)
    local value    = tonumber(val)

    if value > 0 then
      for k,v in pairs(module.OwnedVehicles[category]) do
        if tostring(k) == tostring(value) then
          module.CurrentVehicle = v
        end
      end

      if module.CurrentVehicle then
        local ped          = PlayerPedId()
        local name         = tostring(module.CurrentVehicle["name"])
        local make         = module.CurrentVehicle["make"]
        local plate        = module.CurrentVehicle["plate"]
        local fuelType     = module.CurrentVehicle["fuelType"]
        local vehicleProps = module.CurrentVehicle["vehicle"]

        if not make then
          make = "unknown"
        end

        module.CurrentCategory = category
        module.CurrentValue    = value

        utils.game.requestModel(module.CurrentVehicle["model"], function()
          RequestCollisionAtCoord(module.Config.GarageSpawns[module.CurrentLocation].Pos)
        end)

        utils.game.waitForVehicleToLoad(module.CurrentVehicle["model"])

        utils.game.createLocalVehicle(module.CurrentVehicle["model"], module.Config.GarageSpawns[module.CurrentLocation].Pos, module.Config.GarageSpawns[module.CurrentLocation].Heading, function(vehicle)
          module.CurrentDisplayVehicle = vehicle

          while not DoesEntityExist(vehicle) do
            Wait(100)
          end

          local mod               = GetEntityModel(vehicle, false)
          local hash              = GetHashKey(mod)
          local topSpeed          = GetVehicleMaxSpeed(vehicle) * 3.6
          local acceleration      = GetVehicleModelAcceleration(mod)
          local gears             = GetVehicleHighGear(vehicle)
          local capacity          = GetVehicleMaxNumberOfPassengers(vehicle) + 1
          local topSpeedStat      = (((topSpeed / module.Config.FastestVehicleSpeed) * 100))
          local accelerationStat  = (((acceleration / module.Config.FastestVehicleAccel) * 100))
          local gearsStat         = ((gears / module.Config.MaxGears) * 100)
          local capacityStat      = ((capacity / module.Config.MaxCapacity) * 100)
          local topSpeedLabel     = math.floor(topSpeed)
          local accelerationLabel = string.format("%.2f", acceleration)

          module.Frame:postMessage({ 
            type = "selectVehicle",
            data = { make = make, model = model, name = name, plate = plate, fuelType = fuelType },
            stats = { topSpeed = topSpeedStat, acceleration = accelerationStat, gears = gearsStat, capacity = capacityStat},
            labels = {
              topSpeedLabel     = topSpeedLabel,
              accelerationLabel = accelerationLabel,
              gearsLabel        = gears,
              capacityLabel     = capacity
            }
          })

          utils.game.setVehicleProperties(vehicle, vehicleProps)

          SetVehicleDirtLevel(vehicle, 0.0)
          TaskWarpPedIntoVehicle(ped, vehicle, -1)
          FreezeEntityPosition(vehicle, true)
          SetModelAsNoLongerNeeded(module.CurrentVehicle["model"])
          module.VehicleLoaded = true
        end)
      end
    else
      module.Frame:postMessage({ type = "removeVehicle" })
    end
  end

  module.Busy = false
end

module.StoreVehicle = function(data)
  local plate = module.FormatPlate(data.Plate)

  request('vehicles:storeVehicleInGarage', function(result)
    if result then
      DoScreenFadeOut(250)

      while not IsScreenFadedOut() do
        Citizen.Wait(0)
      end
      
      local vehicleProps = utils.game.getVehicleProperties(data.Vehicle)
      emitServer('vehicles:updateVehicleProps', plate, vehicleProps)
      utils.ui.showNotification(_U('garages:store_success'))
      module.DeleteVehicle(data.Vehicle)

      
      Citizen.Wait(500)
      DoScreenFadeIn(250)
      module.ClearAll()
    end
  end, plate, data.Garage)
end

module.FormatPlate = function(plate)
  local currentPlate = plate
  local firstChar = string.sub(currentPlate, 1, 1)

  if firstChar == " " then
    currentPlate = string.sub(currentPlate, 2)
  end

  local lastChar = string.sub(currentPlate, #currentPlate)

  if lastChar == " " then
    currentPlate = string.sub(currentPlate, 1, #currentPlate - 1)
  end

  return currentPlate
end

module.DeleteDisplayVehicleInsideGarage = function()
  if module.CurrentDisplayVehicle and DoesEntityExist(module.CurrentDisplayVehicle) then
    local attempt = 0

    while DoesEntityExist(module.CurrentDisplayVehicle) and not NetworkHasControlOfEntity(module.CurrentDisplayVehicle) and attempt < 100 do
      Wait(100)
      NetworkRequestControlOfEntity(module.CurrentDisplayVehicle)
      attempt = attempt + 1
    end

    if DoesEntityExist(module.CurrentDisplayVehicle) and NetworkHasControlOfEntity(module.CurrentDisplayVehicle) then
      module.DeleteVehicle(module.CurrentDisplayVehicle)
      module.VehicleLoaded = false
    end
  end
end

module.DeleteVehicle = function(vehicle)
  SetEntityAsMissionEntity(vehicle, false, true)
  DeleteVehicle(vehicle)
end

module.ExitGarage = function()
  module.Frame:postMessage({ type = "close" })

  local ped = PlayerPedId()
  module.DeleteDisplayVehicleInsideGarage()
  module.ClearAll()

  DoScreenFadeOut(500)

  while not IsScreenFadedOut() do
    Citizen.Wait(0)
  end

  if module.SavedPosition then
    SetEntityCoords(ped, module.SavedPosition)
  else
    SetEntityCoords(ped, module.Config.GarageEntrances[module.CurrentLocation].Pos)
  end

  SetEntityVisible(ped, true)

  camera.destroy()

  emit('esx:identity:preventSaving', false)

  module.IsInGarageMenu = false
  emitServer('garages:exitedMenu')

  FreezeEntityPosition(ped, false)

  Citizen.Wait(1000)
  module.SavedPosition = nil
  module.Frame:unfocus()
  DoScreenFadeIn(500)
  Interact.ShowHelpNotification(_U('garages:press_to_retrieve'))
end

module.TakeVehicle = function()
  local plate = module.FormatPlate(module.CurrentVehicle["plate"])

  request('vehicles:removeVehicleFromGarage', function(result)
    if result then
      DoScreenFadeOut(500)

      while not IsScreenFadedOut() do
        Citizen.Wait(0)
      end

      request('utils:spawnVehicle', function(result)
        if result then
          module.ExitGarageAndEnterVehicle(result)
        end
      end, module.CurrentVehicle["model"], module.Config.GarageSpawns[module.CurrentLocation].Pos, module.Config.GarageSpawns[module.CurrentLocation].Heading)
    else
      utils.ui.showNotification("Error")
    end
  end, plate)
end

module.ExitGarageAndEnterVehicle = function(result)
  module.DeleteDisplayVehicleInsideGarage()
  module.Frame:postMessage({ type = "close" })
  module.Frame:unfocus()

  camera.destroy()

  utils.game.requestModel(module.CurrentVehicle["model"], function()
    RequestCollisionAtCoord(module.Config.GarageSpawns[module.CurrentLocation].Pos)
  end)

  utils.game.waitForVehicleToLoad(module.CurrentVehicle["model"])

  local count = 0

  while not NetworkDoesEntityExistWithNetworkId(result) and count < 1000 do
    count = count + 1
    Wait(10)
  end

  local vehicle = NetToVeh(result)

  while not DoesEntityExist(vehicle) do
    Wait(100)
    local vehicle = NetToVeh(result)
  end

  local ped = PlayerPedId()

  FreezeEntityPosition(ped, false)
  SetEntityVisible(ped, true)

  if DoesEntityExist(vehicle) then
    local vehicleProps = module.CurrentVehicle["vehicle"]

    utils.game.setVehicleProperties(vehicle, vehicleProps)
    SetVehicleDirtLevel(vehicle, 0.0)

    while not IsPedInVehicle(ped, vehicle, false) do
      TaskWarpPedIntoVehicle(ped, vehicle, -1)
      Wait(10)
    end

    SetNetworkIdCanMigrate(result, true)
    SetEntityAsMissionEntity(vehicle, true, false)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetPedCanBeKnockedOffVehicle(ped, 0)
    SetPedCanRagdoll(ped, true)
    SetEntityVisible(ped, true)

    Wait(500)

    DoScreenFadeIn(500)

    utils.ui.showNotification(_U('garages:retrieve_success'))

    while not IsScreenFadedIn() do
      Wait(0)
    end

    module.ClearAll()
  end

  emit('esx:identity:preventSaving', false)

  module.IsInGarageMenu = false
  emitServer('garages:exitedMenu')
end

module.Exit = function()
  module.ClearAll()
  Interact.StopHelpNotification()
end
