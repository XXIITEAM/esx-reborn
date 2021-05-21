-- Copyright (c) Jérémie N'gadi
--
-- All rights reserved.
--
-- Even if 'All rights reserved' is very clear :
--
--   You shall not use any piece of this software in a commercial product / service
--   You shall not resell this software
--   You shall not provide any facility to install this particular software in a commercial product / service
--   If you redistribute this software, you must link to ORIGINAL repository at https://github.com/ESX-Org/es_extended
--   This copyright should appear in every part of the project code

------------------------------------------------------------------------
----------                                                    ----------
--                                IMPORTS                             --
----------                                                    ----------
------------------------------------------------------------------------

M('events')
M('serializable')
M('cache')
M('ui.menu')

local Input = M('input')
local HUD   = M('game.hud')
local utils = M("utils")

------------------------------------------------------------------------
----------                                                    ----------
--                              FUNCTIONS                             --
----------                                                    ----------
------------------------------------------------------------------------

module.Init()

------------------------------------------------------------------------
----------                                                    ----------
--                               THREADS                              --
----------                                                    ----------
------------------------------------------------------------------------

ESX.SetInterval(250, function()
  if module.CharacterLoaded then
    if not module.IsInShopMenu then
      if utils.game.isPlayerInZone(module.Config.VehicleShopZones) then
        if not module.InMarker then
          module.InMarker = true
          emit('vehicleshop:enteredZone')
        end
      else
        if module.InMarker then
          module.InMarker = false
          emit('vehicleshop:exitedZone')
        end
      end
    end
  else
    Wait(1000)
  end
end)

ESX.SetInterval(5000, function()
  if module.IsInShopMenu then
    emitServer('vehicleshop:stillUsingMenu')
  end
end)

ESX.SetInterval(1, function()
  if module.InMarker or module.InSellMarker then
    if IsControlJustReleased(0, 38) and module.CurrentAction ~= nil then
      module.CurrentAction()
    end
  end

  if module.InTestDrive then
    if IsControlJustReleased(0, 38) then
      module.TestDriveTime = 0
    end
  end
end)