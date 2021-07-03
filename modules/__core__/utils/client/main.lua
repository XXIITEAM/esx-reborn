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

Citizen.CreateThread(function()
  while true do
    if not module.CharacterLoaded then
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
    else
      Wait(999)
    end

    Wait(1)
  end
end)

Citizen.CreateThread(function()
  while true do
    if not module.CharacterLoaded then
      if module.ControlsEnabled then
        module.ControlsEnabled = false
      end

      DisableAllControlActions(0)
    elseif module.CharacterLoaded and not module.ControlsEnabled then
      module.ControlsEnabled = true
      EnableAllControlActions(0)
    else
      Wait(999)
    end

    Wait(1)
  end
end)