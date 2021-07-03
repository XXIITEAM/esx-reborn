
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

on('esx:characterLoaded', function()
  module.CharacterLoaded = true
end)

-- onServer('vehicleshop:removedOwnedVehicle', function()
-- 	local playerPed = PlayerPedId()

-- 	if IsPedSittingInAnyVehicle(playerPed) then
-- 		local vehicle = GetVehiclePedIsIn(playerPed, false)

-- 		if GetPedInVehicleSeat(vehicle, -1) == playerPed then
-- 			module.DeleteVehicle(vehicle)
-- 		end
-- 	end
-- end)
