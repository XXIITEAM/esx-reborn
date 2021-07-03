-- Copyright (c) Jérémie N'gadi
--
-- All rights reserved.
--
-- Even if 'All rights reserved' is very clear :
--
--   You shall not use any piece of this software in a commercial product / service
--   You shall not resell this software
--   You shall not provide any facility to install this particular software in a commercial product / service
--   If you redistribute this software, you must link to ORIGINAL repository at https://github.com/ESX-Org/esx-reborn
--   This copyright should appear in every part of the project code

local utils = M('utils')

module.Init()

module.Config = run('data/config.lua', {vector3 = vector3})['Config']

ESX.SetInterval(1, function()
  if not module.Sitting then
    if module.Object then
      if IsControlJustPressed(0, module.Config.SitKey) and module.Object and IsInputDisabled(0) and IsPedOnFoot(PlayerPedId()) then
        if module.Object then
          module.Sit(module.Object)
        end
      end

      if IsControlJustPressed(0, module.Config.LieDownKey) and module.Object and IsInputDisabled(0) and IsPedOnFoot(PlayerPedId()) then
        if module.Object then
          if module.Object.type == "bed" then
            module.LieDown(module.Object)
          end
        end
      end
    end
  else
    if (IsControlJustPressed(0, module.Config.GetUpKey) or module.WakeupPlease) and module.Sitting and IsInputDisabled(0) then
      if module.WakeupPlease then
        module.Wakeup(true)
      else
        module.Wakeup()
      end
    end

    if IsControlJustPressed(0, module.Config.SwitchPositionKey) then
      module.SwitchPositions(module.Object)
    end

    if module.Coords then
      if module.Object.type == "chair" then
        utils.ui.draw3DText(module.Coords.x, module.Coords.y, module.Coords.z-0.5, 0, 0, 0, 0, tostring(_U('sit:press_getup')))
      elseif module.Object.type == "bed" then
        utils.ui.draw3DText(module.Coords.x, module.Coords.y, module.Coords.z-1.0, 0, 0, 0, 0, tostring(_U('sit:press_getup_switch')))
      end
    end
  end
end)

ESX.SetInterval(500, function()
  module.Coords = GetEntityCoords(PlayerPedId())
end)

ESX.SetInterval(500, function()
  if not module.Sitting and module.Coords then
    for _,v in ipairs(module.Config.Interactables) do
      local closestObject = GetClosestObjectOfType(module.Coords.x, module.Coords.y, module.Coords.z, module.Config.MaxDistance, GetHashKey(v.object), 0, 0, 0)
      local coordsObject  = GetEntityCoords(closestObject)
      local distanceDiff  = #(coordsObject - module.Coords)

      if (distanceDiff < module.Config.MaxDistance) then
        if not module.DrawActive then
          if v.type == "chair" then
            module.Object = {
              name           = closestObject,
              coords         = coordsObject,
              type           = v.type,
              scenario       = v.scenario,
              scenario2      = v.scenario2,
              verticalOffset = v.verticalOffset,
              forwardOffset  = v.forwardOffset,
              leftOffset     = v.leftOffset,
              text           = tostring(_U('sit:press_chair'))
            }

            module.DrawActive = true
          elseif v.type == "bed" then
            module.Object = {
              name           = closestObject,
              coords         = coordsObject,
              type           = v.type,
              scenario       = v.scenario,
              scenario2      = v.scenario2,
              verticalOffset = v.verticalOffset,
              forwardOffset  = v.forwardOffset,
              leftOffset     = v.leftOffset,
              text           = tostring(_U('sit:press_bed'))
            }

            module.DrawActive = true
          end

          break
        else
          Wait(1000)
        end
      else
        module.Object = nil
        module.DrawActive = false
      end
    end
  else
    Wait(1000)
  end
end)

ESX.SetInterval(1, function()
  if module.Sitting then
    module.DrawActive = false
    Wait(1000)
  else
    if module.DrawActive then
      if module.Object then
        utils.ui.draw3DText(module.Object.coords.x, module.Object.coords.y, module.Object.coords.z, 0, 0, 0, 0, module.Object.text)
      end
    end
  end
end)
