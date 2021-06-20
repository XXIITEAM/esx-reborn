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

module.Config = run('data/config.lua', {vector3 = vector3})['Config']

module.Frame = Frame('vehicleshop', 'https://cfx-nui-' .. __RESOURCE__ .. '/modules/__base__/vehicleshop/data/html/index.html', true)

module.Frame:on('load', function()
  module.Ready = true
end)

module.Ready                         = false
module.Migrated                      = false
module.CharacterLoaded               = false
module.Mouse                         = {down = {}, pos = {x = -1, y = -1}}

module.InTestDrive                   = false
module.InSellMarker                  = false
module.NumberCharset                 = {}
module.Charset                       = {}

module.CurrentAction                 = nil
module.InMarker                      = false
module.IsInShopMenu                  = false
module.InSellMarker                  = false

module.Vehicles                      = {}
module.DataInitiated                 = false
module.SavedPosition                 = nil
module.InTestDrive                   = false
module.TestDriveTime                 = 0
module.IsDead                        = false

module.CurrentCategory               = nil
module.CurrentValue                  = nil
module.CurrentModel                  = nil
module.CurrentPrice                  = nil
module.CurrentPlate                  = nil
module.CurrentDisplayVehicle         = nil
module.CurrentVehicle                = nil
module.CurrentVehicle                = nil
module.CurrentSelectedPrimaryColor   = {r = 0, g = 0, b = 0}
module.CurrentSelectedSecondaryColor = {r = 0, g = 0, b = 0}
module.VehicleLoaded                 = false

------------------------------------------------------------------------
----------                                                    ----------
--                                INIT                                --
----------                                                    ----------
------------------------------------------------------------------------

module.Init = function()
  local translations = run('data/locales/' .. Config.Locale .. '.lua')['Translations']
  LoadLocale('vehicleshop', Config.Locale, translations)

  Citizen.CreateThread(function()
    local blip = AddBlipForCoord(module.Config.VehicleShopZones.Main.Center)

    SetBlipSprite (blip, 664)
    SetBlipDisplay(blip, 4)
    SetBlipScale  (blip, 0.9)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(_U('vehicleshop:blip_buy_title'))
    EndTextCommandSetBlipName(blip)
    SetBlipColour (blip,2)
  end)

  Citizen.CreateThread(function()
    local blip2 = AddBlipForCoord(module.Config.Zones.ShopSell.Pos)

    SetBlipSprite (blip2, 108)
    SetBlipDisplay(blip2, 4)
    SetBlipScale  (blip2, 0.9)
    SetBlipAsShortRange(blip2, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(_U('vehicleshop:blip_sell_title'))
    EndTextCommandSetBlipName(blip2)
    SetBlipColour (blip2,1)
  end)

  for k, v in pairs(module.Config.Zones) do
    local key = 'vehicleshop:' .. tostring(k)

    Interact.Register({
      name         = key,
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
      if data.name == "vehicleshop:ShopSell" then
        if not module.InTestDrive then
          local ped = PlayerPedId()

          if IsPedSittingInAnyVehicle(ped) then
            local vehicle = GetVehiclePedIsIn(ped, false)

            if GetPedInVehicleSeat(vehicle, -1) == ped then

              Interact.ShowHelpNotification(_U('vehicleshop:press_to_sell'))

              module.CurrentAction = function()
                module.SellVehicle()
              end

              if not module.InMarker then
                module.InSellMarker = true
              end
            end
          else
            Interact.ShowHelpNotification(_U('vehicleshop:must_be_in_vehicle'))
          end
        end
      end
    end)

    on('esx:interact:exit:' .. key, function(data)
      module.Exit()
    end)

    on('vehicleshop:enteredZone', function()
      if not module.InTestDrive then
        local ped = PlayerPedId()
        Interact.ShowHelpNotification(_U('vehicleshop:press_access'))

        module.CurrentAction = function()
          if IsPedSittingInAnyVehicle(ped) then
            utils.ui.showNotification(_U('vehicleshop:already_in_vehicle'))
            return
          end

          request('vehicleshop:isAnyoneInShopMenu', function(result)
            if not result then
              module.OpenShopMenu()
            else
              utils.ui.showNotification(_U('vehicleshop:shop_being_used'))
              return
            end
          end)
        end
      end
    end)

    on('vehicleshop:exitedZone', function()
      module.Exit()
    end)
  end

  Citizen.CreateThread(function()
    local interiorID = 7170

    if not IsIplActive(interiorId) then
      RequestIpl('shr_int')
      LoadInterior(interiorID)
      EnableInteriorProp(interiorID, 'csr_beforeMission')
      RefreshInterior(interiorID)
    end
  end)
end

for i = 48, 57 do
  table.insert(module.NumberCharset, string.char(i))
end

for i = 65, 90 do
  table.insert(module.Charset, string.char(i))
end

for i = 97, 122 do
  table.insert(module.Charset, string.char(i))
end

------------------------------------------------------------------------
----------                                                    ----------
--                                MENU                                --
----------                                                    ----------
------------------------------------------------------------------------

module.OpenShopMenu = function()
  Interact.StopHelpNotification()

  local ped = PlayerPedId()
  
  module.SavedPosition = GetEntityCoords(ped, true)

  if not module.DataInitiated then
    module.Vehicles = {}

    request("vehicles:getVehicles", function(data)
      if data then
        module.Vehicles = data
  
        while not module.Ready do
          Wait(100)
        end
  
        module.Frame:postMessage({
          type           = "initData",
          sedans         = tonumber(#module.Vehicles["sedans"]),
          compact        = tonumber(#module.Vehicles["compacts"]),
          muscle         = tonumber(#module.Vehicles["muscle"]),
          sports         = tonumber(#module.Vehicles["sports"]),
          sportsclassics = tonumber(#module.Vehicles["sportsclassics"]),
          super          = tonumber(#module.Vehicles["super"]),
          suvs           = tonumber(#module.Vehicles["suvs"]),
          offroad        = tonumber(#module.Vehicles["offroad"]),
          motorcycles    = tonumber(#module.Vehicles["motorcycles"])
        })
  
        module.DataInitiated = true
      end
    end)
  end

  DoScreenFadeOut(500)

  while not IsScreenFadedOut() do
    Citizen.Wait(0)
  end

  camera.start()

  FreezeEntityPosition(ped, true)
  SetEntityVisible(ped, false)
  SetEntityCoords(ped, module.Config.ShopInside.Pos)

  module.MainCameraScene()

  Citizen.Wait(500)

  camera.setPolarAzimuthAngle(250.0, 120.0)
  camera.setRadius(3.5)
  emit('esx:identity:preventSaving', true)
  module.IsInShopMenu = true
  DoScreenFadeIn(500)
  module.Frame:postMessage({ type = "open" })
  module.Frame:focus(true, true)
end

module.ExitShop = function()
  local ped = PlayerPedId()

  module.DeleteDisplayVehicleInsideShop()
  module.CurrentCategory               = nil
  module.CurrentValue                  = nil
  module.CurrentModel                  = nil
  module.CurrentPrice                  = nil
  module.CurrentPlate                  = nil
  module.CurrentDisplayVehicle         = nil
  module.CurrentVehicle                = nil
  module.CurrentSelectedPrimaryColor   = {r = 0, g = 0, b = 0}
  module.CurrentSelectedSecondaryColor = {r = 0, g = 0, b = 0}
  module.VehicleLoaded                 = false

  module.Frame:postMessage({ type = "close" })
  DoScreenFadeOut(500)

  while not IsScreenFadedOut() do
    Citizen.Wait(0)
  end

  if module.SavedPosition then
    SetEntityCoords(ped, module.SavedPosition)
  else
    SetEntityCoords(ped, module.Config.VehicleShopZones.Main.Center)
  end

  SetEntityVisible(ped, true)

  camera.destroy()

  emit('esx:identity:preventSaving', false)

  module.IsInShopMenu = false
  emitServer('vehicleshop:exitedMenu')

  FreezeEntityPosition(ped, false)

  Citizen.Wait(1000)
  DoScreenFadeIn(500)

  module.SavedPosition = nil
  module.Frame:unfocus()
  Interact.ShowHelpNotification(_U('vehicleshop:press_access'))
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

module.Frame:on('message', function(msg)
  if msg.action == 'vehshop.buy' then
    module.BuyVehicle()
  elseif msg.action =="vehshop.exit" then
    module.ExitShop()
  elseif msg.action =="vehshop.changeTab" then
    module.DeleteDisplayVehicleInsideShop()
    module.CurrentCategory               = tostring(msg.data.value)
    module.CurrentVehicle                = nil
    module.CurrentDisplayVehicle         = nil
    module.CurrentSelectedPrimaryColor   = {r = 0, b = 0, g = 0}
    module.CurrentSelectedSecondaryColor = {r = 0, g = 0, b = 0}
    module.VehicleLoaded                 = false
  elseif msg.action == "vehshop.testdrive" then
    module.PrepareTestDrive(module.CurrentModel)
  elseif msg.action == "vehshop.changeColors" then
    module.ChangeColors(msg.data.category, msg.data.r, msg.data.g, msg.data.b)
  elseif msg.action == 'vehshop.changeSedan' then
    module.ChangeVehicle("sedans", msg.data.value)
  elseif msg.action == "vehshop.changeCompact" then
    module.ChangeVehicle("compacts", msg.data.value)
  elseif msg.action == "vehshop.changeMuscle" then
    module.ChangeVehicle("muscle", msg.data.value)
  elseif msg.action == "vehshop.changeSports" then
    module.ChangeVehicle("sports", msg.data.value)
  elseif msg.action == "vehshop.changeSportsClassics" then
    module.ChangeVehicle("sportsclassics", msg.data.value)
  elseif msg.action == "vehshop.changeSuper" then
    module.ChangeVehicle("super", msg.data.value)
  elseif msg.action == "vehshop.changeSUVS" then
    module.ChangeVehicle("suvs", msg.data.value)
  elseif msg.action == "vehshop.changeOffroad" then
    module.ChangeVehicle("offroad", msg.data.value)
  elseif msg.action == "vehshop.changeMotorcycles" then
    module.ChangeVehicle("motorcycles", msg.data.value)
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

module.MouseWheel = function(msg)
  emit('mouse:wheel', msg.data)
end


------------------------------------------------------------------------
----------                                                    ----------
--                            FUNCTIONS                               --
----------                                                    ----------
------------------------------------------------------------------------

module.SellVehicle = function()
  local ped = PlayerPedId()

  if IsPedSittingInAnyVehicle(ped) then
    local vehicle = GetVehiclePedIsIn(ped, false)

    if GetPedInVehicleSeat(vehicle, -1) == ped then
      local plate = module.Trim(GetVehicleNumberPlateText(vehicle))
      local model = GetEntityModel(vehicle)
      local displaytext = GetDisplayNameFromVehicleModel(model)
      local name = GetLabelText(displaytext)

      request("vehicles:sellVehicle", function(result)
        if result then
            DoScreenFadeOut(250)

            while not IsScreenFadedOut() do
              Citizen.Wait(0)
            end
            
            utils.ui.showNotification(_U('vehicleshop:sell_success', name, result.plate, result.resellPrice))
            module.DeleteVehicle(vehicle)

            Citizen.Wait(500)
            DoScreenFadeIn(250)
        else
          utils.ui.showNotification(_U('vehicleshop:sell_unowned'))
        end
      end, plate)
    end
  end
end

module.BuyVehicle = function()
  local generatedPlate = module.GeneratePlate()
  local displaytext = GetDisplayNameFromVehicleModel(module.CurrentModel)
  local name = GetLabelText(displaytext)
  local ped = PlayerPedId()

  if not generatedPlate then
    print(_U('vehicleshop:generate_failure'))
  else
    utils.game.requestModel(module.CurrentModel, function()

      RequestCollisionAtCoord(module.Config.ShopOutside.Pos)
    
    end)

    utils.game.waitForVehicleToLoad(module.CurrentModel)

    request('vehicles:buyVehicle', function(result)
      if result then
        module.CurrentPlate = result.plate
        utils.ui.showNotification(_U('vehicleshop:buy_success', result.name, result.plate, result.price))
        request('utils:spawnVehicle', function(result)
          if result then
            module.ExitShopAndEnterVehicle(result)
          end
        end, module.CurrentModel, module.Config.ShopOutside.Pos, module.Config.ShopOutside.Heading)
      else
        utils.ui.showNotification("Error")
      end
    end, module.CurrentCategory, module.CurrentValue, generatedPlate, name, module.CurrentVehicle)
  end
end

module.ExitShopAndEnterVehicle = function(result)
  module.DeleteDisplayVehicleInsideShop()
  module.Frame:postMessage({ type = "close" })
  module.Frame:unfocus()
  camera.destroy()

  DoScreenFadeOut(500)

  utils.game.requestModel(module.CurrentModel, function()
    RequestCollisionAtCoord(module.Config.ShopOutside.Pos)
  end)

  utils.game.waitForVehicleToLoad(module.CurrentModel)

  while not IsScreenFadedOut() do
    Wait(0)
  end

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
    SetVehicleCustomPrimaryColour(vehicle, module.CurrentSelectedPrimaryColor.r, module.CurrentSelectedPrimaryColor.g, module.CurrentSelectedPrimaryColor.b)   
    SetVehicleCustomSecondaryColour(vehicle, module.CurrentSelectedSecondaryColor.r, module.CurrentSelectedSecondaryColor.g, module.CurrentSelectedSecondaryColor.b)
    SetVehicleDirtLevel(vehicle, 0.0)

    while not IsPedInVehicle(ped, vehicle, false) do
      TaskWarpPedIntoVehicle(ped, vehicle, -1)
      Wait(10)
    end

    SetNetworkIdCanMigrate(result, true)
    SetEntityAsMissionEntity(vehicle, true, false)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetVehicleNumberPlateText(vehicle, module.CurrentPlate)
    SetPedCanBeKnockedOffVehicle(ped, 0)
    SetPedCanRagdoll(ped, true)
    SetEntityVisible(ped, true)

    local vehicleProps = utils.game.getVehicleProperties(vehicle)
    
    emitServer('vehicles:updateVehicleProps', module.CurrentPlate, vehicleProps)

    Wait(500)

    DoScreenFadeIn(500)

    while not IsScreenFadedIn() do
      Wait(0)
    end

    module.InMarker                      = false
    module.IsInShopMenu                  = false
    module.InSellMarker                  = false
    module.CurrentAction                 = nil
    module.CurrentCategory               = nil
    module.CurrentValue                  = nil
    module.CurrentModel                  = nil
    module.CurrentPrice                  = nil
    module.CurrentPlate                  = nil
    module.CurrentDisplayVehicle         = nil
    module.CurrentVehicle                = nil

    emit('esx:identity:preventSaving', false)
    module.IsInShopMenu = false
    emitServer('vehicleshop:exitedMenu')
  end
end

module.PrepareTestDrive = function(model)
  module.IsDead = false

  local ped = PlayerPedId()

  module.TestDriveTime = tonumber(module.Config.TestDriveTime)

  PlaySoundFrontend(-1, "Player_Enter_Line", "GTAO_FM_Cross_The_Line_Soundset", 0)

  utils.game.requestModel(model, function()

    RequestCollisionAtCoord(module.Config.ShopOutside.Pos)
  
  end)

  utils.game.waitForVehicleToLoad(model)

  request('utils:spawnVehicle', function(result)
    if result then
      module.StartTestDrive(result)
    end
  end, model, module.Config.ShopOutside.Pos, module.Config.ShopOutside.Heading)
end

module.StartTestDrive = function(result)
  module.DeleteDisplayVehicleInsideShop()
  module.Frame:postMessage({ type = "close" })
  module.Frame:unfocus()
  camera.destroy()

  DoScreenFadeOut(500)

  while not IsScreenFadedOut() do
    Wait(0)
  end

  local count = 0

  while not NetworkDoesEntityExistWithNetworkId(result) and count < 100 do
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
    SetVehicleCustomPrimaryColour(vehicle, module.CurrentSelectedPrimaryColor.r, module.CurrentSelectedPrimaryColor.g, module.CurrentSelectedPrimaryColor.b)   
    SetVehicleCustomSecondaryColour(vehicle, module.CurrentSelectedSecondaryColor.r, module.CurrentSelectedSecondaryColor.g, module.CurrentSelectedSecondaryColor.b)
    SetVehicleDirtLevel(vehicle, 0.0)

    while not IsPedInVehicle(ped, vehicle, false) do
      TaskWarpPedIntoVehicle(ped, vehicle, - 1)
      Wait(10)
    end

    SetNetworkIdCanMigrate(result, true)
    SetEntityAsMissionEntity(vehicle, true, false)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetVehicleNumberPlateText(vehicle, "RENTAL")
    SetPedCanBeKnockedOffVehicle(ped,1)
    SetPedCanRagdoll(ped,false)
    SetEntityVisible(ped, true)

    utils.ui.showNotification(_U('vehicleshop:test_drive_started'))

    Wait(500)

    DoScreenFadeIn(500)

    while not IsScreenFadedIn() do
      Wait(0)
    end

    module.IsInShopMenu = false

    module.InTestDrive = true

    while module.InTestDrive do
      Wait(0)
      DisableControlAction(0, 75, true)
      DisableControlAction(27, 75, true)
      DisableControlAction(0, 70, true)
      DisableControlAction(0, 69, true)

      if IsEntityDead(ped) then
        module.IsDead        = true
        module.inTestDrive   = false
        module.TestDriveTime = 0
      else
        local pedCoords = GetEntityCoords(ped)

        module.TestDriveTime = module.TestDriveTime - 0.009
        if math.floor(module.TestDriveTime) >= 60 then
          utils.ui.showHelpNotification(_U('vehicleshop:test_drive_remaining_long', math.floor(module.TestDriveTime)), false, false, 1)
        elseif math.floor(module.TestDriveTime) >= 20 and math.floor(module.TestDriveTime) < 60 then
          utils.ui.showHelpNotification(_U('vehicleshop:test_drive_remaining_med', math.floor(module.TestDriveTime)), false, false, 1)
        elseif math.floor(module.TestDriveTime) < 20 then
          utils.ui.showHelpNotification(_U('vehicleshop:test_drive_remaining_short', math.floor(module.TestDriveTime)), false, false, 1)
        end

        if module.TestDriveTime <= 0 then
          module.InTestDrive = false
        end
      end
    end

    if module.PlayerDied then
      utils.ui.showNotification(_U('vehicleshop:end_test_drive_death'))
    else
      Interact.StopHelpNotification()

      SetPedCanRagdoll(ped,true)
      SetPedCanBeKnockedOffVehicle(ped,0)
      PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 1)

      DoScreenFadeOut(500)

      while not IsScreenFadedOut() do
        Wait(0)
      end

      Wait(500)

      utils.ui.showNotification(_U('vehicleshop:test_drive_ended'))

      SetEntityCoordsNoOffset(vehicle, module.Config.ShopInside.Pos, 0, 0, 1)
      SetEntityHeading(vehicle, module.Config.ShopInside.Heading)
      SetEntityVisible(ped, false)

      Wait(500)

      DoScreenFadeIn(500)

      while not IsScreenFadedIn() do
        Wait(0)
      end

      camera.start()
      module.MainCameraScene()

      module.Frame:postMessage({ type = "open" })
      module.Frame:focus(true, true)

      module.IsInShopMenu = true

      module.CurrentDisplayVehicle = vehicle
      module.VehicleLoaded = true
    end
  end
end

module.ChangeVehicle = function(cat, val)
  if not module.Busy then
    module.Busy = true
    local category = tostring(cat)
    local value = tonumber(val)

    module.DeleteDisplayVehicleInsideShop()
    module.CurrentDisplayVehicle         = nil
    module.CurrentVehicle                = nil
    module.CurrentSelectedPrimaryColor   = {r = 0, g = 0, b = 0}
    module.CurrentSelectedSecondaryColor = {r = 0, g = 0, b = 0}
    module.VehicleLoaded                 = false

    if value > 0 then
      if module.Vehicles[category] then
        if module.Vehicles[category][value] then
          local ped      = PlayerPedId()
          local name     = tostring(module.Vehicles[category][value].name)
          local make     = module.Vehicles[category][value].make
          local price    = tostring(module.Vehicles[category][value].price)
          local model    = tostring(module.Vehicles[category][value].model)
          local fuelType = tostring(module.Vehicles[category][value].fuelType)
          module.CurrentVehicle = module.Vehicles[category][value]

          if not make then
            make = "unknown"
          end

          module.CurrentCategory = category
          module.CurrentValue    = value
          module.CurrentModel    = model
          module.CurrentPrice    = tonumber(price)

          utils.game.requestModel(model, function()
            RequestCollisionAtCoord(module.Config.ShopOutside.Pos)
          end)

          utils.game.waitForVehicleToLoad(model)

          utils.game.createLocalVehicle(model, module.Config.ShopInside.Pos, module.Config.ShopInside.Heading, function(vehicle)

            module.CurrentDisplayVehicle = vehicle

            while not DoesEntityExist(vehicle) do
              Wait(100)
            end

            module.ChangeColors("primary", 0, 0, 0)
            module.ChangeColors("secondary", 0, 0, 0)
            SetVehicleDirtLevel(module.CurrentDisplayVehicle, 0.0)

            TaskWarpPedIntoVehicle(ped, vehicle, -1)
            
            FreezeEntityPosition(vehicle, true)

            SetModelAsNoLongerNeeded(model)

            module.VehicleLoaded = true
          end)

          while not module.VehicleLoaded do
            Wait(100)
          end

          if IsPedSittingInAnyVehicle(ped) then
            local vehicle = GetVehiclePedIsIn(ped, false)

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
              data = { make = make, model = model, name = name, price = price },
              stats = { topSpeed = topSpeedStat, acceleration = accelerationStat, gears = gearsStat, capacity = capacityStat},
              labels = {
                topSpeedLabel     = topSpeedLabel,
                accelerationLabel = accelerationLabel,
                gearsLabel        = gears,
                capacityLabel     = capacity,
                fuelTypeStat      = fuelType
              }
            })
          end
        end
      end
    else
      module.Frame:postMessage({ type = "removeVehicle"})
    end

    module.Busy = false
  end
end

module.ChangeColors = function(category, r, g, b)
  if module.CurrentDisplayVehicle and module.VehicleLoaded then
    if category == "primary" then
      SetVehicleCustomPrimaryColour(module.CurrentDisplayVehicle, r, g, b)
      module.CurrentSelectedPrimaryColor = {r = r, g = g, b = b}      
    else
      SetVehicleCustomSecondaryColour(module.CurrentDisplayVehicle, r, g, b)
      module.CurrentSelectedSecondaryColor = {r = r, g = g, b = b}
    end
  end
end

module.DeleteDisplayVehicleInsideShop = function()
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

module.Exit = function()
  module.InMarker                      = false
  module.IsInShopMenu                  = false
  module.InSellMarker                  = false
  module.CurrentAction                 = nil
  module.CurrentCategory               = nil
  module.CurrentValue                  = nil
  module.CurrentModel                  = nil
  module.CurrentPrice                  = nil
  module.CurrentPlate                  = nil
  module.CurrentDisplayVehicle         = nil
  module.CurrentVehicle                = nil
  module.CurrentSelectedPrimaryColor   = {r = 0, g = 0, b = 0}
  module.CurrentSelectedSecondaryColor = {r = 0, g = 0, b = 0}
  Interact.StopHelpNotification()
end

module.GetRandomNumber = function(length)
  math.randomseed(GetGameTimer())
  if length then
    if length > 0 then
      return module.GetRandomNumber(length - 1) .. module.NumberCharset[math.random(1, #module.NumberCharset)]
    else
      return ''
    end
  else
    return ''
  end
end

module.GetRandomLetter = function(length)
  math.randomseed(GetGameTimer())
  if length then
    if length > 0 then
      return module.GetRandomLetter(length - 1) .. module.Charset[math.random(1, #module.Charset)]
    else
      return ''
    end
  else
    return ''
  end
end

module.GeneratePlate = function()
  local generatedPlate
  local doBreak  = false
  local attempts = 0

  while true do
    Citizen.Wait(20)

    if attempts > 100 then
      generatedPlate = nil
      break
    else
      math.randomseed(GetGameTimer())

      if module.plateUseSpace then
        generatedPlate = string.upper(module.GetRandomLetter(module.Config.PlateLetters) .. ' ' .. module.GetRandomNumber(module.Config.PlateNumbers))
      else
        generatedPlate = string.upper(module.GetRandomLetter(module.Config.PlateLetters) .. module.GetRandomNumber(module.Config.PlateNumbers))
      end

      request('vehicles:isPlateTaken', function(isPlateTaken)
        if not isPlateTaken then
          doBreak = true
        end
      end, generatedPlate, module.Config.PlateUseSpace, module.Config.PlateLetters, module.Config.PlateNumbers)

      if doBreak then
        break
      end

      attempts = attempts + 1
    end   
  end

  return generatedPlate
end

module.Trim = function(value)
  if value then
    return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
  else
    return nil
  end
end
