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
--
-----
--
-- Following license apply for windPnPoly and isLeft:
--
-- The MIT License (MIT)
--
-- Copyright 2019 Romain Billot
--
-- Permission is hereby granted, free of charge, to any person
-- obtaining a copy of this software and associated documentation
-- files (the "Software"), to deal in the Software without
-- restriction, including without limitation the rights to use,
-- copy, modify, merge, publish, distribute, sublicense, and/or
-- sell copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following
-- conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED,INCLUDING BUT NOT LIMITED TO THE WARRANTIES
-- OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
-- HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.

M('constants')

-- Namespaces
module.game = module.game or {}
module.ui   = module.ui   or {}
module.math = module.math or {}
module.time = module.time or {}

-- Vars
module.IsFadedOut           = true
module.ExtraIsFadedOut      = true
module.FadeInActive         = false
module.ExtraFadeInActive    = false
module.CurrentModifier      = nil
module.CurrentExtraModifier = nil
module.FadeStrength         = 0
module.ExtraFadeStrength    = 0
module.LoopReady            = false
module.CurrentModifier      = nil
module.CharacterLoaded      = false
module.ControlsEnabled      = false

-- Wind Around Point Poly
module.game.windPnPoly = function(tablePoints, flag)
  if tostring(type(flag)) == table then
    py = flag.y
    px = flag.x
  else
    px, py, pz = table.unpack(GetEntityCoords(PlayerPedId(), true))
  end
  wn = 0
  table.insert(tablePoints, tablePoints[1])
  for i=1, #tablePoints do
    if i == #tablePoints then
      break
    end
    if tonumber(tablePoints[i].y) <= py then
      if tonumber(tablePoints[i+1].y) > py then
        if module.game.isLeft(tablePoints[i], tablePoints[i+1], flag) > 0 then
          wn = wn + 1
        end
      end
    else
      if tonumber(tablePoints[i+1].y) <= py then
        if module.game.isLeft(tablePoints[i], tablePoints[i+1], flag) < 0 then
          wn = wn - 1
        end
      end
    end
  end
  return wn
end

module.game.isLeft = function(p1s, p2s, flag)
  p1 = p1s
  p2 = p2s
  if tostring(type(flag)) == "table" then
    p = flag
  else
    p = GetEntityCoords(PlayerPedId(), true)
  end
  return ( ((p1.x - p.x) * (p2.y - p.y))
            - ((p2.x -  p.x) * (p1.y - p.y)) )
end

-- Game
module.game.requestModel = function(model, cb)

  if type(model) == 'string' then
    model = GetHashKey(model)
  end

  local interval

  RequestModel(model)

  interval = ESX.SetInterval(50, function()

    if HasModelLoaded(model) then

      ESX.ClearInterval(interval)

      if cb ~= nil then
        cb()
      end

    end

  end)

end

module.game.requestAnimDict = function(model, cb)
  if type(model) == 'string' then

    local interval

    RequestAnimDict(model)

    interval = ESX.SetInterval(50, function()
      if HasAnimDictLoaded(model) then
        ESX.ClearInterval(interval)

        if cb ~= nil then
          cb()
        end
      end
    end)
  end
end

module.game.teleport = function(entity, coords)
  if DoesEntityExist(entity) then
    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    local timeout = 0

    -- we can get stuck here if any of the axies are "invalid"
    while not HasCollisionLoadedAroundEntity(entity) and timeout < 2000 do
      Citizen.Wait(0)
      timeout = timeout + 1
    end

    SetEntityCoords(entity, coords.x, coords.y, coords.z, false, false, false, false)

    if type(coords) == 'table' and coords.heading then
      SetEntityHeading(entity, coords.heading)
    end
  end
end

module.game.createObject = function(model, coords, cb)

  if type(model) == 'string' then
    model = GetHashKey(model)
  end

  module.game.requestModel(model, function()

    local obj = CreateObject(model, coords.x, coords.y, coords.z, true, false, true)
    SetModelAsNoLongerNeeded(model)

    if cb ~= nil then
      cb(obj)
    end

  end)

end

module.game.createLocalObject = function(model, coords, cb)

  if type(model) == 'string' then
    model = GetHashKey(model)
  end

  module.game.requestModel(model, function()

    local obj = CreateObject(model, coords.x, coords.y, coords.z, false, false, true)
    SetModelAsNoLongerNeeded(model)

    if cb ~= nil then
      cb(obj)
    end

  end)

end

module.game.createVehicle = function(model, coords, heading, cb)

  if type(model) == 'string' then
    model = GetHashKey(model)
  end

  module.game.requestModel(model, function()

    RequestCollisionAtCoord(coords.x, coords.y, coords.z)

    local vehicle   = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
    local networkId = NetworkGetNetworkIdFromEntity(vehicle)
    local timeout   = 0

    SetNetworkIdCanMigrate(networkId, true)
    SetEntityAsMissionEntity(vehicle, true, false)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetVehRadioStation(vehicle, 'OFF')
    SetModelAsNoLongerNeeded(model)

    if cb ~= nil then
      cb(vehicle)
    end

  end)

end

module.game.createLocalVehicle = function(model, coords, heading, cb)

  if type(model) == 'string' then
    model = GetHashKey(model)
  end

  module.game.requestModel(model, function()

    RequestCollisionAtCoord(coords.x, coords.y, coords.z)

    local vehicle   = CreateVehicle(model, coords.x, coords.y, coords.z, heading, false, false)
    local networkId = NetworkGetNetworkIdFromEntity(vehicle)
    local timeout   = 0

    SetNetworkIdCanMigrate(networkId, true)
    SetEntityAsMissionEntity(vehicle, true, false)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetVehRadioStation(vehicle, 'OFF')
    SetModelAsNoLongerNeeded(model)

    if cb ~= nil then
      cb(vehicle)
    end

  end)

end

module.game.deleteVehicle = function(vehicle)

  SetEntityAsMissionEntity(vehicle, false, true)
  Citizen.Wait(250)
  DeleteVehicle(vehicle)

end

module.game.deleteObject = function(obj)

  SetEntityAsMissionEntity(object, false, true)
  Citizen.Wait(250)
  DeleteObject(object)

end

module.game.isVehicleEmpty = function(vehicle)

  local passengers     = GetVehicleNumberOfPassengers(vehicle)
  local driverSeatFree = IsVehicleSeatFree(vehicle, -1)

  return (passengers == 0) and driverSeatFree

end


-- Enumerate entities
module.game.getNearbyEntities = function(entities, playerEntities, coords, maxDistance)
	local nearbyEntities = {}
	coords = coords and vector3(coords.x, coords.y, coords.z) or GetEntityCoords(PlayerPedId())
	for k, entity in pairs(entities) do
		if not playerEntities then
			local entityCoords = GetEntityCoords(entity)
			if not maxDistance or #(coords - entityCoords) <= maxDistance then
				table.insert(nearbyEntities, {ped=entity, coords=entityCoords})
			end
		else
			local entityCoords = GetEntityCoords(entity)
			if not maxDistance or #(coords - entityCoords) <= maxDistance then
				table.insert(nearbyEntities, {id=k, ped=entity, coords=entityCoords})
			end
		end
	end
	
	return nearbyEntities
end

module.game.getPlayers = function(includePlayer)
	local players, playerId = {}, PlayerId()
	
	for k, player in pairs(GetActivePlayers()) do
		if includePlayer or player ~= playerId then
			players[player] = GetPlayerPed(player)
		end
	end

	return players
end

module.game.getClosestEntity = function(entities, playerEntities, coords, modelFilter, maxDistance)
	local distance, closestEntity, closestCoords = maxDistance or 100
	coords = coords and vector3(coords.x, coords.y, coords.z) or GetEntityCoords(PlayerPedId())

	for k, entity in pairs(entities) do
		if not playerEntities or (playerEntities and IsPedAPlayer(entity)) then
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


-- Get entities in area
module.game.getPlayersInArea = function(includePlayer, coords, maxDistance)
	return module.game.getNearbyEntities(module.game.getPlayers(includePlayer), true, coords, maxDistance) 
end

module.game.getPedsInArea = function(coords, maxDistance)
	return module.game.getNearbyEntities(GetGamePool('CPed'), false, coords, maxDistance) 
end

module.game.getObjectsInArea = function(coords, maxDistance)
	return module.game.getNearbyEntities(GetGamePool('CObject'), false, coords, maxDistance) 
end

module.game.getVehiclesInArea = function(coords, maxDistance)
	return module.game.getNearbyEntities(GetGamePool('CVehicle'), false, coords, maxDistance) 
end

module.game.getPickupsInArea = function(coords, maxDistance)  
	return module.game.getNearbyEntities(GetGamePool('CPickup'), false, coords, maxDistance) 
end


-- Get closest entity of type
module.game.getClosestPlayer = function(coords, modelFilter, maxDistance)
	return module.game.getClosestEntity(module.game.getPlayers(), true, coords, modelFilter, maxDistance)
end

module.game.getClosestPed = function(coords, modelFilter, maxDistance)
	return module.game.getClosestEntity(GetGamePool('CPed'), false, coords, modelFilter, maxDistance)
end

module.game.getClosestObject = function(coords, modelFilter, maxDistance)
	return module.game.getClosestEntity(GetGamePool('CObject'), false, coords, modelFilter, maxDistance)
end

module.game.getClosestVehicle = function(coords, modelFilter, maxDistance)
	return module.game.getClosestEntity(GetGamePool('CVehicle'), false, coords, modelFilter, maxDistance)
end

module.game.getClosestPickup = function(coords, modelFilter, maxDistance)
	return module.game.getClosestEntity(GetGamePool('CPickup'), false, coords, modelFilter, maxDistance)
end

module.game.getEntityFacing = function(type)  
	local playerPed    = PlayerPedId()
	local playerCoords = GetEntityCoords(playerPed)
	local inDirection  = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)
	local rayHandle    = StartShapeTestRay(playerCoords, inDirection, 10, playerPed, 0)
	local numRayHandle, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
	
	if hit == 1 then
		local entityType = GetEntityType(entityHit)
		entityType = entityType == type or entityType > 0
		if entityHit > 0 then return entityHit end
	end

	return nil
end

module.game.getVehicleProperties = function(vehicle)

  if DoesEntityExist(vehicle) then

    local color1 = {}
    local color2 = {}

    color1.r, color1.g, color1.b = GetVehicleCustomPrimaryColour(vehicle)
    color2.r, color2.g, color2.b = GetVehicleCustomSecondaryColour(vehicle)

    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
    local extras = {}

    for extraId=0, 12 do
      if DoesExtraExist(vehicle, extraId) then
        local state = IsVehicleExtraTurnedOn(vehicle, extraId) == 1
        extras[tostring(extraId)] = state
      end
    end

    return {

      model             = GetEntityModel(vehicle),

      plate             = module.math.Trim(GetVehicleNumberPlateText(vehicle)),
      plateIndex        = GetVehicleNumberPlateTextIndex(vehicle),

      bodyHealth        = math.round(GetVehicleBodyHealth(vehicle), 1),
      engineHealth      = math.round(GetVehicleEngineHealth(vehicle), 1),
      tankHealth        = math.round(GetVehiclePetrolTankHealth(vehicle), 1),

      fuelLevel         = math.round(GetVehicleFuelLevel(vehicle), 1),
      dirtLevel         = math.round(GetVehicleDirtLevel(vehicle), 1),
      color1            = color1,
      color2            = color2,

      pearlescentColor  = pearlescentColor,
      wheelColor        = wheelColor,

      wheels            = GetVehicleWheelType(vehicle),
      windowTint        = GetVehicleWindowTint(vehicle),
      xenonColor        = GetVehicleXenonLightsColour(vehicle),

      neonEnabled       = {
        IsVehicleNeonLightEnabled(vehicle, 0),
        IsVehicleNeonLightEnabled(vehicle, 1),
        IsVehicleNeonLightEnabled(vehicle, 2),
        IsVehicleNeonLightEnabled(vehicle, 3)
      },

      neonColor         = table.pack(GetVehicleNeonLightsColour(vehicle)),
      extras            = extras,
      tyreSmokeColor    = table.pack(GetVehicleTyreSmokeColor(vehicle)),
      modSpoilers       = GetVehicleMod(vehicle, 0),
      modFrontBumper    = GetVehicleMod(vehicle, 1),
      modRearBumper     = GetVehicleMod(vehicle, 2),
      modSideSkirt      = GetVehicleMod(vehicle, 3),
      modExhaust        = GetVehicleMod(vehicle, 4),
      modFrame          = GetVehicleMod(vehicle, 5),
      modGrille         = GetVehicleMod(vehicle, 6),
      modHood           = GetVehicleMod(vehicle, 7),
      modFender         = GetVehicleMod(vehicle, 8),
      modRightFender    = GetVehicleMod(vehicle, 9),
      modRoof           = GetVehicleMod(vehicle, 10),
      modEngine         = GetVehicleMod(vehicle, 11),
      modBrakes         = GetVehicleMod(vehicle, 12),
      modTransmission   = GetVehicleMod(vehicle, 13),
      modHorns          = GetVehicleMod(vehicle, 14),
      modSuspension     = GetVehicleMod(vehicle, 15),
      modArmor          = GetVehicleMod(vehicle, 16),
      modTurbo          = IsToggleModOn(vehicle, 18),
      modSmokeEnabled   = IsToggleModOn(vehicle, 20),
      modXenon          = IsToggleModOn(vehicle, 22),
      modFrontWheels    = GetVehicleMod(vehicle, 23),
      modBackWheels     = GetVehicleMod(vehicle, 24),
      modPlateHolder    = GetVehicleMod(vehicle, 25),
      modVanityPlate    = GetVehicleMod(vehicle, 26),
      modTrimA          = GetVehicleMod(vehicle, 27),
      modOrnaments      = GetVehicleMod(vehicle, 28),
      modDashboard      = GetVehicleMod(vehicle, 29),
      modDial           = GetVehicleMod(vehicle, 30),
      modDoorSpeaker    = GetVehicleMod(vehicle, 31),
      modSeats          = GetVehicleMod(vehicle, 32),
      modSteeringWheel  = GetVehicleMod(vehicle, 33),
      modShifterLeavers = GetVehicleMod(vehicle, 34),
      modAPlate         = GetVehicleMod(vehicle, 35),
      modSpeakers       = GetVehicleMod(vehicle, 36),
      modTrunk          = GetVehicleMod(vehicle, 37),
      modHydrolic       = GetVehicleMod(vehicle, 38),
      modEngineBlock    = GetVehicleMod(vehicle, 39),
      modAirFilter      = GetVehicleMod(vehicle, 40),
      modStruts         = GetVehicleMod(vehicle, 41),
      modArchCover      = GetVehicleMod(vehicle, 42),
      modAerials        = GetVehicleMod(vehicle, 43),
      modTrimB          = GetVehicleMod(vehicle, 44),
      modTank           = GetVehicleMod(vehicle, 45),
      modWindows        = GetVehicleMod(vehicle, 46),
      modLivery         = GetVehicleMod(vehicle, 48)
    }
  end

end

module.game.setVehicleProperties = function(vehicle, props)

  if DoesEntityExist(vehicle) then
    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)

    SetVehicleModKit(vehicle, 0)

    if props.plate             then SetVehicleNumberPlateText(vehicle, props.plate) end
    if props.plateIndex        then SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex) end
    if props.bodyHealth        then SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0) end
    if props.engineHealth      then SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0) end    
    if props.tankHealth        then SetVehiclePetrolTankHealth(vehicle, props.tankHealth + 0.0) end
    if props.fuelLevel         then SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0) end
    if props.dirtLevel         then SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0) end
    if props.color1            then SetVehicleCustomPrimaryColour(vehicle, props.color1.r, props.color1.g, props.color1.b)  end
    if props.color2            then SetVehicleCustomSecondaryColour(vehicle, props.color2.r, props.color2.g, props.color2.b) end
    if props.pearlescentColor  then SetVehicleExtraColours(vehicle, props.pearlescentColor, wheelColor) end
    if props.wheelColor        then SetVehicleExtraColours(vehicle, props.pearlescentColor or pearlescentColor, props.wheelColor) end
    if props.wheels            then SetVehicleWheelType(vehicle, props.wheels) end
    if props.windowTint        then SetVehicleWindowTint(vehicle, props.windowTint) end

    if props.neonEnabled then
      SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
      SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
      SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
      SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
    end

    if props.extras then
      for extraId,enabled in pairs(props.extras) do
        if enabled then
          SetVehicleExtra(vehicle, tonumber(extraId), 0)
        else
          SetVehicleExtra(vehicle, tonumber(extraId), 1)
        end
      end
    end

    if props.neonColor          then SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3]) end
    if props.xenonColor         then SetVehicleXenonLightsColour(vehicle, props.xenonColor) end
    if props.modSmokeEnabled    then ToggleVehicleMod(vehicle, 20, true) end
    if props.tyreSmokeColor     then SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3]) end
    if props.modSpoilers        then SetVehicleMod(vehicle, 0, props.modSpoilers, false) end
    if props.modFrontBumper     then SetVehicleMod(vehicle, 1, props.modFrontBumper, false) end
    if props.modRearBumper      then SetVehicleMod(vehicle, 2, props.modRearBumper, false) end
    if props.modSideSkirt       then SetVehicleMod(vehicle, 3, props.modSideSkirt, false) end
    if props.modExhaust         then SetVehicleMod(vehicle, 4, props.modExhaust, false) end
    if props.modFrame           then SetVehicleMod(vehicle, 5, props.modFrame, false) end
    if props.modGrille          then SetVehicleMod(vehicle, 6, props.modGrille, false) end
    if props.modHood            then SetVehicleMod(vehicle, 7, props.modHood, false) end
    if props.modFender          then SetVehicleMod(vehicle, 8, props.modFender, false) end
    if props.modRightFender     then SetVehicleMod(vehicle, 9, props.modRightFender, false) end
    if props.modRoof            then SetVehicleMod(vehicle, 10, props.modRoof, false) end
    if props.modEngine          then SetVehicleMod(vehicle, 11, props.modEngine, false) end
    if props.modBrakes          then SetVehicleMod(vehicle, 12, props.modBrakes, false) end
    if props.modTransmission    then SetVehicleMod(vehicle, 13, props.modTransmission, false) end
    if props.modHorns           then SetVehicleMod(vehicle, 14, props.modHorns, false) end
    if props.modSuspension      then SetVehicleMod(vehicle, 15, props.modSuspension, false) end
    if props.modArmor           then SetVehicleMod(vehicle, 16, props.modArmor, false) end
    if props.modTurbo           then ToggleVehicleMod(vehicle, 18, props.modTurbo) end
    if props.modXenon           then ToggleVehicleMod(vehicle, 22, props.modXenon) end
    if props.modFrontWheels     then SetVehicleMod(vehicle, 23, props.modFrontWheels, false) end
    if props.modBackWheels      then SetVehicleMod(vehicle, 24, props.modBackWheels, false) end
    if props.modPlateHolder     then SetVehicleMod(vehicle, 25, props.modPlateHolder, false) end
    if props.modVanityPlate     then SetVehicleMod(vehicle, 26, props.modVanityPlate, false) end
    if props.modTrimA           then SetVehicleMod(vehicle, 27, props.modTrimA, false) end
    if props.modOrnaments       then SetVehicleMod(vehicle, 28, props.modOrnaments, false) end
    if props.modDashboard       then SetVehicleMod(vehicle, 29, props.modDashboard, false) end
    if props.modDial            then SetVehicleMod(vehicle, 30, props.modDial, false) end
    if props.modDoorSpeaker     then SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false) end
    if props.modSeats           then SetVehicleMod(vehicle, 32, props.modSeats, false) end
    if props.modSteeringWheel   then SetVehicleMod(vehicle, 33, props.modSteeringWheel, false) end
    if props.modShifterLeavers  then SetVehicleMod(vehicle, 34, props.modShifterLeavers, false) end
    if props.modAPlate          then SetVehicleMod(vehicle, 35, props.modAPlate, false) end
    if props.modSpeakers        then SetVehicleMod(vehicle, 36, props.modSpeakers, false) end
    if props.modTrunk           then SetVehicleMod(vehicle, 37, props.modTrunk, false) end
    if props.modHydrolic        then SetVehicleMod(vehicle, 38, props.modHydrolic, false) end
    if props.modEngineBlock     then SetVehicleMod(vehicle, 39, props.modEngineBlock, false) end
    if props.modAirFilter       then SetVehicleMod(vehicle, 40, props.modAirFilter, false) end
    if props.modStruts          then SetVehicleMod(vehicle, 41, props.modStruts, false) end
    if props.modArchCover       then SetVehicleMod(vehicle, 42, props.modArchCover, false) end
    if props.modAerials         then SetVehicleMod(vehicle, 43, props.modAerials, false) end
    if props.modTrimB           then SetVehicleMod(vehicle, 44, props.modTrimB, false) end
    if props.modTank            then SetVehicleMod(vehicle, 45, props.modTank, false) end
    if props.modWindows         then SetVehicleMod(vehicle, 46, props.modWindows, false) end
    if props.modLivery          then SetVehicleMod(vehicle, 48, props.modLivery, false) end
  end
end

module.game.getForcedComponents = function(ped, componentId, drawableId, textureId)

  local components = {}
  local compHash   = GetHashNameForComponent(ped, componentId, drawableId, textureId)
  local count      = GetShopPedApparelForcedComponentCount(compHash)

  for i=0, PV_COMP_MAX - 1, 1 do
    components[i] = {}
  end

  for i=0, count - 1, 1 do

    local nameHash, enumValue, componentType = GetForcedComponent(compHash, i)
    local entry                              = components[componentType]

    entry[#entry + 1] = {nameHash, enumValue}

  end

  return components

end

module.game.ensureForcedComponents = function(ped, componentId, drawableId, textureId)

  local forcedComponents = module.game.getForcedComponents(ped, componentId, drawableId, textureId)

  for k,v in pairs(forcedComponents) do
    
    local compId = tonumber(k)

    for i=1, #v, 1 do
      local forcedComponent = v[i]
      SetPedComponentVariation(ped, compId, forcedComponent[2], 0, 0)
    end

  end

  return forcedComponents

end

module.game.setEnforcedPedComponentVariation = function(ped, componentId, drawableId, textureId, paletteId)
  paletteId = paletteId or 0
  SetPedComponentVariation(ped, componentId, drawableId, textureId, paletteId)
  return module.game.ensureForcedComponents(ped, componentId, drawableId, textureId)
end

module.game.doSpawn = function(data, cb)
  exports.spawnmanager:spawnPlayer(data, cb)
end

-- Check if player is within poly zone
module.game.isPlayerInZone = function(zone)
  local plyCoords = GetEntityCoords(PlayerPedId(), true)

  if zone then
    for k, v in pairs(zone) do
      if GetDistanceBetweenCoords(plyCoords, tonumber(v.Center.x), tonumber(v.Center.y), 1.01, false) < tonumber(v.MaxLength) then
        local n = module.game.windPnPoly(v.Points, plyCoords)
        if n ~= 0 then
          return true
        else
          return false
        end
      end
    end
  else
    return false
  end
end

module.game.waitForVehicleToLoad = function(modelHash)
  modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

  if not HasModelLoaded(modelHash) then
    module.game.requestModel(modelHash)

    BeginTextCommandBusyspinnerOn('STRING')
    AddTextComponentSubstringPlayerName("Please wait for the model to load...")
    EndTextCommandBusyspinnerOn(4)

    while not HasModelLoaded(modelHash) do
      Citizen.Wait(0)
      DisableAllControlActions(0)
    end

    BusyspinnerOff()
  end
end

module.game.CharacterLoaded = function()
  module.CharacterLoaded = true
end

module.game.UnloadCharacter = function()
  module.CharacterLoaded = false
end

module.game.RequestAnimSet = function(dict)
  RequestAnimSet(dict)
end

module.game.RequestAnimDict = function(dict)

end

module.game.StartAttitude = function(lib, anim)
  RequestAnimSet(lib)

  while not HasAnimSetLoaded(lib) do
    Wait(0)
  end

  SetPedMovementClipset(PlayerPedId(), anim, true)
end

module.game.StartScenarioInPlace = function(anim)
  TaskStartScenarioInPlace(PlayerPedId(), anim, 0, false)
end

module.game.LoopAnimation = function(dict,animationName,animationLength,flag)
  RequestAnimDict(dict)
  while not HasAnimDictLoaded(dict) do
    Wait(0)
  end
  TaskPlayAnim(PlayerPedId(), dict, animationName, 8.0, 8.0, animationLength, flag, 0, false, false, false)
end

module.game.StartTempAnimation = function(dict,animationName,animationLength,flag)
  RequestAnimDict(dict)
  while not HasAnimDictLoaded(dict) do
    Wait(0)
  end
  TaskPlayAnim(PlayerPedId(), dict, animationName, 8.0, 8.0, animationLength, flag, 0, false, false, false)
  Wait(animationLength)
  StopAnimTask(PlayerPedId(), dict, animationName, 1.0)
end

module.game.FadeInModifier = function(modifier, speed, amount, max)
  if module.FadeInActive then
    print("Was not ready, pausing")
    module.FadeInActive = false
    Wait(1000)
  end

  if module.CurrentModifier ~= modifier then
    module.FadeStrength = 0
    ClearTimecycleModifier()
    ClearExtraTimecycleModifier()
    SetTimecycleModifier(modifier)
    SetTimecycleModifierStrength(0)
  end

  module.FadeInActive = true
  module.CurrentModifier = modifier

  if module.FadeStrength > max then
    print("reducing")
    module.game.ReduceModifier(modifier, speed, amount, max)
  else
    print("increasing")
    Citizen.CreateThread(function()
      while true do
        if tonumber(module.FadeStrength) < max and module.FadeInActive then
          module.FadeStrength = module.FadeStrength + amount
          SetTimecycleModifierStrength(module.FadeStrength)
          Wait(speed)
        else
          if not module.ModifierActive then
            module.ModifierActive = true
          end

          break
        end
      end
    end)
  end
end

module.game.ReduceModifier = function(modifier, speed, amount, max)
  Citizen.CreateThread(function()
    while true do
      if tonumber(module.FadeStrength) > max then
        module.FadeStrength = module.FadeStrength - amount
        SetTimecycleModifierStrength(module.FadeStrength)
        Wait(speed)
      else
        break
      end
    end
  end)
end

-- Lighter Resource Usage
module.game.FadeOutModifier = function(speed, amount)
  module.FadeInActive = false
  module.IsFadedOut   = false

  Citizen.CreateThread(function()
    while true do
      if tonumber(module.FadeStrength) > 0 then
        module.FadeStrength = module.FadeStrength - amount
        SetTimecycleModifierStrength(module.FadeStrength)
        Wait(speed)
      else
        module.IsFadedOut      = true
        module.ModifierActive  = false
        module.CurrentModifier = nil
        ClearTimecycleModifier()
        break
      end
    end
  end)
end

-- Lighter Resource Usage
module.game.LoopModifier = function(modifier, speed, amount, min, max)
  if module.ModifierActive and not module.ExtraModifierActive then
    ClearTimecycleModifier()
    module.ModifierActive       = false
  elseif module.ModifierActive and module.ExtraModifierActive then
    ClearTimecycleModifier()
    ClearExtraTimecycleModifier()
    module.ModifierActive       = false
    module.ExtraModifierActive  = false
  end

  SetTimecycleModifier(modifier)

  module.FadeStrength      = 0
  module.Increasing        = true
  module.BreakLoopModifier = false

  Citizen.CreateThread(function()
    while true do     
      if module.BreakLoopModifier then
        ClearTimecycleModifier()
        module.ModifierActive = false
        break
      end

      if not module.ModifierActive then
        module.IsFadedOut      = false
        module.ModifierActive  = true
      end

      if module.Increasing then
        module.FadeStrength = module.FadeStrength + amount

        if tonumber(module.FadeStrength) <= max then
          SetTimecycleModifierStrength(module.FadeStrength)
        else
          module.Increasing = false
        end

        Wait(speed)
      elseif not module.Increasing then
        module.FadeStrength = module.FadeStrength - amount

        if module.FadeStrength >= min then
          SetTimecycleModifierStrength(module.FadeStrength)
        else
          module.Increasing = true
        end

        Wait(speed)
      else
        Wait(speed)
      end
    end
  end)
end

-- Heavier Resource Usage
module.game.SwingingLoopModifier = function(modifier, modifier2, speed, amount, min, max)
  if module.ModifierActive and not module.ExtraModifierActive then
    ClearTimecycleModifier()
    module.ModifierActive       = false
  elseif module.ModifierActive and module.ExtraModifierActive then
    ClearTimecycleModifier()
    ClearExtraTimecycleModifier()
    module.ModifierActive       = false
    module.ExtraModifierActive  = false
  end

  SetTimecycleModifier(modifier)
  SetTimecycleModifierStrength(max)
  SetExtraTimecycleModifier(modifier2)
  SetExtraTimecycleModifierStrength(min)

  module.FadeStrength              = max
  module.ExtraFadeStrength         = min
  module.Increasing                = true
  module.BreakSwingingLoopModifier = false
  module.LoopReady                 = false

  Citizen.CreateThread(function()
    while true do 
      if module.BreakSwingingLoopModifier then
        ClearTimecycleModifier()
        ClearExtraTimecycleModifier()
        module.ModifierActive       = false
        module.ExtraModifierActive  = false
        break
      end

      if not module.ModifierActive or not module.ExtraModifierActive then
        module.IsFadedOut           = false
        module.ExtraIsFadedOut      = false
        module.ModifierActive       = true
        module.ExtraModifierActive  = true
      end

      if module.Increasing then
        if tonumber(module.FadeStrength) < max then
          module.FadeStrength = module.FadeStrength + amount
          SetTimecycleModifierStrength(module.FadeStrength)

          if module.ExtraFadeStrength > min then
            module.ExtraFadeStrength = module.ExtraFadeStrength - amount
            SetExtraTimecycleModifierStrength(module.ExtraFadeStrength)
          end
        else
          module.Increasing = false
        end

        Wait(speed)
      elseif not module.Increasing then
        if module.FadeStrength > min then
          module.FadeStrength = module.FadeStrength - amount
          SetTimecycleModifierStrength(module.FadeStrength)

          module.ExtraFadeStrength = module.ExtraFadeStrength + amount
          SetExtraTimecycleModifierStrength(module.ExtraFadeStrength)
        else
          module.Increasing = true
        end

        Wait(speed)
      else
        Wait(speed)
      end
    end
  end)
end

module.game.ClearModifiers = function()
  module.ModifierActive  = false
  module.FadeInActive    = false
  module.CurrentModifier = nil
  ClearTimecycleModifier()
  ClearExtraTimecycleModifier()
  SetTimecycleModifierStrength(0)
  SetExtraTimecycleModifierStrength(0)
end

module.game.BreakLoopModifier = function()
  if module.ModifierActive then
    module.BreakLoopModifier = true
  end
end

module.game.BreakSwingingLoopModifier = function()
  if module.ExtraModifierActive then
    module.BreakSwingingLoopModifier = true
  end
end

module.game.IsModifierFadedOut = function()
  return module.IsFadedOut
end

module.game.IsExtraModifierFadedOut = function()
  return module.ExtraIsFadedOut
end

-- UI
module.ui.showNotification = function(msg)
  SetNotificationTextEntry('STRING')
  AddTextComponentSubstringPlayerName(msg)
  DrawNotification(false, true)
end

-- Draw3DText
module.ui.draw3DText = function(x, y, z, r, g, b, a, string)
  local onScreen, _x, _y = World3dToScreen2d(x, y, z+1.0)
  local px,py,pz=table.unpack(GetGameplayCamCoords())
  local factor = (string.len(string)) / 370

  if onScreen then
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextDropShadow(0, 0, 0, 55)
    SetTextEdge(0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(string)
    DrawText(_x,_y)
    DrawRect(_x,_y + 0.0125, 0.015 + factor, 0.03, r, g, b, a)
  end
end

module.ui.renderBox = function(xMin,xMax,yMin,yMax,color1,color2,color3,color4)
  DrawRect(xMin, yMin,xMax, yMax, color1, color2, color3, color4)
end

module.ui.drawText = function(string, x, y)
  SetTextFont(2)
  SetTextProportional(0)
  SetTextScale(0.5, 0.5)
  SetTextColour(255, 255, 255, 255)
  SetTextDropShadow(0, 0, 0, 0,255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(2)
  SetTextEntry("STRING")
  AddTextComponentString(string)
  DrawText(x,y)
end

module.ui.drawVehicleStats = function(xoffset, yoffset, windowSizeX, windowSizeY, statOffsetX, statSizeX, statSizeY, topSpeedStat, accelerationStat, gearStat, capacityStat)
  module.ui.renderBox(xoffset - 0.05, windowSizeX, (yoffset - 0.0325), windowSizeY, 0, 0, 0, 225)

  module.ui.drawText("Top Speed", xoffset - 0.146, yoffset - 0.105)
  module.ui.renderBox(statOffsetX, statSizeX, (yoffset - 0.07), statSizeY, 60, 60, 60, 225)
  module.ui.renderBox(statOffsetX - ((statSizeX - topSpeedStat) / 2), topSpeedStat, (yoffset - 0.07), statSizeY, 0, 255, 255, 225)

  module.ui.drawText("Acceleration", xoffset - 0.138, yoffset - 0.065)
  module.ui.renderBox(statOffsetX, statSizeX, (yoffset - 0.03), statSizeY, 60, 60, 60, 225)
  module.ui.renderBox(statOffsetX - ((statSizeX - (accelerationStat * 4)) / 2), accelerationStat * 4, (yoffset - 0.03), statSizeY, 0, 255, 255, 225)

  module.ui.drawText("Gears", xoffset - 0.1565, yoffset - 0.025)
  module.ui.drawText(gearStat, xoffset + 0.068, yoffset - 0.025)

  module.ui.drawText("Seating Capacity", xoffset - 0.1275, yoffset + 0.002)
  module.ui.drawText(capacityStat, xoffset + 0.068, yoffset + 0.002)
end
  
module.ui.showAdvancedNotification = function(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)

  if saveToBrief == nil then
    saveToBrief = true
  end

  BeginTextCommandThefeedPost('STRING')
  AddTextComponentSubstringPlayerName(msg)

  if hudColorIndex then
    ThefeedNextPostBackgroundColor(hudColorIndex)
  end

  EndTextCommandThefeedPostMessagetext(textureDict, textureDict, false, iconType, sender, subject)
  EndTextCommandThefeedPostTicker(flash or false, saveToBrief)

end

module.ui.showHelpNotification = function(msg, thisFrame, beep, duration)

  BeginTextCommandDisplayHelp('STRING')
  AddTextComponentSubstringPlayerName(msg)

  if thisFrame then
    DisplayHelpTextThisFrame(msg, false)
  else
    if beep == nil then beep = true end
    BeginTextCommandDisplayHelp('esxHelpNotification')
    EndTextCommandDisplayHelp(0, false, beep, duration or -1)
  end

end

module.ui.howFloatingHelpNotification = function(msg, coords, timeout)

  timeout     = timeout or 5000
  local start = GetGameTimer()

  Citizen.CreateThread(function()

    while (GetGameTimer() - start) < timeout do

      SetFloatingHelpTextWorldPosition(1, coords.x, coords.y, coords.z)
      SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
      BeginTextCommandDisplayHelp('STRING')
      AddTextComponentSubstringPlayerName(msg)
      EndTextCommandDisplayHelp(2, false, true, -1)

      Citizen.Wait(0)

    end

  end)

end

module.math.Trim = function(value)
  if value then
    return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
  else
    return nil
  end
end

module.math.polar3DToWorld3D = function(center, polar, azimuth, radius)

  local polarRad   = polar   * DEG2RAD
  local azimuthRad = azimuth * DEG2RAD

  local sinPolar   = math.sin(polarRad)
  local cosPolar   = math.cos(polarRad)
  local sinAzimuth = math.sin(azimuthRad)
  local cosAzimuth = math.cos(azimuthRad)

  return vector3(
    center.x + radius * (sinAzimuth * cosPolar),
    center.y - radius * (sinAzimuth * sinPolar),
    center.z - radius *  cosAzimuth
  )

end

module.math.world3DtoPolar3D = function(center, position)
  
  local diff   = position - center
  local radius = #(diff)
  local p      = math.atan(diff.y / diff.x)
  local o      = math.atan(math.sqrt(diff.x ^ 2 + diff.y ^ 2) / diff.z)

  local polarDeg   = 180 - p * RAD2DEG % 180
  local azimuthDeg = 180 - o * RAD2DEG % 180

  return polarDeg, azimuthDeg, radius

end

module.math.screen2DToWorld3D = function(x, y, fov, near, far, right, forward, up, at)

  local fovRatio = (360 - fov) / 360
  local sX, sY   = GetActiveScreenResolution()
  local sX2, sY2 = sX/2, sY/2
  local aspect   = sX / sY

  local transformMatrix = Matrix:new({
    {right.x,   right.z,   right.y,   0},
    {forward.x, forward.z, forward.y, 0},
    {up.x,      up.z,      up.y,      0},
    {at.x,      at.z,      at.y,      1},
  })

  local dx = math.tan(fovRatio * 0.5) * (x / sX2 - 1) * aspect
  local dy = math.tan(fovRatio * 0.5) * (1 - y / sY2)

  local p1 = Matrix:new({{dx * near, near, dy * near, 1}})
  local p2 = Matrix:new({{dx * far,  far,  dy * far , 1}})

  p1 = Matrix.mul(p1, transformMatrix)
  p2 = Matrix.mul(p2, transformMatrix)

  _near = vector3(p1[1][1], p1[1][3], p1[1][2])
  _far  = vector3(p2[1][1], p2[1][3], p2[1][2])

  return _near, _far

end

module.math.rotateAround = function(p1, p2, angle)

  p1 = Matrix:new({{p1.x, p1.z, p1.y}})
  p2 = Matrix:new({{p2.x, p2.z, p2.y}})

  local rotationMatrix = Matrix:new({
    {math.cos(angle), -p2[1][1] * math.cos(angle) + p2[1][1] + p2[1][2] * math.sin(angle), -math.sin(angle)},
    {math.sin(angle), -p2[1][1] * math.sin(angle) - p2[1][2] * math.cos(angle) + p2[1][2], math.cos(angle)},
    {              0,                                                                  1,               0}
  })

  local np = Matrix.add(p1, rotationMatrix)

  return vector3(np[1][1], np[1][3], p1[1][2])

end

module.time.timestamp = function()
  return Citizen.InvokeNative(0x9A73240B49945C76)
end
