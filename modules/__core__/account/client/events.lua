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

onServer('esx:account:notify', function(account, transactionAmount)
  Account.Notify(account, transactionAmount)
end)

onServer('esx:account:notEnoughMoney', function(account, money)
  Account.NotEnoughMoney(account, money)
end)

onServer('esx:account:transactionError', function(account)
  Account.TransactionError(account)
end)

onServer('esx:account:showMoney', function(accounts)
  Account.ShowMoney(accounts)
end)
