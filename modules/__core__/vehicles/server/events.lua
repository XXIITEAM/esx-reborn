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

------------------------------------------------------------------------
----------                                                    ----------
--                              IMPORTS                               --
----------                                                    ----------
------------------------------------------------------------------------

local Command = M("events")
local migrate = M('migrate')

------------------------------------------------------------------------
----------                                                    ----------
--                             MIGRATION                              --
----------                                                    ----------
------------------------------------------------------------------------

on("esx:db:ready", function()
  migrate.Ensure("vehicles", "core")
end)

on('esx:ready', function()
  module.Ready = true
  module.Init()
end)

------------------------------------------------------------------------
----------                                                    ----------
--                             REQUESTS                               --
----------                                                    ----------
------------------------------------------------------------------------

onRequest("vehicles:getVehicles", function(source, cb)
  while not module.Ready do
    Wait(100)
  end

  while not module.Imported do
    Wait(100)
  end

  cb(module.Cache)
end)