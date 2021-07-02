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

onRequest("utils:spawnVehicle", function(source, cb, model, location, heading)
  if model and type(model) == 'string' then
    module.game.createVehicle(model, location, heading, function(vehicle)
      local count = 0

      while not DoesEntityExist(vehicle) and count < 1000 do
        count = count + 1
        Wait(10)
      end
      
      if DoesEntityExist(vehicle) then
        local vehicleID = NetworkGetNetworkIdFromEntity(vehicle)

        cb(vehicleID)
      else
        cb(false)
      end
    end)
  else
    cb(false)
  end
end)

onRequest("utils:spawnPed", function(source, cb, model, location, heading)
  if model and type(model) == 'string' then
    module.game.createPed(model, location, heading, function(ped)
      local count = 0

      while not DoesEntityExist(ped) and count < 1000 do
        count = count + 1
        Wait(10)
      end
      
      if DoesEntityExist(ped) then
        local pedID = NetworkGetNetworkIdFromEntity(ped)

        cb(ped)
      else
        cb(false)
      end
    end)
  else
    cb(false)
  end
end)
