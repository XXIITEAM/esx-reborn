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

onClient('esx:atm:open', function(type)
  local player = Player.fromId(source)
  local identity = player:getIdentity()
  local accounts = identity:getAccounts()

  emitClient('esx:atm:open', player.source, accounts:serialize(), type)
end)

onClient('esx:atm:depositMoney', function(account, amount)
  module.DepositMoney(source, account, amount)
end)

onClient('esx:atm:withdrawMoney', function(account, amount)
  module.WithdrawMoney(source, account, amount)
end)

onClient('esx:atm:transferMoney', function(account, amount, targetPlayer, targetAccount)
  module.TransferMoney(source, account, amount, targetPlayer, targetAccount)
end)
