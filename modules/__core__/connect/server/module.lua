M('persistent')

-- print(json.encode(Config.Modules))

Ban, BanBase = Persist('bans', 'id')

Ban.define({
  {name = 'id',         field = {name = 'id',          type = 'INT',        length = nil, default = nil,    extra = 'NOT NULL AUTO_INCREMENT'}},
  {name = 'identifier', field = {name = 'identifier',  type = 'VARCHAR',    length = 64,  default = nil,    extra = 'NOT NULL'}},
  {name = 'reason',     field = {name = 'reason',      type = 'VARCHAR',    length = 5000, default = nil,    extra = 'NOT NULL'}}
})

Whitelist, WhitelistBase = Persist('whitelists', 'id')

Whitelist.define({
  {name = 'id',         field = {name = 'id',          type = 'INT',        length = nil, default = nil,    extra = 'NOT NULL AUTO_INCREMENT'}},
  {name = 'identifier', field = {name = 'identifier',  type = 'VARCHAR',    length = 64,  default = nil,    extra = 'NOT NULL'}},
})

module.onPlayerConnecting = function(playerName, setKickReason, deferrals, source)
  deferrals.defer()
  -- get the license identifier
  local identifiers = GetPlayerIdentifiers(source)
  local identifier  = nil

  for i=1, #identifiers, 1 do

    local current = identifiers[i]

    if current:match('license:') then
      identifier = current:sub(9)
      break
    end

  end

  -- stop here if there is no license identifier
  if identifier == nil then
    return setKickReason("We cannot find your license identifier, try to restart FiveM.")
  end

  if Config.Modules.connect.enableWhitelist then
    -- make a whitelist check based on the player identifier
    Whitelist.findOne({
      identifier = identifier
    }, function(result)
      if result == nil then
        return deferrals.done(Config.Modules.connect.notWhitelistedMessage)
      end

      -- make a ban check based on the player identifier
      module.BanGuard(identifier, deferrals, function()
        -- if the end-user enabled the connect queue feature, add the player to the queue
        if Config.Modules.connect.enableConnectQueue then
          module.onPlayerEnterInQueue(playerName, deferrals, source, identifier)
        else
          deferrals.done()
        end
      end)
    end)
  else
    -- make a ban check based on the player identifier
    module.BanGuard(identifier, deferrals, function()
      -- if the end-user enabled the connect queue feature, add the player to the queue
      if Config.Modules.connect.enableConnectQueue then
        module.onPlayerEnterInQueue(playerName, deferrals, source, identifier)
      else
        deferrals.done()
      end
    end)
  end
end

-- execute successCb if the player isn't banned
-- else it will kick them with the ban reason
module.BanGuard = function(identifier, deferrals, successCb)
  Ban.findOne({
    identifier = identifier
  }, function(result)
    if result ~= nil then
      return deferrals.done(result.reason)
    end
    successCb()
  end)
end

module.onPlayerEnterInQueue = function(playerName, deferrals, source, identifier)
  deferrals.done()
end