onClient('handler:true', function(objectNames)
    for k,v in pairs(objectNames) do
        print(tostring(k) .. " | " .. tostring(v))
    end
end)

onClient('handler:false', function()
    print(false)
end)