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
--                              VARIABLES                             --
----------                                                    ----------
------------------------------------------------------------------------

module.Ready         = false
module.Imported      = false
module.Vehicles      = {}
module.UsedPlates    = {}
module.OwnedVehicles = {}

------------------------------------------------------------------------
----------                                                    ----------
--                                INIT                                --
----------                                                    ----------
------------------------------------------------------------------------

module.Init = function()
  exports.ghmattimysql:execute('SELECT * FROM vehicles', {}, function(result)
    if result then
      for i=1,#result,1 do

        if not module.Vehicles[result[i].category] then
          module.Vehicles[result[i].category] = {}
        end

        table.insert(module.Vehicles[result[i].category], {
          ["name"]          = result[i].name,
          ["make"]          = result[i].make,
          ["model"]         = result[i].model,
          ["price"]         = result[i].price,
          ["category"]      = result[i].category,
          ["categoryLabel"] = result[i].category_label,
          ["fuelType"]      = result[i].fuel_type
        })
      end
    end
  end)

  exports.ghmattimysql:execute('SELECT * FROM owned_vehicles', {}, function(result)
    if result then
      for i=1, #result, 1 do
        if not module.OwnedVehicles[result[i].id] then
          module.OwnedVehicles[result[i].id] = {}
        end

        module.OwnedVehicles[result[i].id][result[i].plate] = {
          ["id"]           = result[i].id,
          ["plate"]        = result[i].plate,
          ["model"]        = result[i].model,
          ["vehicle"]      = json.decode(result[i].vehicle),
          ["fuelType"]     = result[i].fuel_type,
          ["stored"]       = 1,
          ["garage"]       = result[i].garage,
          ["category"]     = result[i].category,
          ["name"]         = result[i].name,
          ["containerID"]  = result[i].container_id
        }
      end
    end
  end)

  module.Imported = true

  exports.ghmattimysql:execute('UPDATE owned_vehicles SET stored = @stored WHERE sold = @sold', {
    ['@stored'] = 1,
    ['@sold'] = 0
  }, function()
    print(_U('vehicles_all_stored'))
  end)
end

module.GetVehicles = function()
  return module.Vehicles
end

module.GetOwnedVehicles = function(id)
  if id then
    return module.OwnedVehicles[id]
  else
    return module.OwnedVehicles
  end
end

module.GetOwnedVehicle = function(id, plate)
  return module.OwnedVehicles[id][plate]
end

module.UpdateVehicle = function(id, plate, field, value)
  local count = 0
  
  while not module.OwnedVehicles[id][plate] and count < 1000 do
    Wait(10)
    count = count + 1
  end

  if module.OwnedVehicles[id][plate] then
    if module.OwnedVehicles[id][plate][field] then
      module.OwnedVehicles[id][plate][field] = value
      return true
    end

    return false
  else
    return false
  end

  return false
end

module.RemoveOwnedVehicle = function(id, plate)
  if module.OwnedVehicles[id][plate] then
    module.OwnedVehicles[id][plate] = nil
    return true
  end

  return false
end

module.AddOwnedVehicle = function(id, plate, data)
  if module.OwnedVehicles[id] then
    if not module.OwnedVehicles[id][plate] then
      module.OwnedVehicles[id][plate] = {}
    end

    module.OwnedVehicles[id][plate] = data
    return true
  end

  return false
end

module.isPlateTaken = function(plate)
  local usedPlates = module.OwnedVehicles

  for k,_ in pairs(usedPlates) do
    if usedPlates[k][plate] then
      return true
    end
  end

  return false
end

module.ExcessPlateLength = function(plate, plateUseSpace, plateLetters, plateNumbers)
  local checkedPlate = tostring(plate)
  local plateLength = string.len(checkedPlate)

  if plateLength > 8 then
      print("^1Generated plate is more than 8 characters. FiveM does not support this.^7")
      return true
  else
      return false
  end
end

module.GroupDigits = function(value)
local left,num,right = string.match(value,'^([^%d]*%d)(%d*)(.-)$')

return left..(num:reverse():gsub('(%d%d%d)','%1' .. ","):reverse())..right
end