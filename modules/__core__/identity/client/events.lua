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

on("esx:identity:selectIdentity", function(identity)
    module.SelectIdentityAndSpawnCharacter(identity)
end)

on("esx:identity:openRegistration", function()
    -- identity arrives serialized here
    module.RequestRegistration(function(identity)
        module.initIdentity(identity)
    end)
end)

-- Temporary solution to blocking saving position
-- @TODO: Find a more permanent solution
on("esx:identity:preventSaving", function(value)
    module.preventSaving = value
end)

