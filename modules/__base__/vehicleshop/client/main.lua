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

local Input = M('input')
local HUD   = M('game.hud')
local utils = M("utils")

module.Init()

Citizen.CreateThread(function()
  while true do
    if module.isInShopMenu then
      for _,playerId in pairs(GetActivePlayers()) do
        if playerId then
          local serverId = GetPlayerServerId(playerId)
          local ped = GetPlayerPed(GetPlayerFromServerId(serverId))
          if ped ~= PlayerPedId() then
            SetEntityNoCollisionEntity(PlayerPedId(), ped, true)
            SetEntityVisible(ped, false, false)
          end
        end
      end

      Wait(1)
    else
      Wait(20)
    end
  end
end)

ESX.SetInterval(250, function()
  if module.CharacterLoaded then
    if not module.isInShopMenu then
      if utils.game.isPlayerInZone(module.Config.VehicleShopZones) then
        if not module.inMarker then
          module.inMarker = true
          emit('vehicleshop:enteredZone')
        end
      else
        if module.inMarker then
          module.inMarker = false
          emit('vehicleshop:exitedZone')
        end
      end
    end
  else
    Wait(1000)
  end
end)

ESX.SetInterval(10000, function()
  if module.isInShopMenu then
    emitServer('vehicleshop:stillUsingMenu')
  end
end)

ESX.SetInterval(1, function()
  if module.inMarker or module.inSellMarker then
    if module.CharacterLoaded then
      if not module.ControlsLimited then
        module.ControlsLimited = true
        Input.DisableControl(Input.Groups.MOVE, Input.Controls.SPRINT)
        Input.DisableControl(Input.Groups.MOVE, Input.Controls.JUMP)
      end

      DisableControlAction(0,21,true)
      DisableControlAction(0,22,true)
      DisableControlAction(0,25,true)  -- disable aim
      DisableControlAction(0,47,true)  -- disable weapon
      DisableControlAction(0,58,true)  -- disable weapon
      DisableControlAction(0,263,true) -- disable melee
      DisableControlAction(0,264,true) -- disable melee
      DisableControlAction(0,257,true) -- disable melee
      DisableControlAction(0,140,true) -- disable melee
      DisableControlAction(0,141,true) -- disable melee
      DisableControlAction(0,142,true) -- disable melee
      DisableControlAction(0,143,true) -- disable melee

      NetworkSetFriendlyFireOption(false)
      SetCanAttackFriendly(PlayerPedId(), false, false)
    end

    if IsControlJustReleased(0, 38) and module.CurrentAction ~= nil then
      emit('sit:forceWakeup')
      module.CurrentAction()
    end

    if module.isInShopMenu then
      DisableControlAction(0,51,true)
    end
  else
    if module.ControlsLimited then
      Input.EnableControl(Input.Groups.MOVE, Input.Controls.SPRINT)
      Input.EnableControl(Input.Groups.MOVE, Input.Controls.JUMP)
      module.ControlsLimited = false
    end
  end

  if module.inTestDrive then
    if IsControlJustReleased(0, 51, true) then
      module.testDriveTime = 0
    end
  end
end)

ESX.SetInterval(20, function()
  if module.isInShopMenu then
    DisableControlAction(0, 75,  true)
    DisableControlAction(27, 75, true)
  end
end)
