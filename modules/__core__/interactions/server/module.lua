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

module.Ready = false
module.NPCs = {}

module.SpawnNPCs = function()
  if Config.Modules.Interactions.NPCEntities then
    for k,v in pairs(Config.Modules.Interactions.NPCEntities) do
      -- print(tostring(k))

      utils.game.createPed(v.model, v.coords, v.heading, function(ped)
        local count = 0

        while not DoesEntityExist(ped) and count < 1000 do
          count = count + 1
          Wait(10)
        end

        if not module.NPCs[k] then
          module.NPCs[k] = {
            id      = ped,
            model   = v.model,
            coords  = v.coords,
            heading = v.heading,
            entity  = v.entity,
            prop    = v.prop,
            eCoords = v.eCoords
          }
        end
      end)
    end

    if Config.Modules.Interactions.UseExternalEventHandler then
      TriggerEvent('external_handler:storeNPCs', module.NPCs)
    end
  end
end

module.RespawnPed = function(k)
  local data = module.NPCs[k]

  utils.game.createPed(data.model, data.coords, data.heading, function(ped)
    local count = 0

    while not DoesEntityExist(ped) and count < 1000 do
      count = count + 1
      Wait(10)
    end

    module.NPCs[k] = {
      id      = ped,
      model   = data.model,
      coords  = data.coords,
      heading = data.heading,
      entity  = data.entity,
      prop    = data.prop,
      eCoords = data.eCoords
    }
  end)
  
  if Config.Modules.Interactions.UseExternalEventHandler then
    TriggerEvent('external_handler:storeNPCs', module.NPCs)
  end
end
