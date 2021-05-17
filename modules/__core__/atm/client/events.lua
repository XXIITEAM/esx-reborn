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

--M('events')
--M('ui.hud')
--local utils = M('utils')
--
--onServer('esx:atm:deposit', function()
--    print('You have deposited money into the bank')
--    utils.ui.showNotification("Money deposited")
--end)

module.Frame = Frame('atm', 'https://cfx-nui-' .. __RESOURCE__ .. '/modules/__core__/atm/data/html/index.html', true)

module.Frame:on('load', function()
    module.Ready = true
end)

