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

------------------------------------------------------------------------
----------                                                    ----------
--                              IMPORTS                               --
----------                                                    ----------
------------------------------------------------------------------------

local Command = M("events")
local migrate = M('migrate')

------------------------------------------------------------------------
----------                                                    ----------
--                             MIGRATION                              --
----------                                                    ----------
------------------------------------------------------------------------

on("esx:db:ready", function()
  migrate.Ensure("vehicles", "core")
end)

on('esx:ready', function()
  module.Ready = true
  module.Init()
end)

------------------------------------------------------------------------
----------                                                    ----------
--                             REQUESTS                               --
----------                                                    ----------
------------------------------------------------------------------------

onRequest("vehicles:getVehicles", function(source, cb)
  while not module.Ready do
    Wait(100)
  end

  while not module.Imported do
    Wait(100)
  end

  cb(module.Vehicles)
end)

onRequest("vehicles:getOwnedVehicles", function(source, cb)
  while not module.Ready do
    Wait(100)
  end

  while not module.Imported do
    Wait(100)
  end

  local player = Player.fromId(source)
  local identityId = player:getIdentityId()

  if module.OwnedVehicles[identityId] then
    cb(module.OwnedVehicles[identityId])
  else
    cb(nil)
  end
end)


onRequest('vehicles:storeVehicleInGarage', function(source, cb, plate, garage)
  local player = Player.fromId(source)

  exports.ghmattimysql:execute('UPDATE owned_vehicles SET stored = @stored, garage = @garage WHERE plate = @plate', {
    ['@plate'] = plate,
    ['@stored'] = 1,
    ['@garage'] = garage
  }, function(rowsChanged)
    local storeVehicle   = module.UpdateVehicle(player:getIdentityId(), plate, "stored", 1)
    local garageLocation = module.UpdateVehicle(player:getIdentityId(), plate, "garage", garage)

    if storeVehicle and garageLocation then
      cb(true)
    else
      cb(false)
    end
  end)
end)

onRequest('vehicles:removeVehicleFromGarage', function(source, cb, plate)
  local player = Player.fromId(source)

  print("Updating for: " .. tostring(player:getIdentityId()) .. " | " .. plate)

  exports.ghmattimysql:execute('UPDATE owned_vehicles SET stored = @stored WHERE plate = @plate', {
    ['@plate'] = plate,
    ['@stored'] = 0
  }, function(rowsChanged)
      local removeVehicle = module.UpdateVehicle(player:getIdentityId(), plate, "stored", 0)
      if removeVehicle then
        cb(true)
      else
        cb(false)
      end
  end)
end)

onRequest("vehicles:buyVehicle", function(source, cb, cat, value, plate, name, vehicle)
  local player = Player.fromId(source)
  local playerData = player:getIdentity()
  local vehicles = module.Vehicles
  local category = tostring(cat)

  if vehicles then
    local price = vehicles[cat][value].price
    local formattedPrice = module.GroupDigits(price)
    local resellPrice = math.round(price / 100 * Config.Modules.Vehicles.ResellPercentage)
    local model = vehicles[cat][value].model

    exports.ghmattimysql:execute('INSERT INTO `owned_vehicles` (id, identifier, plate, model, sell_price, fuel_type, category, name) VALUES (@id, @identifier, @plate, @model, @sell_price, @fuel_type, @category, @name)', {
      ['@id']         = player:getIdentityId(),
      ['@identifier'] = player.identifier,
      ['@plate']      = plate,
      ['@model']      = model,
      ['@sell_price'] = resellPrice,
      ['@fuel_type']  = vehicle.fuelType,
      ['@category']   = category,
      ['@name']       = name
    }, function(rowsChanged)
      if rowsChanged.affectedRows > 0 then
        local data = {
          id = player:getIdentityId(),
          identifier = player.identifier,
          plate = plate,
          model = model,
          sell_price = resellPrice,
          stored = 0,
          sold = 0,
          category = category,
          garage = "public",
          vehicle = {}
        }

        module.AddOwnedVehicle(player:getIdentityId(), plate, data)

        print(_U('vehicle_buy_success', player:getIdentityId(), playerData:getFirstName(), playerData:getLastName(), name, plate, tostring(formattedPrice)))

        local callbackData = {
          name = name,
          plate = plate,
          price = formattedPrice
        }

        cb(callbackData)
      end
    end)
  end
end)

onRequest("vehicles:isPlateTaken", function(source, cb, plate, plateUseSpace, plateLetters, plateNumbers)
  local player = Player.fromId(source)

  if module.isPlateTaken(plate) then
    cb(true)
  else
    if module.ExcessPlateLength(plate, plateUseSpace, plateLetters, plateNumbers) then
      cb(true)
    else
      cb(false)
    end
  end
end)

onClient('vehicles:updateVehicleProps', function(plate, vehicleProps)
  local player = Player.fromId(source)

  exports.ghmattimysql:execute('UPDATE owned_vehicles SET vehicle = @vehicle WHERE plate = @plate', {
    ['@plate'] = plate,
    ['@vehicle'] = json.encode(vehicleProps)
  })
  
  module.UpdateVehicle(player:getIdentityId(), plate, "vehicle", vehicleProps)
end)

onRequest("vehicles:sellVehicle", function(source, cb, plate)
  local player = Player.fromId(source)
  local callbackData = {}

  if player then
    exports.ghmattimysql:execute('SELECT * FROM owned_vehicles WHERE plate = @plate', {
      ['@identifier'] = player.identifier,
      ['@plate'] = plate
    }, function(result)
      if result then
        if result[1].id == player:getIdentityId() and result[1].identifier == player.identifier then
          callbackData = {
            resellPrice = module.GroupDigits(result[1].sell_price),
            plate = plate
          }

          exports.ghmattimysql:execute('DELETE FROM owned_vehicles WHERE plate = @plate', {
            ['@plate'] = plate
          }, function(rowsChanged)
            cb(callbackData)
          end)
        else
          cb(false)
        end
      else
        cb(false)
      end
    end)
  else
    cb(false)
  end
end)