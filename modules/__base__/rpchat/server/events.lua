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

module.Config = run('data/config.lua', {vector3 = vector3})['Config']

onClient('chatMessage', function(playerId, playerName, message)
  CancelEvent()

  if string.sub(message, 1, string.len('/')) ~= '/' then
    if not module.Config.DisableChat then
      local player   = Player.fromId(playerId)

      if player then
        local playerData = player:getIdentity()
        local firstname  = playerData:getFirstName()
        local lastname   = playerData:getLastName()
        local arg        = nil

        if firstname and lastname then
          arg = {args = {'IC | ' .. playerId .. ' | ' ..  firstname .. ' ' .. lastname, message}, color = {0, 255, 0}}
        else
          arg = {args = {'IC | ' .. playerId .. " | " .. playerName, message}, color = {0, 255, 0}}
        end

        if module.Config.ProximityMode then
          emitClient('rpchat:proximitySendNUIMessage', -1, playerId, arg)
        else
          emitClient('chat:addMessage', -1, arg)
        end
      else
        local arg = {args = {'IC | ' .. playerId .. " | " .. playerName, message}, color = {0, 255, 0}}

        if module.Config.ProximityMode then
          emitClient('rpchat:proximitySendNUIMessage', -1, playerId, arg)
        else
          emitClient('chat:addMessage', -1, arg)
        end
      end
    end
  end
end)