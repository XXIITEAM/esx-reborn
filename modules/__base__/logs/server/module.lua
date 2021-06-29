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

module.SendLogs = function(message)
  if message == nil or message == '' then return false end

  if module.Config.webhook then
    PerformHttpRequest(module.Config.webhook, function(err, text, headers) end, 'POST', json.encode({ content = message }), { ['Content-Type'] = 'application/json' })
  else
	  return false
  end
end
