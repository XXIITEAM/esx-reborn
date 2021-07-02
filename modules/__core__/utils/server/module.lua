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

-- Enumerate entities
module.game.getNearbyEntities = function(entities, coords, modelFilter, maxDistance, isPed)
	local nearbyEntities = {}
	coords = type(coords) == 'number' and GetEntityCoords(GetPlayerPed(coords)) or vector3(coords.x, coords.y, coords.z)
	for k, entity in pairs(entities) do
		if not isPed or (isPed and not IsPedAPlayer(entity)) then
			if not modelFilter or modelFilter[GetEntityModel(entity)] then
				local entityCoords = GetEntityCoords(entity)
				if not maxDistance or #(coords - entityCoords) <= maxDistance then
					table.insert(nearbyEntities, {entity=entity, coords=entityCoords})
				end
			end
		end
	end
	
	return nearbyEntities
end

module.game.getClosestEntity = function(entities, coords, modelFilter, maxDistance, isPed)
	local distance, closestEntity, closestCoords = maxDistance or 100
	coords = type(coords) == 'number' and GetEntityCoords(GetPlayerPed(coords)) or vector3(coords.x, coords.y, coords.z)

	for k, entity in pairs(entities) do
		if not isPed or (isPed and not IsPedAPlayer(entity)) then
			if not modelFilter or modelFilter[GetEntityModel(entity)] then
				local entityCoords = GetEntityCoords(entity)
				local dist = #(coords - entityCoords)
				if dist < distance then
					closestEntity, distance, closestCoords = entity, dist, entityCoords
				end
			end
		end
	end
	return closestEntity, distance, closestCoords
end

module.game.getPlayers = function(playerId, closest, coords, maxDistance)
	local players = {}
	local maxDistance = maxDistance or 100
	local playerPed = playerId and GetPlayerPed(playerId)
	if type then coords = type(coords) == 'number' and GetEntityCoords(GetPlayerPed(coords)) or vector3(coords.x, coords.y, coords.z) end
	
	for k, player in pairs(GetPlayers()) do
		if player ~= playerId then
			if type == nil then
				table.insert(players, {id = player, ped = GetPlayerPed(player)})
			else
				local entity = GetPlayerPed(player)
				local entityCoords = GetEntityCoords(entity)
				if not closest then
					if #(coords - entityCoords) <= maxDistance then
						table.insert(players, {id = player, ped = entity, coords = entityCoords})
					end
				else
					local dist = #(coords - entityCoords)
					if dist <= players.dist or maxDistance then
						players = {id = player, ped = entity, coords = entityCoords, distance = dist}
					end
				end
			end
		end
	end
	
	return players
end


-- Get entities in area
module.game.getPlayersInArea = function(playerId, coords, maxDistance)
	return module.game.getPlayers(playerId, false, coords, maxDistance) 
end

module.game.getPedsInArea = function(coords, maxDistance, modelFilter)
	return module.game.getNearbyEntities(GetAllPeds(), coords, modelFilter, true) 
end

module.game.getObjectsInArea = function(coords, maxDistance, modelFilter)
	return module.game.getNearbyEntities(GetAllObjects(), coords, modelFilter, maxDistance) 
end

module.game.getVehiclesInArea = function(coords, maxDistance, modelFilter)
	return module.game.getNearbyEntities(GetAllVehicles(), coords, modelFilter, maxDistance) 
end

-- Get closest entity of type
module.game.getClosestPlayer = function(playerId, coords, maxDistance)
	return module.game.getPlayers(playerId, true, coords)
end

module.game.getClosestPed = function(coords, maxDistance, modelFilter)
	return module.game.getClosestEntity(GetAllPeds(), coords, modelFilter, maxDistance, true)
end

module.game.getClosestObject = function(coords, maxDistance, modelFilter)
	return module.game.getClosestEntity(GetAllObjects(), coords, modelFilter, maxDistance)
end

module.game.getClosestVehicle = function(coords, maxDistance, modelFilter)
	return module.game.getClosestEntity(GetAllVehicles(), coords, modelFilter, maxDistance)
end
