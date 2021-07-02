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
--
-----
--
-- Source before modification for ScreenToWorld, ScreenRelToWorld, RotToDir, World3DToScreen2D functions:
--
-- https://gtaforums.com/topic/802220-screen-to-world-coordinates/?tab=comments#comment-1067790512
--
-- The ScreenToWorld, ScreenRelToWorld, RotToDir, World3DToScreen2D functions are not claimed as part of the ESX copyright

local utils = M("utils")

module.Ready, module.FocusActive, module.DataActive, module.Busy, module.SavedWeapon, module.Disabled = false, false, false, false, nil, false
module.Abs, module.Sin, module.Cos, module.Pi, module.RaycastLength, module.ToIgnore, module.Flags = math.abs, math.sin, math.cos, math.pi, 50.0, 0, 30
module.Object, module.Interactable = {}, {}
module.ShouldHighlightObject = false

module.Init = function()
  module.ModelNames = run('data/object_names.lua')['Objects']
end

module.Clear = function()
  module.DataActive = false
  module.Object     = nil
  module.Frame:postMessage({ type = "clear" })
end

-- module.VendStand = function(object)
--   if not module.Busy then
--     module.Busy = true

--     local hash = GetHashKey(object.prop)
--     local coords = GetEntityCoords(PlayerPedId(), 0)
--     local npcPed
--     local pedCoords

--     for ped in utils.game.enumeratePeds() do
--       pedCoords = GetEntityCoords(ped, true)
--       local distance = #(coords - pedCoords)

--       if distance < 3 and DoesEntityExist(ped) and not IsEntityDead(ped) then
--         -- local vendorNPC = npc.GetNPC(ped)

--         if vendorNPC then
--           npcPed = vendorNPC["StorePed"]
--         end
--       end
--     end

--     local vendorProp = GetClosestObjectOfType(coords.x, coords.y, coords.z, 3.0, hash, false)

--     if DoesEntityExist(vendorProp) and DoesEntityExist(npcPed) then
--       local position = GetOffsetFromEntityInWorldCoords(vendorProp, 0.0, -0.97, 0.05)
--       ------------------------
--       -- INITIAL ANIMATIONS --
--       ------------------------

--       -- Request Dict
--       utils.game.requestAnimDict("gestures@f@standing@casual")

--       -- TURN PEDS TO FACE EACH OTHER
--       TaskTurnPedToFaceEntity(PlayerPedId(), npcPed, -1)
--       Wait(250)

--       -- CLEAR TASKS
--       ClearPedTasks(npcPed)
--       ClearPedTasks(PlayerPedId())
--       Wait(250)

--       -- PLAYER GESTURES FOR SOMETHING
--       TaskPlayAnim(PlayerPedId(), "gestures@f@standing@casual", "gesture_come_here_soft", 8.0, 5.0, -1, 50, 0, 0, 0, 0)
--       Wait(1000)

--       -- NPC ACKNOWLEDGES
--       TaskPlayAnim(npcPed, "gestures@f@standing@casual", "gesture_nod_yes_soft", 8.0, 5.0, -1, 50, 0, 0, 0, 0)
--       Wait(500)

--       -- PLAYER STOPS GESTURING
--       StopAnimTask(PlayerPedId(), "gestures@f@standing@casual", "gesture_come_here_soft", 1.0)
--       Wait(500)

--       -- NPC STOPS GESTURING
--       StopAnimTask(npcPed, "gestures@f@standing@casual", "gesture_nod_yes_soft", 1.0)

--       ------------------------------
--       -- NPC RETRIEVAL ANIMATIONS --
--       ------------------------------

--       -- REQUEST DICT
--       utils.game.requestAnimDict("anim@amb@business@meth@meth_monitoring_cooking@cooking@")

--       -- TURN PEDS TOWARDS PROP
--       TaskTurnPedToFaceEntity(PlayerPedId(), venderProp, -1)
--       Wait(500)

--       -- NPC STARTS RETRIEVING
--       TaskPlayAnim(npcPed, "anim@amb@business@meth@meth_monitoring_cooking@cooking@", "base_idle_tank_cooker", 8.0, 5.0, -1, 50, 0, 0, 0, 0)
--       Wait(4000)

--       -- SPAWN MODEL
--       utils.game.requestModel(object.object)
--       local model = CreateObjectNoOffset(object.object, position, true, false, false)

--       -- ATTACH MODEL TO NPC
--       AttachEntityToEntity(model, npcPed, GetPedBoneIndex(npcPed, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
--       Wait(500)

--       -- STOP RETRIEVING
--       StopAnimTask(npcPed, "anim@amb@business@meth@meth_monitoring_cooking@cooking@", "base_idle_tank_cooker", 1.0)
--       Wait(1500)

--       -- CLEAR PED TASKS
--       ClearPedTasks(PlayerPedId())
--       ClearPedTasks(npcPed)

--       -- DELETE MODEL IF STILL EXISTS
--       if DoesEntityExist(model) then
--         DetachEntity(model, true, true)
--         DeleteEntity(model)
--       end

--       RemoveAnimDict("anim@amb@business@meth@meth_monitoring_cooking@cooking@")
--       SetModelAsNoLongerNeeded(object.object)
--     end

--     Wait(5000)

--     module.FocusActive = false
--     module.Frame:postMessage({ type = "inactive" })
--     module.Busy = false

--     module.RestoreLoadout()
--   end
-- end

module.RestoreLoadout = function()
  if module.SavedWeapon then
    SetCurrentPedWeapon(PlayerPedId(), module.SavedWeapon, true)
    module.SavedWeapon = nil
  end
end

module.StartRaycast = function()
  local point, endCoords, surfaceNormal, foundEntity, foundType, dir = module.ScreenToWorld(module.Flags, module.ToIgnore)

  if foundEntity == 0 then
    foundType = 0
  end

  module.Object = {
    target = foundEntity,
    type = foundType,
    hash = GetEntityModel(foundEntity),
    coords = GetEntityCoords(foundEntity, 1),
    heading = GetEntityHeading(foundEntity),
    rotation = GetEntityRotation(foundEntity)
  }

  if module.ModelNames[tostring(module.Object.hash)] then
    local model = module.ModelNames[tostring(module.Object.hash)]

    if Config.Modules.Interactions.Objects[model] then
      local ped = PlayerPedId()
      local playerCoords = GetEntityCoords(ped, true)
      local distance = #(playerCoords - module.Object.coords)

      if distance < 3 then
        module.Interactable = Config.Modules.Interactions.Objects[model]
 
        if Config.Modules.Interactions.EnableDebugging then
          module.ShouldHighlightObject = true
        end

        if module.Interactable then
          module.Frame:postMessage({
            type         = "open",
            interactable = module.Interactable.interactable
          })
        end
      end
    else
      print(tostring(model) .. " not added?")
    end
  else
    print(tostring(module.Object.hash) .. " not found?")
  end
end

module.ScreenToWorld = function(flags, toIgnore)
  local camRot               = GetGameplayCamRot(0)
  local camPos               = GetGameplayCamCoord()
  local posX                 = GetControlNormal(0, 239)
  local posY                 = GetControlNormal(0, 240)
  local cursor               = vector2(posX, posY)
  local cam3DPos, forwardDir = module.ScreenRelToWorld(camPos, camRot, cursor)
  local dir            = camPos + forwardDir * module.RaycastLength
  local rayHandle            = StartShapeTestRay(cam3DPos, dir, flags, toIgnore, 0)
  local _, point, endCoords, surfaceNormal, foundEntity = GetShapeTestResult(rayHandle)

  if foundEntity >= 1 then
      foundType = GetEntityType(foundEntity)
  end

  return point, endCoords, surfaceNormal, foundEntity, foundType, dir
end

module.HighlightObject = function(coords)
  SetDrawOrigin(coords.x, coords.y, coords.z, 0)
  RequestStreamedTextureDict("helicopterhud", false)
  DrawSprite("helicopterhud", "hud_corner", -0.01, -0.01, 0.006, 0.006, 0.0, 0, 255, 255, 200)
  DrawSprite("helicopterhud", "hud_corner", 0.01, -0.01, 0.006, 0.006, 90.0, 0, 255, 255, 200)
  DrawSprite("helicopterhud", "hud_corner", -0.01, 0.01, 0.006, 0.006, 270.0, 0, 255, 255, 200)
  DrawSprite("helicopterhud", "hud_corner", 0.01, 0.01, 0.006, 0.006, 180.0, 0, 255, 255, 200)
  ClearDrawOrigin()
end

module.ScreenRelToWorld = function(camPos, camRot, cursor)
  local camForward = module.RotToDir(camRot)
  local rotUp = vector3(camRot.x + 1.0, camRot.y, camRot.z)
  local rotDown = vector3(camRot.x - 1.0, camRot.y, camRot.z)
  local rotLeft = vector3(camRot.x, camRot.y, camRot.z - 1.0)
  local rotRight = vector3(camRot.x, camRot.y, camRot.z + 1.0)
  local camRight = module.RotToDir(rotRight) - module.RotToDir(rotLeft)
  local camUp = module.RotToDir(rotUp) - module.RotToDir(rotDown)
  local rollRad = -(camRot.y * module.Pi / 180.0)
  local camRightRoll = camRight * module.Cos(rollRad) - camUp * module.Sin(rollRad)
  local camUpRoll = camRight * module.Sin(rollRad) + camUp * module.Cos(rollRad)
  local point3DZero = camPos + camForward * 1.0
  local point3D = point3DZero + camRightRoll + camUpRoll
  local point2D = module.World3DToScreen2D(point3D)
  local point2DZero = module.World3DToScreen2D(point3DZero)
  local scaleX = (cursor.x - point2DZero.x) / (point2D.x - point2DZero.x)
  local scaleY = (cursor.y - point2DZero.y) / (point2D.y - point2DZero.y)
  local point3Dret = point3DZero + camRightRoll * scaleX + camUpRoll * scaleY
  local forwardDir = camForward + camRightRoll * scaleX + camUpRoll * scaleY

  return point3Dret, forwardDir
end

module.RotToDir = function(rotation)
  local x = rotation.x * module.Pi / 180.0
  local z = rotation.z * module.Pi / 180.0
  local num = module.Abs(module.Cos(x))

  return vector3((-module.Sin(z) * num), (module.Cos(z) * num), module.Sin(x))
end

module.World3DToScreen2D = function(pos)
  local _, sX, sY = GetScreenCoordFromWorldCoord(pos.x, pos.y, pos.z)

  return vector2(sX, sY)
end

module.StartInteraction = function()
  SetCursorLocation(0.5, 0.5)
  module.Frame:postMessage({ type = "active" })
  module.Frame:focus(true, true)
end

module.EndInteraction = function(restore)
  module.Frame:unfocus()
  module.FocusActive = false
  module.Object, module.Interactable = {}, {}

  if restore then
    module.RestoreLoadout()
  end
end

module.Frame = Frame('handler', 'https://cfx-nui-' .. __RESOURCE__ .. '/modules/__core__/interactions/data/html/index.html', true)

module.Frame:on('load', function()
  module.Ready = true
end)

module.Frame:on('message', function(msg)
  if msg.action == 'interactions:raycast' then
    module.StartRaycast()
  elseif msg.action == 'interactions:atm:use' then
    if module.Interactable and module.Object then
      local interactable = module.Interactable
      local object = module.Object

      module.EndInteraction(false)

      emit("interactions:atm", "use", interactable, object)
    end
  elseif msg.action == 'interactions:vehicle:in' then
    if module.Interactable and module.Object then
      emit("interactions:vehicle", "in", module.Interactable, module.Object)
    end

    module.EndInteraction(false)
  elseif msg.action == 'interactions:vehicle:frontleft' then
    if module.Interactable and module.Object then
      emit("interactions:vehicle", "frontleft", module.Interactable, module.Object)
    end
  elseif msg.action == 'interactions:vehicle:frontright' then
    if module.Interactable and module.Object then
      emit("interactions:vehicle", "frontright", module.Interactable, module.Object)
    end
  elseif msg.action == 'interactions:vehicle:backleft' then
    if module.Interactable and module.Object then
      emit("interactions:vehicle", "backleft", module.Interactable, module.Object)
    end
  elseif msg.action == 'interactions:vehicle:backright' then
    if module.Interactable and module.Object then
      emit("interactions:vehicle", "backright", module.Interactable, module.Object)
    end
  elseif msg.action == 'interactions:vehicle:hood' then
    if module.Interactable and module.Object then
      emit("interactions:vehicle", "hood", module.Interactable, module.Object)
    end
  elseif msg.action == 'interactions:vehicle:trunk' then
    if module.Interactable and module.Object then
      emit("interactions:vehicle", "trunk", module.Interactable, module.Object)
    end
  elseif msg.action == 'interactions:vehicle:lockpick' then
    if module.Interactable and module.Object then
      emit("interactions:vehicle", "lockpick", module.Interactable, module.Object)
    end

    module.EndInteraction(false)
  elseif msg.action == 'interactions:door:open' then
    if module.Interactable and module.Object then
      emit("interactions:door", "open", module.Interactable, module.Object)
    end

    module.EndInteraction(false)
  elseif msg.action == 'interactions:door:close' then
    if module.Interactable and module.Object then
      emit("interactions:door", "close", module.Interactable, module.Object)
    end

    module.EndInteraction(false)
  elseif msg.action == 'interactions:door:lock' then
    if module.Interactable and module.Object then
      emit("interactions:door", "lock", module.Interactable, module.Object)
    end

    module.EndInteraction(false)
  elseif msg.action == 'interactions:door:unlock' then
    if module.Interactable and module.Object then
      emit("interactions:door", "unlock", module.Interactable, module.Object)
    end

    module.EndInteraction(false)
  elseif msg.action == 'interactions:door:lockpick' then
    if module.Interactable and module.Object then
      emit("interactions:door", "lockpick", module.Interactable, module.Object)
    end

    module.EndInteraction(false)
  elseif msg.action == 'interactions:vending:buy' then
    if module.Interactable and module.Object then
      local interactable = module.Interactable
      local object = module.Object
  
      module.EndInteraction(false)

      emit("interactions:vending", "buy", interactable, object)
    end
  elseif msg.action == 'interactions:npcvending:buy' then
    if module.Interactable and module.Object then
      local interactable = module.Interactable
      local object = module.Object
  
      request('interactions:getNPC', function(npc)
        if npc then
          print("NPC FOUND")
        end
      end, module.Object)

      module.EndInteraction(false)

      emit("interactions:npcvending", "buy", interactable, object)
    end
  elseif msg.action == 'interactions:close' then
    module.EndInteraction(true)
  end
end)
