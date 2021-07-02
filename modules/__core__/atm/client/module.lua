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

M('events')


module.Ready = false
module.Frame = Frame('atm', 'https://cfx-nui-' .. __RESOURCE__ .. '/modules/__core__/atm/data/html/index.html', true)

module.Frame:on('load', function()
    module.Ready = true
end)

module.Frame:on('withdraw', function(data)
  emitServer('esx:atm:withdrawMoney', data.account, data.quantity)
end)

module.Frame:on('deposit', function(data)
  emitServer('esx:atm:depositMoney', data.account, data.quantity)
end)

module.Frame:on('transfer', function(data)
  emitServer('esx:atm:transferMoney', data.account, data.quantity, data.targetPlayer, data.targetAccount)
end)

module.Frame:on('close', function(data)
  module.Busy = false
  module.Frame:unfocus()
  emit('esx:atm:close')
end)

module.AccessATM = function(intType, object)
  if not module.Busy then
    module.Busy = true
    if DoesEntityExist(object) then
      print(true)
      local playerPed = PlayerPedId()
      local pCoords = GetEntityCoords(playerPed, 0)
      local oCoords = GetEntityCoords(object, 0)
      local position = GetOffsetFromEntityInWorldCoords(object, 0.0, -0.55, 0.05)
      local heading =  GetEntityHeading(object)
      TaskTurnPedToFaceEntity(playerPed, object, -1)

      local count = 0

      if not IsEntityAtCoord(playerPed, position, 0.05, 0.05, 0.05, false, true, 0) then
        TaskGoStraightToCoord(playerPed, position, 0.05, 20000, heading, 0.05)
        while not IsEntityAtCoord(playerPed, position, 0.05, 0.05, 0.05, false, true, 0) and count < 4 do
          count = count + 1
          Citizen.Wait(500)
        end
      end

      TaskTurnPedToFaceEntity(playerPed, atm, -1)
      TaskStartScenarioAtPosition(playerPed, "PROP_HUMAN_ATM", position.x, position.y, pCoords.z, heading, 0, true, true)
      Wait(2500)
      emitServer('esx:atm:open', intType)
    end
  end
end

module.OpenATM = function(accounts, type)
  module.Frame:postMessage({
      method = 'setData',
      data = {
          theme = type,
          accounts = accounts
      }
  })

  module.Frame:postMessage({
    method = 'open'
  })

  module.Frame:focus(true,true)
end

module.SendResult = function (action, result, newAccounts, msgError)
  module.Frame:postMessage({
    method = 'sendResult',
    data = {
      action = action,
      result = result,
      newAccounts = newAccounts or {},
      msgError = msgError or ''
    }
  })
end
