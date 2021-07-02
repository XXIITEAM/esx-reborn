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

module.PlayersToHide = {}
module.server = module.server or {}

local CREATE_AUTOMOBILE = GetHashKey('CREATE_AUTOMOBILE')

module.game.createVehicle = function (model, coords, heading, cb)

  if type(model) == 'string' then
    model = GetHashKey(model)
  end

	local vehicle = Citizen.InvokeNative(CREATE_AUTOMOBILE, model, coords, heading)

  local interval

  interval = ESX.SetInterval(0, function()
    if DoesEntityExist(vehicle) then
      ESX.ClearInterval(interval)
    end
  end)
  
  if vehicle and cb then
    cb(vehicle)
  else
    cb(nil)
  end
end

module.game.createPed = function (model, coords, heading, cb)
  if type(model) == 'string' then
    modelHash = GetHashKey(model)

    -- print("CreatePed: model = " .. model .. " | coords = " .. json.encode(coords) .. " | heading = " .. tostring(heading))
    local ped = CreatePed(4, modelHash, coords, heading, true, false)

    local interval

    interval = ESX.SetInterval(0, function()
      if DoesEntityExist(ped) then
        ESX.ClearInterval(interval)
      end
    end)
    
    if ped and cb then
      cb(ped)
    else
      cb(nil)
    end
  else
    cb(nil)
  end
end

module.game.createLocalVehicle = function(model, coords, heading, cb)
  if type(model) == 'string' then
    model = GetHashKey(model)
  end

  local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, false, false)

  if vehicle and cb then
    cb(vehicle)
  end
end

module.server.systemMessage = function(message)
  TriggerClientEvent('chat:addMessage', -1, {
    color = { 255, 0, 0},
    multiline = true,
    args = {"System", message}
  })
end
