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

M('command')

module.Config = run('data/config.lua', {vector3 = vector3})['Config']

local lifeCommand = Command("life", "user", "Send a message as a tweet")
lifeCommand:addArgument("message", "string", "The message you want to send", true)

lifeCommand:setHandler(function(player, args, baseArgs)
  local msg = module.toString(baseArgs)

  local name = player:getName()

  emitClient('rpchat:sendLifeInvaderMessage', -1, player.source, msg, name)
end)

local meCommand = Command("me", "user", "Send a message as a personal action")
meCommand:addArgument("message", "string", "The message you want to send", true)

meCommand:setHandler(function(player, args, baseArgs)

  local msg = module.toString(baseArgs)

  local identity  = Player.fromId(player.source):getIdentity()
  local firstname = identity:getFirstName()
  local lastname  = identity:getLastName()

  if msg and player.source then

    if module.Config.OverHeadMode then
      emitClient('rpchat:3DTextOverhead', -1, player.source, '~p~*~w~'..msg..'~p~*')
    else
      emitClient('rpchat:proximitySendNUIMessage', -1, player.source, {args = {'ME ['..player.source..'] '.. firstname .. ' ' .. lastname, msg}, color = {170, 102, 204}})
    end
  end
end)

local doCommand = Command("do", "user", "Send facts or acction response")
doCommand:addArgument("message", "string", "The message you want to send", true)

doCommand:setHandler(function(player, args, baseArgs)

  local msg = module.toString(baseArgs)

  local identity  = Player.fromId(player.source):getIdentity()
  local firstname = identity:getFirstName()
  local lastname  = identity:getLastName()

  if msg and player.source then

    if module.Config.OverHeadMode then
      emitClient('rpchat:3DTextOverhead', -1, player.source, '~o~*~w~'..msg..'~o~*')
    else
      emitClient('rpchat:proximitySendNUIMessage', -1, player.source, {args = {'DO ['..player.source..'] ' .. firstname .. ' ' .. lastname, msg}, color = {220, 120, 0}})
    end

  end
end)

local oocCommand = Command("ooc", "user", "Send a OOC message in proximity")
oocCommand:addArgument("message", "string", "The message you want to send", true)

oocCommand:setHandler(function(player, args, baseArgs)
  if not module.Config.DisableChat then
    local message = module.toString(baseArgs)

    local identity = Player.fromId(player.source)

    if player then
      local playerData = identity:getIdentity()
      local firstname  = playerData:getFirstName()
      local lastname   = playerData:getLastName()
      local arg        = nil

      if firstname and lastname then
        arg = {args = {'OOC | ' .. player.source .. ' | ' ..  firstname .. ' ' .. lastname, message}, color = {0, 255, 255}}
      else
        arg = {args = {'OOC | ' .. player.source, message}, color = {0, 255, 255}}
      end

      if module.Config.ProximityMode then
        emitClient('rpchat:proximitySendNUIMessage', -1, player.source, arg)
      else
        emitClient('chat:addMessage', -1, arg)
      end
    end
  end
end)

local goocCommand = Command("gooc", "user", "Send a message across global OOC")
goocCommand:addArgument("message", "string", "The message you want to send", true)

goocCommand:setHandler(function(player, args, baseArgs)
  if not module.Config.DisableChat then
    local message = module.toString(baseArgs)

    local identity = Player.fromId(player.source)

    if player then
      local playerData = identity:getIdentity()
      local firstname  = playerData:getFirstName()
      local lastname   = playerData:getLastName()
      local arg        = nil

      if firstname and lastname then
        arg = {args = {'GOOC | ' .. player.source .. ' | ' ..  firstname .. ' ' .. lastname, message}, color = {255, 165, 0}}
      else
        arg = {args = {'GOOC | ' .. player.source, message}, color = {255, 165, 0}}
      end

      emitClient('chat:addMessage', -1, arg)
    end
  end
end)

lifeCommand:register()

meCommand:register()

doCommand:register()

oocCommand:register()

goocCommand:register()
