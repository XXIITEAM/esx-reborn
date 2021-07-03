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

onServer('esx:status:updateStatus', function(statuses)
  module.UpdateStatus(statuses)
end)

onServer('esx:status:statCheck', function(low, dying, drunk, drugName, drugs, stress)
  module.StatCheck(low, dying, drunk, drugName, drugs, stress)
end)

onServer('esx:status:damagePlayer', function()
  module.DamagePlayer()
end)

module.Init()

