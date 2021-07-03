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

onRequest("garages:isAnyoneInGarageMenu", function(source, cb, location)
  if module.GarageInUse[location] then
    cb(true)
  else
    module.Updated[location]     = true
    module.GarageInUse[location] = true
    cb(nil)
  end
end)

onClient('garages:stillUsingMenu', function(location)
  module.Updated[location] = true
end)

onClient('garages:exitedMenu', function(location)
  -- module.Updated[location]     = false
  -- module.GarageInUse[location] = false
end)
