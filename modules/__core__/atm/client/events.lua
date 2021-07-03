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

--M('events')
--M('ui.hud')
--local utils = M('utils')
--
--onServer('esx:atm:deposit', function()
--    print('You have deposited money into the bank')
--    utils.ui.showNotification("Money deposited")
--end)

onServer('esx:atm:open', function(accounts, type)
  module.OpenATM(accounts, type)
end)

onServer('esx:atm:sendResult', function(action, result, newAccounts, msgError)
  module.SendResult(action, result, newAccounts, msgError)
end)

on("interactions:atm", function(action, interactable, object)
  module.AccessATM(interactable.type, object.target)
end)
