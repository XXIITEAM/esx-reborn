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

ESX.SetInterval(10000, function()
  if module.Ready then
    for k,v in pairs(module.Updated) do
      if v then
        if not module.Updated[k] then
          module.Updated[k] = false
        end

        module.Updated[k] = false
      else
        if not module.GarageInUse[k] then
          module.GarageInUse[k] = false
        end

        module.GarageInUse[k] = false
      end
    end
  end
end)
