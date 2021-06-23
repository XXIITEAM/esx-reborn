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
  module.Frame:unfocus()
  emit('esx:atm:close')
end)





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
