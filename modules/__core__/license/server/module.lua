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

M('class')
M('events')

-------------------------------------------------------------------------
--- Licenses
-------------------------------------------------------------------------

Licenses = Extends(EventEmitter, 'Licenses')

function Licenses:constructor(data, playerId)

  self.super:ctor()

  self.licenses = {}

  for k,v in pairs(data) do
    self.licenses[k] = License(v)
  end

  self:on('license.add', function(licenseName)
    emitClient('esx:license:addedLicense', playerId, licenseName)
  end)

  self:on('license.revoked', function(licenseName)
    emitClient('esx:license:revokedLicense', playerId, licenseName)
  end)

  self:on('license.removed', function(licenseName)
    emitClient('esx:license:removedLicense', playerId, licenseName)
  end)

  self:on('license.validated', function(licenseName)
    emitClient('esx:license:validatedLicense', playerId, licenseName)
  end)

end

function Licenses:hasLicense(name)
  return self.licenses[name] ~= nil
end

function Licenses:addLicense(name)

  if not self:hasLicense(name) then
    self.licenses[name] = License()
    self:emit('license.add', name)
    return true
  end

  return false

end

function Licenses:removeLicense(name)

  if self.licenses[name] then
    self.licenses[name] = nil
    self:emit('license.removed', name)
    return true
  end

 return false

end

function Licenses:revokeLicense(name)

  if self.licenses[name] and self.licenses[name].status ~= module.LicenseStatus.REVOKED then
    self.licenses[name]:revoke()
    self:emit('license.revoked', name)
    return true
  end

 return false

end

function Licenses:validateLicense(name)

  if self.licenses[name] and self.licenses[name].status ~= module.LicenseStatus.VALID then
    self.licenses[name]:validate()
    self:emit('license.validated', name)
    return true
  end

 return false

end

function Licenses:isValid(name)

  if self.licenses[name] then
    return self.licenses[name]:isValid()
  end

 return false

end

function Licenses:getLicense(name)

  if self.licenses[name] == nil then
    return nil
  end

  local license = {}
  license.type = name
  license.valid = self.licenses[name].valid

 return license

end

function Licenses:serialize()

  local data = {}

  for k,v in pairs(self.licenses) do
    data[k] = v:serialize()
  end

  return data

end

-------------------------------------------------------------------------
--- Individual License
-------------------------------------------------------------------------

License = Extends(nil, 'License')

function License:constructor(data)

  self.status = data and data.status or module.LicenseStatus.VALID

end

License.all = setmetatable({}, {
  __index    = function(t, k) return rawget(t, tostring(k)) end,
  __newindex = function(t, k, v) rawset(t, tostring(k), v) end,
})

function License:isValid()

  return self.status == module.LicenseStatus.VALID

end

function License:validate()

  self.status = module.LicenseStatus.VALID

end

function License:revoke()

  self.status = module.LicenseStatus.REVOKED

end

function License:serialize()

  local data = {}
  data.status = self.status

  return data

end

-------------------------------------------------------------------------
--- License Status ENUM
-------------------------------------------------------------------------

module.LicenseStatus = {
  REVOKED     = 0,
  VALID       = 1
}
