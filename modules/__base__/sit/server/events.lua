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

onClient('sit:takePlace', function(objectCoords)
  module.SeatsTaken[objectCoords] = true
end)

onClient('sit:leavePlace', function(objectCoords)
  if module.SeatsTaken[objectCoords] then
    module.SeatsTaken[objectCoords] = nil
  end
end)

onRequest('sit:getPlace', function(source, cb, objectCoords)
  cb(module.SeatsTaken[objectCoords])
end)
