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

module.Ready      = false
module.Imported   = false
module.Cache      = {}
module.UsedPlates = {}

------------------------------------------------------------------------
----------                                                    ----------
--                                INIT                                --
----------                                                    ----------
------------------------------------------------------------------------

module.Init = function()
  exports.ghmattimysql:execute('SELECT * FROM vehicles', {}, function(result)
    if result then
      for i=1,#result,1 do

        if not module.Cache[result[i].category] then
          module.Cache[result[i].category] = {}
        end

        table.insert(module.Cache[result[i].category], {
          name          = result[i].name,
          make          = result[i].make,
          model         = result[i].model,
          price         = result[i].price,
          category      = result[i].category,
          categoryLabel = result[i].category_label,
          fuelType      = result[i].fuel_type
        })
      end
    end
  end)

  module.Imported = true

  exports.ghmattimysql:execute('SELECT * FROM owned_vehicles', {}, function(result)
    if result then
      for i=1, #result, 1 do
        table.insert(module.UsedPlates, result[i].plate)
      end
    end
  end)
end

module.GetVehicles = function()
  return module.Cache
end

module.GetUsedPlates = function()
  return module.UsedPlates
end

module.AddUsedPlates = function(plate)
  table.insert(module.UsedPlates, plate)
end