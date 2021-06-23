local utils = M("utils")
-- local npc = M("npc")

module.Ready, module.FocusActive, module.DataActive, module.Busy, module.SavedWeapon, module.Disabled = false, false, false, false, nil, false
module.X, module.Y, module.Z, module.RotX, module.RotY, module.RotZ = 0.11, 0.0, 0.02, 270.0, 0.0, 0.0

module.Init = function()
  module.ModelNames = run('data/object_names.lua')['Objects']
end

module.Update = function(model)
  print(model)
  if model and Config.Modules.Interactions.Objects[model] then
    if not module.DataActive then
      module.Object = Config.Modules.Interactions.Objects[model]
      module.DataActive = true

      module.Frame:postMessage({
        type         = "update",
        id           = module.Object.id,
        interactable = module.Object.interactable,
        name         = module.Object.name
      })
    end
  else
    print(model .. " not added?")
    module.Object = nil
    module.DataActive = false
    module.Frame:postMessage({ type = "clear" })
  end
end

module.Clear = function()
  module.DataActive = false
  module.Object = nil
  module.Frame:postMessage({ type = "clear" })
end

module.ATM = function(object)
  if not module.Busy then
    module.Busy = true
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed, 0)
    local hash = GetHashKey(object.prop)
    local atm = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.5, hash, false)

    if DoesEntityExist(atm) then
      local position = GetOffsetFromEntityInWorldCoords(atm, 0.0, -0.55, 0.05)
      local heading =  GetEntityHeading(atm)
      TaskTurnPedToFaceEntity(playerPed, atm, -1)

      local count = 0

      if not IsEntityAtCoord(playerPed, position, 0.05, 0.05, 0.05, false, true, 0) then
        TaskGoStraightToCoord(playerPed, position, 0.05, 20000, heading, 0.05)
        while not IsEntityAtCoord(playerPed, position, 0.05, 0.05, 0.05, false, true, 0) and count < 4 do
          count = count + 1
          Citizen.Wait(500)
        end
      end

      TaskTurnPedToFaceEntity(playerPed, atm, -1)
      TaskStartScenarioAtPosition(playerPed, "PROP_HUMAN_ATM", position.x, position.y, coords.z, heading, 0, true, true)
      Wait(2500)
      emitServer('esx:atm:open', object.type)

      module.FocusActive = false
      module.Frame:postMessage({ type = "inactive" })
    end
  end


end

module.VendMachine = function(object)
  if not module.Busy then
    module.Busy = true
    local coords = GetEntityCoords(PlayerPedId(), 0)
    local hash = GetHashKey(object.prop)
    local vendingMachine = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.5, hash, false)

    if DoesEntityExist(vendingMachine) then
      local position = GetOffsetFromEntityInWorldCoords(vendingMachine, 0.0, -0.97, 0.05)
      TaskTurnPedToFaceEntity(PlayerPedId(), vendingMachine, -1)
      utils.game.requestAnimDict("mini@sprunk")
      RequestAmbientAudioBank("VENDING_MACHINE")
      HintAmbientAudioBank("VENDING_MACHINE", 0, -1)
      SetPedResetFlag(PlayerPedId(), 322, true)

      local count = 0

      if not IsEntityAtCoord(PlayerPedId(), position, 0.05, 0.05, 0.05, false, true, 0) then
        TaskGoStraightToCoord(PlayerPedId(), position, 0.05, 20000, GetEntityHeading(vendingMachine), 0.05)
        while not IsEntityAtCoord(PlayerPedId(), position, 0.05, 0.05, 0.05, false, true, 0) and count < 4 do
          count = count + 1
          Citizen.Wait(500)
        end
      end

      TaskTurnPedToFaceEntity(PlayerPedId(), vendingMachine, -1)
      Wait(1000)
      TaskPlayAnim(PlayerPedId(), "mini@sprunk", "plyr_buy_drink_pt1", 8.0, 5.0, -1, 50, 0, 0, 0, 0)
      Wait(3500)

      utils.game.requestModel(object.object)
      local model = CreateObjectNoOffset(object.object, position, true, false, false)

      SetEntityAsMissionEntity(model, true, true)
      SetEntityProofs(model, false, true, false, false, false, false, 0, false)
      -- print("X: " .. module.X .. " Y: " .. module.Y .. " Z: " .. module.Z)
      -- print("RotX: " .. module.RotX .. " RotY: " .. module.RotY .. " RotZ: " .. module.RotZ)
      AttachEntityToEntity(model, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 60309), module.X, module.Y, module.Z, module.RotX, module.RotY, module.RotZ, 1, 1, 0, 0, 2, 1)
      Wait(500)
      StopAnimTask(PlayerPedId(), "mini@sprunk", "plyr_buy_drink_pt1", 1.0)
      Wait(750)
      utils.game.requestAnimDict("mp_player_int_upperarse_pick")
      TaskPlayAnim(PlayerPedId(), "mp_player_int_upperarse_pick", "mp_player_int_arse_pick", 8.0, 5.0, -1, 50, 0, 0, 0, 0)
      Wait(500)
      StopAnimTask(PlayerPedId(), "mp_player_int_upperarse_pick", "mp_player_int_arse_pick", 1.0)
      ClearPedTasks(PlayerPedId())

      if DoesEntityExist(model) then
        DetachEntity(model, true, true)
        DeleteEntity(model)
      end

      ReleaseAmbientAudioBank()
      RemoveAnimDict("mini@sprunk")
      RemoveAnimDict("mp_common_miss")
      SetModelAsNoLongerNeeded(object.object)
    end
    print("object.name " .. object.name)
    if object.name == "Sprunk" then
      print("TESTE)")
      utils.ui.showNotification('You purchased ~g~' .. object.name .. "~s~.")
    elseif object.name == "E-Cola" then
      utils.ui.showNotification('You purchased ~r~' .. object.name .. "~s~.")
    elseif object.name == "Water" then
      utils.ui.showNotification('You purchased ~b~' .. object.name .. "~s~.")
    elseif object.name == "Candy" then
      utils.ui.showNotification('You purchased ~y~' .. object.name .. "~s~.")
    end

    module.FocusActive = false
    module.Frame:postMessage({ type = "inactive" })
    module.Busy = false

    module.RestoreLoadout()
  end
end

module.VendStand = function(object)
  if not module.Busy then
    module.Busy = true

    local hash = GetHashKey(object.prop)
    local coords = GetEntityCoords(PlayerPedId(), 0)
    local npcPed
    local pedCoords

    for ped in utils.game.enumeratePeds() do
      pedCoords = GetEntityCoords(ped, true)
      local distance = #(coords - pedCoords)

      if distance < 3 and DoesEntityExist(ped) and not IsEntityDead(ped) then
        -- local vendorNPC = npc.GetNPC(ped)

        if vendorNPC then
          npcPed = vendorNPC["StorePed"]
        end
      end
    end

    local vendorProp = GetClosestObjectOfType(coords.x, coords.y, coords.z, 3.0, hash, false)

    if DoesEntityExist(vendorProp) and DoesEntityExist(npcPed) then
      local position = GetOffsetFromEntityInWorldCoords(vendorProp, 0.0, -0.97, 0.05)
      ------------------------
      -- INITIAL ANIMATIONS --
      ------------------------

      -- Request Dict
      utils.game.requestAnimDict("gestures@f@standing@casual")

      -- TURN PEDS TO FACE EACH OTHER
      TaskTurnPedToFaceEntity(PlayerPedId(), npcPed, -1)
      Wait(250)

      -- CLEAR TASKS
      ClearPedTasks(npcPed)
      ClearPedTasks(PlayerPedId())
      Wait(250)

      -- PLAYER GESTURES FOR SOMETHING
      TaskPlayAnim(PlayerPedId(), "gestures@f@standing@casual", "gesture_come_here_soft", 8.0, 5.0, -1, 50, 0, 0, 0, 0)
      Wait(1000)

      -- NPC ACKNOWLEDGES
      TaskPlayAnim(npcPed, "gestures@f@standing@casual", "gesture_nod_yes_soft", 8.0, 5.0, -1, 50, 0, 0, 0, 0)
      Wait(500)

      -- PLAYER STOPS GESTURING
      StopAnimTask(PlayerPedId(), "gestures@f@standing@casual", "gesture_come_here_soft", 1.0)
      Wait(500)

      -- NPC STOPS GESTURING
      StopAnimTask(npcPed, "gestures@f@standing@casual", "gesture_nod_yes_soft", 1.0)

      ------------------------------
      -- NPC RETRIEVAL ANIMATIONS --
      ------------------------------

      -- REQUEST DICT
      utils.game.requestAnimDict("anim@amb@business@meth@meth_monitoring_cooking@cooking@")

      -- TURN PEDS TOWARDS PROP
      TaskTurnPedToFaceEntity(PlayerPedId(), venderProp, -1)
      Wait(500)

      -- NPC STARTS RETRIEVING
      TaskPlayAnim(npcPed, "anim@amb@business@meth@meth_monitoring_cooking@cooking@", "base_idle_tank_cooker", 8.0, 5.0, -1, 50, 0, 0, 0, 0)
      Wait(4000)

      -- SPAWN MODEL
      utils.game.requestModel(object.object)
      local model = CreateObjectNoOffset(object.object, position, true, false, false)

      -- ATTACH MODEL TO NPC
      AttachEntityToEntity(model, npcPed, GetPedBoneIndex(npcPed, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
      Wait(500)

      -- STOP RETRIEVING
      StopAnimTask(npcPed, "anim@amb@business@meth@meth_monitoring_cooking@cooking@", "base_idle_tank_cooker", 1.0)
      Wait(1500)



      -- CLEAR PED TASKS
      ClearPedTasks(PlayerPedId())
      ClearPedTasks(npcPed)


      -- DELETE MODEL IF STILL EXISTS
      if DoesEntityExist(model) then
        DetachEntity(model, true, true)
        DeleteEntity(model)
      end

      RemoveAnimDict("anim@amb@business@meth@meth_monitoring_cooking@cooking@")
      SetModelAsNoLongerNeeded(object.object)
    end

    Wait(5000)

    module.FocusActive = false
    module.Frame:postMessage({ type = "inactive" })
    module.Busy = false

    module.RestoreLoadout()
  end
end

module.RestoreLoadout = function()
  if module.SavedWeapon then
    SetCurrentPedWeapon(PlayerPedId(), module.SavedWeapon, true)
    module.SavedWeapon = nil
  end
end

module.Frame = Frame('handler', 'https://cfx-nui-' .. __RESOURCE__ .. '/modules/__core__/interactions/data/html/index.html', true)

module.Frame:on('load', function()
  module.Ready = true
end)
