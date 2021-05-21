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

local utils    = M("utils")
local Input    = M('input')

module.Init()

ESX.SetInterval(1, function()
    if module.IsInShopMenu then
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
        Wait(1000)
    end
end)

ESX.SetInterval(1000, function()
    if not module.IsInShopMenu then
        if utils.game.isPlayerInZone(module.Config.Zones) then
            if not module.inMarker then
                module.inMarker = true
            end
        else
            if module.inMarker then
                module.inMarker = false
            end
        end
    else
        Wait(1000)
    end
end)

ESX.SetInterval(1, function()
    if module.inMarker then
        if not module.ControlsDisabled then
            module.ControlsDisabled = true
            Input.DisableControl(Input.Groups.MOVE, Input.Controls.SPRINT)
            Input.DisableControl(Input.Groups.MOVE, Input.Controls.JUMP)
        end

        if module.IsInShopMenu then
            DisableControlAction(0,51,true)
        end
    else
        if module.ControlsDisabled then
            module.ControlsDisabled = false
            Input.EnableControl(Input.Groups.MOVE, Input.Controls.SPRINT)
            Input.EnableControl(Input.Groups.MOVE, Input.Controls.JUMP)
        end

        Wait(1000)
    end
end)