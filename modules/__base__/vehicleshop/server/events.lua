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
--                                IMPORTS                             --
----------                                                    ----------
------------------------------------------------------------------------

-- local Command  = M("events")
-- local Cache    = M("cache")
local utils    = M("utils")
local Vehicles = M("vehicles")

------------------------------------------------------------------------
----------                                                    ----------
--                               VARIABLES                            --
----------                                                    ----------
------------------------------------------------------------------------

module.Config = run('data/config.lua', {vector3 = vector3})['Config']

------------------------------------------------------------------------
----------                                                    ----------
--                               REQUESTS                             --
----------                                                    ----------
------------------------------------------------------------------------

onRequest("vehicleshop:isAnyoneInShopMenu", function(source, cb)
  if module.ShopInUse then
    cb(true)
  else
    module.Updated   = true
    module.ShopInUse = true
    cb(nil)
  end
end)

onClient('vehicleshop:updateVehicle', function(plate, vehicleProps)
  exports.ghmattimysql:execute('UPDATE owned_vehicles SET vehicle = @vehicle WHERE plate = @plate', {
    ['@plate'] = plate,
    ['@vehicle'] = json.encode(vehicleProps)
  })
end)

onRequest("vehicleshop:sellVehicle", function(source, cb, plate)
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

onRequest("vehicleshop:spawnVehicle", function(source, cb, model)
  if model and type(model) == 'string' then
    utils.game.createVehicle(model, module.Config.ShopOutside.Pos, module.Config.ShopOutside.Heading, function(vehicle)
      while not DoesEntityExist(vehicle) do
        Wait(10)
      end

      local vehicleID = NetworkGetNetworkIdFromEntity(vehicle)

      cb(vehicleID)
    end)
  else
    cb(false)
  end
end)

onRequest("vehicleshop:isPlateTaken", function(source, cb, plate, plateUseSpace, plateLetters, plateNumbers)
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

onRequest("vehicleshop:buyVehicle", function(source, cb, cat, value, plate, name)
  local player = Player.fromId(source)
  local playerData = player:getIdentity()
  local vehicles = Vehicles.GetVehicles()

  if vehicles then
    local price = vehicles[cat][value].price
    local formattedPrice = module.GroupDigits(price)
    local resellPrice = math.round(price / 100 * module.Config.ResellPercentage)
    local model = vehicles[cat][value].model

    exports.ghmattimysql:execute('INSERT INTO `owned_vehicles` (id, identifier, plate, model, sell_price) VALUES (@id, @identifier, @plate, @model, @sell_price)', {
      ['@id']         = player:getIdentityId(),
      ['@identifier'] = player.identifier,
      ['@plate']      = plate,
      ['@model']      = model,
      ['@sell_price'] = resellPrice,
    }, function(rowsChanged)
      if rowsChanged.affectedRows > 0 then
        Vehicles.AddUsedPlates(plate)
        print(_U('vehicleshop:server_buy_success', player:getIdentityId(), playerData:getFirstName(), playerData:getLastName(), name, plate, tostring(formattedPrice)))

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

------------------------------------------------------------------------
----------                                                    ----------
--                               EVENTS                               --
----------                                                    ----------
------------------------------------------------------------------------

onClient('vehicleshop:stillUsingMenu', function()
  module.Updated = true
end)

onClient('vehicleshop:exitedMenu', function()
  module.Updated   = false
  module.ShopInUse = false
end)