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

local Command  = M("events")
local Cache    = M("cache")
local utils    = M("utils")

module.Config = run('data/config.lua', {vector3 = vector3})['Config']

onClient('vehicleshop:updateVehicle', function(plate, vehicleProps)
  local player = Player.fromId(source)

  if player and plate and vehicleProps then
    Cache.UpdateVehicle(player.identifier, player:getIdentityId(), plate, vehicleProps)
  end
end)

onRequest("vehicleshop:checkOwnedVehicle", function(source, cb, plate)
  local player = Player.fromId(source)

  if player then
    local ownedVehicle = Cache.GetOwnedVehicle(player.identifier, player:getIdentityId(), plate)

    if ownedVehicle then
      if ownedVehicle.model and ownedVehicle.sell_price then
        local vehicleData = {
          model = ownedVehicle.model,
          resellPrice = ownedVehicle.sell_price
        }

        cb(vehicleData)
      else
        cb(false)
      end
    else
      cb(false)
    end
  else
    cb(false)
  end
end)

onRequest("vehicleshop:buyVehicle", function(source, cb, model, plate, price, formattedPrice, vehicleName, name, resellPrice)
  local player = Player.fromId(source)

  if player then
    local data = {
      identifier   = player.identifier,
      id           = player:getIdentityId(),
      plate        = plate,
      model        = model,
      sell_price   = resellPrice,
      sold         = 0,
      stored       = 0,
      vehicle      = {model = GetHashKey(model), plate = plate},
      container_id = nil
    }

    local buyVehicle = Cache.BuyVehicle(player.identifier, player:getIdentityId(), data, plate)
    if buyVehicle then
      local playerData = player:getIdentity()

      Cache.AddUsedPlates("usedPlates", plate)
      print(_U('vehicleshop:server_buy_success', player:getIdentityId(), playerData:getFirstName(), playerData:getLastName(), name, plate, tostring(formattedPrice)))

      utils.game.createVehicle(model, module.Config.ShopOutside.Pos, module.Config.ShopOutside.Heading, function(vehicle)
        while not DoesEntityExist(vehicle) do
          Wait(10)
        end

        local vehicleID = NetworkGetNetworkIdFromEntity(vehicle)

        SetVehicleNumberPlateText(vehicle, plate)
        cb(vehicleID)
      end)
    else
      print(_U('vehicleshop:server_buy_failure'))
      cb(false)
    end
  else
    cb(false)
  end
end)

onRequest("vehicleshop:isAnyoneInShopMenu", function(source, cb)
  if module.ShopInUse then
    cb(true)
  else
    module.Updated   = true
    module.ShopInUse = true
    cb(nil)
  end
end)

onClient('vehicleshop:stillUsingMenu', function()
  module.Updated = true
end)

onClient('vehicleshop:exitedMenu', function()
  module.Updated   = false
  module.ShopInUse = false
end)

onRequest("vehicleshop:startTestDrive", function(source, cb, model)
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

onRequest("vehicleshop:sellVehicle", function(source, cb, plate, name, resellPrice, formattedPrice)
  local player = Player.fromId(source)

  if player then
    if Cache.SellVehicle(player.identifier, player:getIdentityId(), plate) then
      local playerData = player:getIdentity()
      print(_U('vehicleshop:server_sell_success', player:getIdentityId(), playerData:getFirstName(), playerData:getLastName(), name, plate, module.GroupDigits(resellPrice)))
      cb(true)
    else
      print(_U('vehicleshop:server_sell_failure'))
      cb(false)
    end
  else
    cb(false)
  end
end)

onRequest("vehicleshop:isPlateTaken", function(source, cb, plate, plateUseSpace, plateLetters, plateNumbers)
  if module.isPlateTaken(plate) then
    cb(true)
  else
    if module.excessPlateLength(plate, plateUseSpace, plateLetters, plateNumbers) then
      cb(true)
    else
      cb(false)
    end
  end
end)

onRequest("vehicleshop:getCategories", function(source, cb)
  module.Cache.categories = Cache.getCacheByName("categories")

  if module.Cache.categories then
    cb(module.Cache.categories)
  else
    cb(nil)
  end
end)

onRequest("vehicleshop:getVehicles", function(source, cb)
  module.Cache.vehicles = Cache.getCacheByName("vehicles")

  if module.Cache.vehicles then
    cb(module.Cache.vehicles)
  else
    cb(nil)
  end
end)
