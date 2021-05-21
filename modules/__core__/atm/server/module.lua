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

M("command")
M("account")

module.init = function()
  module.openAtmCommand()
end

module.openAtmCommand = function()
  local atmCommand = Command("atm", "user", "Open atm display")

  atmCommand:setHandler(
      function(player)
          emitClient("esx:atm:visibility", player.source)
      end
  )
  atmCommand:register()
end

--FIXE: when accounts is done, get the account amount of the source
-- and trigger a client event with the feedback message to NUI

module.depositMoney = function(amount)
  -- Account.RemoveIdentityMoney("money", amount, player)
  -- Account.AddIdentityMoney("bank", amount, player)
  print('deposit', amount, source)
end

module.withdrawMoney = function(amount)
  -- Account.RemoveIdentityMoney("money", amount, player)
  -- Account.AddIdentityMoney("bank", amount, player)
  print('withdraw', amount, source)
end

module.transferMoney = function(amount, playerId)
  --Account.RemoveIdentityMoney('bank', amount, source)
  --Account.AddIdentityMoney('bank', amount, playerId)
  print('transfer', amount, playerId)
end