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

module.Config  = run('data/config.lua', {vector3 = vector3})['Config']
module.Frame = Frame('scoreboard', 'https://cfx-nui-' .. __RESOURCE__ .. '/modules/__base__/scoreboard/data/html/'.. module.Config.Theme ..'.html', true)

module.Frame:on('load', function() module.Ready = true end)

on('esx:characterLoaded', function()
    emitServer('esx:scoredboard:addPlayer')
end)

module.Frame:on('message', function(msg)
    if msg.action == 'CLOSE:SCOREBOARD' then module.CloseScoreboard() end
end)
