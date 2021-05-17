AddEventHandler("playerConnecting", function(playerName, setKickReason, deferrals)
    module.onPlayerConnecting(playerName, setKickReason, deferrals, source)
end)