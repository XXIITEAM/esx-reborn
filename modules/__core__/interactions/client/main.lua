module.Init()

ESX.SetInterval(1, function()
  if IsDisabledControlJustReleased(0, 37) then
    if not module.FocusActive then
      module.FocusActive = true
      module.Frame:postMessage({ type = "active" })
    else
      module.FocusActive = false
      module.Frame:postMessage({ type = "inactive" })
      module.RestoreLoadout()
    end
  end

  if IsControlJustReleased(0, 18) and module.FocusActive then
    if module.Object and not module.Busy then
      if module.Object.interactable == "vending" then
        local object = module.Object

        if object.type == "machine" then
          module.VendMachine(object)
        elseif object.type == "vendor" then
          module.VendStand(object)
        end
      elseif module.Object.interactable == "atm" then
        module.ATM(module.Object)
      end
    end
  end
end)

ESX.SetInterval(1, function()
  if module.FocusActive then
    SetPlayerLockonRangeOverride(PlayerId(), 0.0)
    DisablePlayerFiring(PlayerPedId(), true)
    DisableControlAction(0,21,true)
    DisableControlAction(0,22,true)
    DisableControlAction(1,37,true)
    DisableControlAction(0,47,true)  -- disable weapon
    DisableControlAction(0,58,true)  -- disable weapon
    DisableControlAction(0,263,true) -- disable melee
    DisableControlAction(0,264,true) -- disable melee
    DisableControlAction(0,257,true) -- disable melee
    DisableControlAction(0,140,true) -- disable melee
    DisableControlAction(0,141,true) -- disable melee
    DisableControlAction(0,142,true) -- disable melee
    DisableControlAction(0,143,true) -- disable melee

    NetworkSetFriendlyFireOption(false)
    SetCanAttackFriendly(PlayerPedId(), false, false)
  end

  if module.Busy then
    module.Disabled = true
    DisableAllControlActions(0)
    EnableControlAction(0, 1, true)
    EnableControlAction(0, 2, true)
  else
    if module.Disabled then
      module.Disabled = false
      EnableAllControlActions(0)
    end
  end
end)

ESX.SetInterval(250, function()
  if module.FocusActive then
    if GetSelectedPedWeapon(PlayerPedId()) ~= GetHashKey("WEAPON_UNARMED") then
      module.SavedWeapon = GetSelectedPedWeapon(PlayerPedId())
      SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
    end
  end

  if not module.Busy then
    if IsControlPressed(0, 25) and module.FocusActive then
      local aiming, target = GetEntityPlayerIsFreeAimingAt(PlayerId())
      print(aiming)

      if aiming then
        local model = GetEntityModel(target)
        print("model = " .. tostring(model))
        local modelName
        local pCoords = GetEntityCoords(PlayerPedId(), true)
        local tCoords = GetEntityCoords(target, true)
        local distance = #(pCoords - tCoords)

        print(tostring(distance) .. " m")
        if module.ModelNames[tostring(model)] then
          modelName = module.ModelNames[tostring(model)]
        end

        if distance < 15 and DoesEntityExist(target)then
          if modelName then
            module.Update(tostring(modelName))
          end
        else
          module.Clear()
        end
      else
        module.Clear()
      end
    else
      module.Clear()
    end
  else
    module.Clear()
  end
end)
