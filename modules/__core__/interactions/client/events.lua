-- onServer('esx:interactions:change', function(name, value)
--     if module[name] then
--         print(name .. ": " .. value)
--         module[name] = value
--     end
-- end)


on('esx:atm:close', function()
    ClearPedTasks(PlayerPedId())
    module.Busy = false
    module.RestoreLoadout()
end)