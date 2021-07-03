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

local utils = M('utils')

module.Busy = false

module.AccessVending = function(interactable, object)
  if not module.Busy then
    module.Busy = true
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped, 0)
    local hash = GetHashKey(interactable.prop)

    if DoesEntityExist(object) then
      local position = GetOffsetFromEntityInWorldCoords(object, 0.0, -0.97, 0.05)
      TaskTurnPedToFaceEntity(ped, object, -1)
      utils.game.requestAnimDict("mini@sprunk")
      RequestAmbientAudioBank("VENDING_MACHINE")
      HintAmbientAudioBank("VENDING_MACHINE", 0, -1)
      SetPedResetFlag(ped, 322, true)

      local count = 0

      if not IsEntityAtCoord(ped, position, 0.05, 0.05, 0.05, false, true, 0) then
        TaskGoStraightToCoord(ped, position, 0.05, 20000, GetEntityHeading(object), 0.05)
        while not IsEntityAtCoord(ped, position, 0.05, 0.05, 0.05, false, true, 0) and count < 4 do
          count = count + 1
          Citizen.Wait(500)
        end
      end

      TaskTurnPedToFaceEntity(ped, vendingMachine, -1)
      Wait(1000)
      TaskPlayAnim(PlayerPedId(), "mini@sprunk", "plyr_buy_drink_pt1", 8.0, 5.0, -1, 50, 0, 0, 0, 0)
      Wait(3500)

      utils.game.requestModel(interactable.prop)
      local model = CreateObjectNoOffset(interactable.prop, position, true, false, false)

      SetEntityAsMissionEntity(model, true, true)
      SetEntityProofs(model, false, true, false, false, false, false, 0, false)
      if Config.Modules.Vending.AttachCoords[interactable.name] then
        local aCoords = Config.Modules.Vending.AttachCoords[interactable.name]
        -- print("X: " .. aCoords.x .. " Y: " .. aCoords.y .. " Z: " .. aCoords.z)
        -- print("RotX: " .. aCoords.rotX .. " RotY: " .. aCoords.rotY .. " RotZ: " .. aCoords.rotZ)
        AttachEntityToEntity(model, ped, GetPedBoneIndex(ped, 60309), aCoords.x, aCoords.y, aCoords.z, aCoords.rotX, aCoords.rotY, aCoords.rotZ, 1, 1, 0, 0, 2, 1)
      end

      Wait(500)
      StopAnimTask(PlayerPedId(), "mini@sprunk", "plyr_buy_drink_pt1", 1.0)
      Wait(750)
      utils.game.requestAnimDict("mp_player_int_upperarse_pick")
      TaskPlayAnim(PlayerPedId(), "mp_player_int_upperarse_pick", "mp_player_int_arse_pick", 8.0, 5.0, -1, 50, 0, 0, 0, 0)
      Wait(500)
      StopAnimTask(PlayerPedId(), "mp_player_int_upperarse_pick", "mp_player_int_arse_pick", 1.0)
      ClearPedTasks(PlayerPedId())

      if DoesEntityExist(model) then
        DetachEntity(model, true, true)
        DeleteEntity(model)
      end

      ReleaseAmbientAudioBank()
      RemoveAnimDict("mini@sprunk")
      RemoveAnimDict("mp_common_miss")
      SetModelAsNoLongerNeeded(object)
    end

    if interactable.name == "Sprunk" then
      utils.ui.showNotification('You purchased a ~g~' .. interactable.name .. "~s~.")
    elseif interactable.name == "E-Cola" then
      utils.ui.showNotification('You purchased an ~r~' .. interactable.name .. "~s~.")
    elseif interactable.name == "Water" then
      utils.ui.showNotification('You purchased a ~b~' .. interactable.name .. "~s~.")
    elseif interactable.name == "Candy" then
      utils.ui.showNotification('You purchased some ~y~' .. interactable.name .. "~s~.")
    end

    module.Busy = false
  end
end