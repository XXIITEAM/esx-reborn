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

local utils  = M("utils")

module.NPCs = {}

ESX.SetInterval(20000, function()
  if not module.Ready then
    module.Ready = true
    module.SpawnNPCs()
  end
end)

ESX.SetInterval(600000, function()
  if module.NPCs then
    for k,v in pairs(module.NPCs) do
      if DoesEntityExist(v.id) then
        local health = GetEntityHealth(v.id)

        if health == 0 then
          DeleteEntity(v.id)
          module.RespawnPed(k)
        end
      else
        module.RespawnPed(k)
      end
    end
  end
end)