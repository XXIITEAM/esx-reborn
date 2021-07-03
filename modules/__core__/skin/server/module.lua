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

module.SaveSkin = function(player, skin, cb)
  -- TODO: use ORM to prepare de query
  exports.ghmattimysql:execute('UPDATE identities SET skin = @skin WHERE id = @identityId',
  {
    ['@skin'] = json.encode(skin),
    ['@identityId'] = player:getIdentityId()
  }, function(affectedRows)
    if (cb) then
      cb(skin)
    end
  end)
end

module.GetSkin = function(player, cb)
  -- TODO: use ORM to prepare de query
  exports.ghmattimysql:scalar('SELECT skin FROM identities WHERE id = @identityId',
  {
    ['@identityId'] = player:getIdentityId()
  }, function(skin)

    if (skin) then
      return cb(json.decode(skin))
    end

    return cb(nil)
  end)
end
