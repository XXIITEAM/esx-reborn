
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

onServer('rpchat:sendLifeInvaderMessage', function(playerId, message, name)

  module.SendLifeInvaderMessage(playerId, message, name)

end)

onServer('rpchat:3DTextOverhead', function(playerId, message)
  local id = GetPlayerFromServerId(playerId)

  if NetworkIsPlayerActive(id) then
    local targetPed = GetPlayerPed(id)
    module.Draw3DTextOverheadWithTimeout(targetPed,message,1,0)
  end
end)

onServer('rpchat:proximitySendNUIMessage', function(id, message)
  local clientId = PlayerId()
  local authorId = GetPlayerFromServerId(id)

  if authorId == clientId then
	TriggerEvent('chat:addMessage', message)
  else
    if NetworkIsPlayerActive(authorId) then
      if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(clientId)), GetEntityCoords(GetPlayerPed(authorId)), true) < module.Config.Proximity then
        TriggerEvent('chat:addMessage', message)
	  end
	end
  end
end)