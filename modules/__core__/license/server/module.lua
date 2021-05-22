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

M('class')
M('events')

License = Extends(EventEmitter, 'License')

function License:constructor(data, playerId)

  self.super:ctor()

  self.licenses = data

  self:on('license.add', function(licenseName)
    emitClient('esx:license:addedLicense', playerId, licenseName)
  end)

  self:on('license.remove', function(licenseName)
    emitClient('esx:license:removedLicense', playerId, licenseName)
  end)

end

function License:hasLicense(name)
  return table.indexOf(self.licenses, name) ~= -1
end

function License:addLicense(name)

  if not self:hasLicense(name) then
    self.licenses[#self.licenses + 1] = name
    self:emit('license.add', name)
    return true
  end

  return false

end

function License:removeLicense(name)

  local newLicenses = {}
  local found    = false

  for i=1, #self.licenses, 1 do

    local license = self.licenses[i]

    if license == name then
      found = true
    else
      newLicenses[#newLicenses + 1] = license
    end

  end

  self.licenses = newLicenses

  if found then
    self:emit('license.remove', name)
  end

  return found

end


function License:serialize()

  return self.licenses

end

