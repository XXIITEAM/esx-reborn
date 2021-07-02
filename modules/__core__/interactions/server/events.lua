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

onRequest("interactions:getNPC", function(source, cb, object)
  if module.NPCs then
    print(json.encode(object.coords))

    for k,v in pairs(module.NPCs) do
      print(json.encode(v.eCoords))
      if json.encode(object.coords) == json.encode(v.eCoords) then
        if DoesEntityExist(v.id) then
          local health = GetEntityHealth(v.id)

          if health ~= 0 then
            cb(module.NPCs[k])
          else
            cb(nil)
          end
        else
          cb(nil)
        end
      end
    end

    cb(nil)
  else
    cb(nil)
  end
end)

AddEventHandler('onResourceStop', function(resourceName)
  if (GetCurrentResourceName() == resourceName) then
    if Config.Modules.Interactions.UseExternalEventHandler then
      TriggerEvent('external_handler:deleteEntities')
    end
  end
end)  