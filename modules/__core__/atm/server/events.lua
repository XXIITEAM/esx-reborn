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


onClient('esx:atm:depositMoney', function(amount)
  module.depositMoney(amount)
end)

onClient('esx:atm:withdrawMoney', function(amount)
  module.withdrawMoney(amount)
end)

onClient('esx:atm:transferMoney', function(amount, playerId)
  module.transferMoney(amount, playerId)
end)
