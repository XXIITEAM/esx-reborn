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

module.Cache = {}

module.getCacheByName = function(cacheName)
  if module.Cache[cacheName] then
    return module.Cache[cacheName]
  else
    return nil
  end
end

-------------------------
--       Garages       --
-------------------------

module.RetrieveOwnedVehicles = function(identifier, id)
  if module.Cache["owned_vehicles"] then
    if not module.Cache["owned_vehicles"][identifier] then
      module.Cache["owned_vehicles"][identifier] = {}
    end

    if not module.Cache["owned_vehicles"][identifier][id] then
      module.Cache["owned_vehicles"][identifier][id] = {}
    end

    local ownedVehicles = {}

    for k,v in pairs(module.Cache["owned_vehicles"][identifier][id]) do
      print(tostring(k) .. " | " .. tostring(v))
      if v["sold"] == 0 then
        table.insert(ownedVehicles, v)
      end
    end

    return ownedVehicles
  else
    return nil
  end
end

module.CheckOwnedVehicle = function(identifier, id, plate)
  if module.Cache["owned_vehicles"][identifier][id][plate] then
    return true
  else
    return false
  end
end

module.GetOwnedVehicle = function(identifier, id, plate)
  if module.Cache["owned_vehicles"][identifier][id][plate] then
    return module.Cache["owned_vehicles"][identifier][id][plate]
  else
    return false
  end
end

module.RetrieveVehicle = function(identifier, id, plate)
  if module.Cache["owned_vehicles"][identifier][id][plate] then
    module.Cache["owned_vehicles"][identifier][id][plate]["stored"] = 0
    return true
  else
    return false
  end
end

module.StoreVehicle = function(identifier, id, plate)
  if module.Cache["owned_vehicles"][identifier][id][plate] then
    module.Cache["owned_vehicles"][identifier][id][plate]["stored"] = 1
    return true
  else
    return false
  end
end

module.UpdateVehicle = function(identifier, id, plate, props)
  if module.Cache["owned_vehicles"][identifier][id][plate] then
    module.Cache["owned_vehicles"][identifier][id][plate]["vehicle"] = props
  end
end

-------------------------
--     Vehicleshop     --
-------------------------

module.BuyVehicle = function(identifier, id, data, plate)
  if module.Cache["owned_vehicles"] then
    if not module.Cache["owned_vehicles"][identifier] then
      module.Cache["owned_vehicles"][identifier] = {}
    end

    if not module.Cache["owned_vehicles"][identifier][id] then
      module.Cache["owned_vehicles"][identifier][id] = {}
    end

    if not module.Cache["owned_vehicles"][identifier][id][plate] then
      module.Cache["owned_vehicles"][identifier][id][plate] = {}
    end

    module.Cache["owned_vehicles"][identifier][id][plate] = data

    return true
  end
end

module.SellVehicle = function(identifier, id, plate)
  if module.Cache["owned_vehicles"][identifier][id][plate] then
    module.Cache["owned_vehicles"][identifier][id][plate]["sold"] = 1

    return true
  else
    return false
  end
end

module.AddUsedPlates = function(cacheName, updateData)
  if module.Cache["usedPlates"] then
    table.insert(module.Cache["usedPlates"], updateData)
  end
end

-------------------------
--        CORE         --
-------------------------

module.StartCache = function()
  if Config.Modules.Cache.BasicCachedTables then
    for _,tab in pairs(Config.Modules.Cache.BasicCachedTables) do
      if tab == "vehicles" then
        exports.ghmattimysql:execute('SELECT * FROM vehicles', {}, function(result)
          if result then
            for i=1,#result,1 do

              if module.Cache["vehicles"] == nil then
                module.Cache["vehicles"] = {}
              end

              if module.Cache["categories"] == nil then
                module.Cache["categories"] = {}
              end

              table.insert(module.Cache["vehicles"], {
                name          = result[i].name,
                model         = result[i].model,
                price         = result[i].price,
                category      = result[i].category,
                categoryLabel = result[i].category_label
              })
            end

            for k,v in pairs(module.Cache["vehicles"]) do
              if #module.Cache["categories"] > 0 then
                for i,j in pairs(module.Cache["categories"]) do
                  if v.category == j.category then
                    module.categoryAlreadyExists = true
                  end
                end

                if module.categoryAlreadyExists then
                  module.categoryAlreadyExists = false
                else
                  table.insert(module.Cache["categories"], {
                    category      = v.category,
                    categoryLabel = v.categoryLabel
                  })
                end
              else
                table.insert(module.Cache["categories"], {
                  category      = v.category,
                  categoryLabel = v.categoryLabel
                })
              end
            end
          end
        end)
      elseif tab == "usedPlates" then
        exports.ghmattimysql:execute('SELECT * FROM owned_vehicles', {}, function(result)
          if result then

            if module.Cache["usedPlates"] == nil then
              module.Cache["usedPlates"] = {}
            end

            for i=1,#result,1 do
              table.insert(module.Cache["usedPlates"], result[i].plate)
            end
          end
        end)
      else
        module.Cache[tab] = {}

        exports.ghmattimysql:execute('SELECT * FROM ' .. tab, {}, function(result)
          for _,data in ipairs(result) do
            local index = #module.Cache[tab]+1
            module.Cache[tab][index] = {}

            for k,v in pairs(data) do
              module.Cache[tab][index][k] = {}

              if type(v) == "string" and v:len() >= 2 and v:find("{") and v:find("}") then
                module.Cache[tab][index][k] = json.decode(v)
              else
                module.Cache[tab][index][k] = v
              end
            end
          end
        end)
      end
    end
  end

  if Config.Modules.Cache.IdentityCachedTables then
    for _,tab in pairs(Config.Modules.Cache.IdentityCachedTables) do
      if tab == "owned_vehicles" then
        module.Cache[tab] = {}

        exports.ghmattimysql:execute('SELECT * FROM ' .. tab, {}, function(result)
          for _,data in ipairs(result) do
            if data.identifier and data.id then
              if not module.Cache[tab][data.identifier] then
                module.Cache[tab][data.identifier] = {}
              end

              if not module.Cache[tab][data.identifier][data.id] then
                module.Cache[tab][data.identifier][data.id] = {}
              end
              for k,v in pairs(data) do
                if not module.Cache[tab][data.identifier][data.id][data.plate] then
                  module.Cache[tab][data.identifier][data.id][data.plate] = {}
                end

                if not module.Cache[tab][data.identifier][data.id][data.plate][k] then
                  module.Cache[tab][data.identifier][data.id][data.plate][k] = {}

                  if type(v) == "string" and v:len() >= 2 and v:find("{") and v:find("}") then
                    if Config.Modules.Cache.EnableDebugging then
                      if k == "plate" then
                        print("module.Cache["..tostring(tab).."]["..tostring(data.identifier).."]["..tostring(data.id).."]["..data.plate.."]["..tostring(k).."] = "..tostring(v))
                      end
                    end
                    module.Cache[tab][data.identifier][data.id][data.plate][k] = json.decode(v)
                  else
                    if Config.Modules.Cache.EnableDebugging then
                      if k == "plate" then
                        print("module.Cache["..tostring(tab).."]["..tostring(data.identifier).."]["..tostring(data.id).."]["..data.plate.."]["..tostring(k).."] = "..tostring(v))
                      end
                    end
                    module.Cache[tab][data.identifier][data.id][data.plate][k] = v
                  end
                end
              end
            end
          end
        end)
      else
        module.Cache[tab] = {}

        exports.ghmattimysql:execute('SELECT * FROM ' .. tab, {}, function(result)
          local index = 0

          for _,data in ipairs(result) do
            index = index + 1

            if data.identifier and data.id then
              if not module.Cache[tab][data.identifier] then
                module.Cache[tab][data.identifier] = {}
              end

              if not module.Cache[tab][data.identifier][data.id] then
                module.Cache[tab][data.identifier][data.id] = {}
              end

              if not module.Cache[tab][data.identifier][data.id][index] then
                module.Cache[tab][data.identifier][data.id][index] = {}
              end

              for k,v in pairs(data) do
                if not module.Cache[tab][data.identifier][data.id][index][k] then
                  module.Cache[tab][data.identifier][data.id][index][k] = {}

                  if type(v) == "string" and v:len() >= 2 and v:find("{") and v:find("}") then
                    if Config.Modules.Cache.EnableDebugging then
                      print("module.Cache["..tostring(tab).."]["..tostring(data.identifier).."]["..tostring(data.id).."]["..tostring(index).."]["..tostring(k).."] = "..tostring(v))
                    end

                    module.Cache[tab][data.identifier][data.id][index][k] = json.decode(v)
                  else
                    if Config.Modules.Cache.EnableDebugging then
                      print("module.Cache["..tostring(tab).."]["..tostring(data.identifier).."]["..tostring(data.id).."]["..tostring(index).."]["..tostring(k).."] = "..tostring(v))
                    end

                    module.Cache[tab][data.identifier][data.id][index][k] = v
                  end
                end
              end
            end
          end
        end)
      end
    end
  end
end

module.SaveCache = function()
  print("^2saving cache...^7")

  if Config.Modules.Cache.IdentityCachedTables then
    for _,tab in pairs(Config.Modules.Cache.IdentityCachedTables) do
      if tab == "owned_vehicles" then
        if module.Cache[tab] then
          for k,_ in pairs(module.Cache[tab]) do
            for k2,_ in pairs(module.Cache[tab][k]) do
              for _,data in pairs(module.Cache[tab][k][k2]) do

                local plate = tostring(data["plate"])

                exports.ghmattimysql:execute('SELECT plate FROM owned_vehicles WHERE plate = @plate', {
                  ['@plate'] = plate
                }, function(result)
                  if result[1] then
                    if Config.Modules.Cache.EnableDebugging then
                      print("updating owned vehicles with the plates: ^2" .. tostring(data["plate"]) .. "^7")
                      print("UPDATE owned_vehicles SET id = "..data["id"]..", identifier = "..data["identifier"]..", vehicle = "..tostring(data["vehicle"])..", stored = "..data["stored"]..", sold = "..data["sold"].." WHERE plate = "..data["plate"])
                    end

                    exports.ghmattimysql:execute('UPDATE owned_vehicles SET id = @id, identifier = @identifier, vehicle = @vehicle, stored = @stored, sold = @sold WHERE plate = @plate', {
                      ['@id']         = tonumber(data["id"]),
                      ['@identifier'] = tostring(data["identifier"]),
                      ['@vehicle']    = json.encode(data["vehicle"]),
                      ['@stored']     = tonumber(data["stored"]),
                      ['@sold']       = tonumber(data["sold"]),
                      ['@plate']      = tostring(data["plate"])
                    })
                  else
                    if Config.Modules.Cache.EnableDebugging then
                      print("inserting owned vehicles with the plates: ^2" .. tostring(data["plate"]) .. "^7")
                      print("INSERT INTO owned_vehicles (id, identifier, plate, model, sell_price, vehicle, stored, sold) VALUES ("..data["id"]..", "..data["identifier"]..", "..data["plate"]..", "..data["model"]..", "..data["sell_price"]..", "..tostring(data["vehicle"])..", "..data["stored"]..", "..data["sold"])
                    end

                    exports.ghmattimysql:execute('INSERT INTO owned_vehicles (id, identifier, plate, model, sell_price, vehicle, stored, sold) VALUES (@id, @identifier, @plate, @model, @sell_price, @vehicle, @stored, @sold)', {
                      ['@id']         = tonumber(data["id"]),
                      ['@identifier'] = tostring(data["identifier"]),
                      ['@plate']      = tostring(data["plate"]),
                      ['@model']      = tostring(data["model"]),
                      ['@sell_price'] = tonumber(data["sell_price"]),
                      ['@vehicle']    = json.encode(data["vehicle"]),
                      ['@stored']     = tonumber(data["stored"]),
                      ['@sold']       = tonumber(data["sold"])
                    })
                  end
                end)
              end
            end
          end
        end
      end
    end
  end
end
