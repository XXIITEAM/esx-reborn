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

local utils = M('utils')
M('ui.hud')

module.Dict          = "cellphone@"
module.InAnim        = "cellphone_text_in"
module.OutAnim       = "cellphone_text_out"
module.IdleAnim      = "cellphone_text_read_base"
module.WalletShowing = false

Account = {}
Account.Ready, Account.Frame, Account.isPaused = false, nil, false

Account.Notify = function(account, transactionAmount)
  utils.ui.showNotification(_U('account_notify_moneychange', _U('account_moniker'), transactionAmount, account))
end

Account.NotEnoughMoney = function(account, money)
  utils.ui.showNotification(_U('account_notify_not_enough_money', _U('account_moniker'), money, account))
end

Account.TransactionError = function(account)
  utils.ui.showNotification(_U('account_notify_transaction_error', account))
end

Account.ShowMoney = function(accounts)

  local Accounts = {}
  local index = 0

  for k,v in pairs(accounts) do
    index = index + 1
    Accounts[index] = {
      id = index,
      type = k,
      amount = v
    }
  end

  module.Frame:postMessage({
    data = Accounts
  })

end

module.Frame = Frame('account', 'https://cfx-nui-' .. __RESOURCE__ .. '/modules/__core__/account/data/html/index.html', true)

module.Frame:on('load', function()
  module.Ready = true
  emit('esx:account:ready')
end)
