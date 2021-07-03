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
M('events')
M('ui.hud')
module.Config  = run('data/config.lua', {vector3 = vector3})['Config']
module.Ready = false
module.Frame = nil
module.Debug = false

function Sanitize(str)
	local replacements = {
		['&' ] = '&amp;',
		['<' ] = '&lt;',
		['>' ] = '&gt;',
		['\n'] = '<br/>'
	}

	return str
		:gsub('[&<>\n]', replacements)
		:gsub(' +', function(s)
			return ' '..('&nbsp;'):rep(#s-1)
		end)
end

RegisterCommand("OpenScoreboard", function()
    if module.Debug then print("Scoreboard:open") end

    local header = {}
    table.insert(header, '<tr><th>Name</th><th>RP Name</th><th>SERVER ID</th><th>Ping</th></tr>')
    ClearTimecycleModifier()
    SetTimecycleModifier("hud_def_blur")

    if module.Debug then print(header) end

    module.Frame:postMessage({action = "SHOW:SCOREBOARD", header = (header)})
    DisplayRadar(false)
    module.Frame:focus(true) -- sets nui focus automatically, and true or false determines if mouse cursor should exit

    local players = {}

    request('esx:scoreboard:Getplayers', function(players)
        if players then

            if module.Debug then
                print(GetPlayerName(playerId))
                print(players)
            end

            module.Frame:postMessage({action = "ADD:PLAYER", data = (players)})
        else
            return
        end

    end)
    request('esx:scoreboard:GetInfo', function(players, name, id, maxPlayers)
        if module.Debug then
            print("players",info)
        end
        module.Frame:postMessage({action = "ADD:INFO", data = (players), text = (name.. " - ".. id), maxPlayers = (maxPlayers)})
    end)
end, false)

module.CloseScoreboard = function()
    DisplayRadar(true)
    ClearTimecycleModifier()
    module.Frame:postMessage({action = "HIDE:SCOREBOARD"})
    module.Frame:unfocusAll()
end

RegisterCommand("CloseScoreboard", function()
    DisplayRadar(true)
    ClearTimecycleModifier()
    module.Frame:postMessage({action = "HIDE:SCOREBOARD"})
    module.Frame:unfocusAll()
end, false)

RegisterKeyMapping('OpenScoreboard', 'Open Scoreboard', 'keyboard', 'f11')
