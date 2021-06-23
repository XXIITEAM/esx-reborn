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

module.DepositMoney = function(playerId, account, amount)
  local amount   = amount
  local playerId = playerId
  local player   = Player.fromId(playerId)
  local identity = player:getIdentity()
  local accounts = identity:getAccounts()

  local walletAmount = accounts:getWallet()

  if walletAmount < amount then
    emitClient('esx:atm:sendResult', playerId, 'deposit', false, 0, "Insufficient funds")
    return
  end

  accounts:removeMoney('wallet', amount, function(result)
    if result then
      accounts:addMoney(account, amount, function(result)
        if result then
          emitClient('esx:atm:sendResult', playerId, 'deposit', true, accounts:serialize())
        end
      end)
    end
  end)

end


module.WithdrawMoney = function(playerId, account, amount)
  local amount   = amount
  local playerId = playerId
  local player   = Player.fromId(playerId)
  local identity = player:getIdentity()
  local accounts = identity:getAccounts()

  local accountAmount = accounts[account]

  if accountAmount < amount then
    emitClient('esx:atm:sendResult', playerId, 'withdraw', false, 0, "Insufficient funds")
    return
  end

  accounts:removeMoney(account, amount, function(result)

    if result then
      accounts:addMoney('wallet', amount, function (result)
        if result then
          emitClient('esx:atm:sendResult', playerId, 'withdraw', true, accounts:serialize())
        end
      end)
    end
  end)


end


module.TransferMoney = function(playerId, account, amount, targetPlayer, targetAccount)

  local account        = account
  local amount         = amount
  local targetAccount  = targetAccount
  local playerId       = playerId
  local targetId       = targetPlayer
  local player         = Player.fromId(playerId)
  local playerIdentity = player:getIdentity()
  local playerAccounts = playerIdentity:getAccounts()

  if (targetId == playerId) then
    if(account == targetAccount) then
      emitClient('esx:atm:sendResult', playerId, 'transfer', false, playerAccounts:serialize(), "You can not transfer to the same account")
      return
    end
  end

  local targetPlayer  = Player.fromId(targetId)

  if (targetPlayer == nil) then
    emitClient('esx:atm:sendResult', playerId, 'transfer', false, playerAccounts:serialize(), "Could not find player with ID " .. tostring(targetId))
    return
  end


  local targetIdentity = targetPlayer:getIdentity()

  if (targetIdentity == nil) then
    emitClient('esx:atm:sendResult', playerId, 'transfer', false, playerAccounts:serialize(), "Player with ID " .. tostring(targetId) .. " is selecting identity")
    return
  end

  local targetAccounts = targetIdentity:getAccounts()

  local fromAccount = playerAccounts[account]

  if (fromAccount < amount) then
    emitClient('esx:atm:sendResult', playerId, 'transfer', false, playerAccounts:serialize(), "Insufficient funds")
    return
  end

  local toAccount = targetAccounts[account]

  playerAccounts:removeMoney(account, amount, function(result)

    if result then
      targetAccounts:addMoney(targetAccount, amount, function (result)
        if result then
          emitClient('esx:atm:sendResult', playerId, 'transfer', true, playerAccounts:serialize())
        end
      end)
    end
  end)

end
