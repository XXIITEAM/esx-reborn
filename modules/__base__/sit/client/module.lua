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

local utils = M('utils')

module.Config = run('data/config.lua', {vector3 = vector3})['Config']

module.Object, module.LastPos, module.CurrentCoords, module.CurrentScenario = nil, nil, nil, nil
module.Sitting, module.DrawActive, module.WakeupPlease = false, false, false

module.Init = function()
  local translations = run('data/locales/' .. Config.Locale .. '.lua')['Translations']
  LoadLocale('sit', Config.Locale, translations)

  module.Wakeup()
end

module.Wakeup = function(forced)
  if forced then
    Wait(500)
  end
  ClearPedTasks(PlayerPedId())
  module.Sitting = false
  emitServer('sit:leavePlace', module.CurrentSitCoords)
  FreezeEntityPosition(PlayerPedId(), false)
  ClearPedTasks(PlayerPedId())
  if not forced then
    if module.LastPos and module.Object then
      if module.Object.type == "bed" then
        SetEntityCoords(PlayerPedId(), module.LastPos)
      end
    end
  end
  module.CurrentSitCoords, module.CurrentScenario, module.LastPos = nil, nil, nil
end

module.Sit = function(object)

  if module.Config.Debug then
    print("name = " .. object.name)
    print("type = " .. object.type)
    print("coords = " .. object.coords)
    print("type = " .. object.type)
    print("scenario = " .. object.scenario)
    print("scenario2 = " .. object.scenario2)
    print("verticalOffset = " .. object.verticalOffset)
    print("forwardOffset = " .. object.forwardOffset)
    print("leftOffset = " .. object.leftOffset)
  end

  if object.type == "chair" then
    request('sit:getPlace', function(occupied)
      if occupied then
        utils.ui.showNotification(_U('sit:taken'))
      else
        module.LastPos, module.CurrentSitCoords = GetEntityCoords(PlayerPedId()), object.coords
        TaskGoStraightToCoord(PlayerPedId(), object.coords.x, object.coords.y, object.coords.z - tonumber(object.verticalOffset), 0.5, 2000, GetEntityHeading(object.name) + 180.0, 0)
        Wait(2000)

        emitServer('sit:takePlace', object.coords)
        FreezeEntityPosition(object.name, true)
        module.CurrentScenario = object.scenario
        TaskStartScenarioAtPosition(PlayerPedId(), module.CurrentScenario, object.coords.x, object.coords.y, object.coords.z - tonumber(object.verticalOffset), GetEntityHeading(object.name) + 180.0, 0, true, true)
        Wait(1000)
        FreezeEntityPosition(PlayerPedId(), true)
        module.Sitting = true
      end
    end)
  elseif object.type == "bed" then
    request('sit:getPlace', function(occupied)
      if occupied then
        utils.ui.showNotification(_U('sit:taken'))
      else
        module.LastPos, module.CurrentSitCoords = GetEntityCoords(PlayerPedId()), object.coords
        emitServer('sit:takePlace', object.coords)
        FreezeEntityPosition(object.name, true)
        module.CurrentScenario = object.scenario

        TaskStartScenarioAtPosition(PlayerPedId(), module.CurrentScenario, object.coords.x, object.coords.y, object.coords.z - tonumber(object.verticalOffset), GetEntityHeading(object.name) + 180.0, 0, true, true)
        Wait(1000)
        FreezeEntityPosition(PlayerPedId(), true)
        module.Sitting = true
      end
    end)
  end
end

module.LieDown = function(object)

  if module.Config.Debug then
    print("name = " .. object.name)
    print("type = " .. object.type)
    print("coords = " .. object.coords)
    print("type = " .. object.type)
    print("scenario = " .. object.scenario)
    print("scenario2 = " .. object.scenario2)
    print("verticalOffset = " .. object.verticalOffset)
    print("forwardOffset = " .. object.forwardOffset)
    print("leftOffset = " .. object.leftOffset)
  end

  request('sit:getPlace', function(occupied)
    if occupied then
      utils.ui.showNotification(_U('sit:taken'))
    else
      module.LastPos, module.CurrentSitCoords = GetEntityCoords(PlayerPedId()), object.coords
      emitServer('sit:takePlace', object.coords)
      FreezeEntityPosition(object.name, true)
      module.CurrentScenario = object.scenario2

      TaskStartScenarioAtPosition(PlayerPedId(), module.CurrentScenario, object.coords.x, object.coords.y, object.coords.z - tonumber(object.verticalOffset), GetEntityHeading(object.name), -1, true, true)
      FreezeEntityPosition(PlayerPedId(), true)
      module.Sitting = true
    end
  end)
end

module.SwitchPositions = function(object)
  if module.CurrentScenario == object.scenario then
    module.CurrentScenario = object.scenario2
    TaskStartScenarioAtPosition(PlayerPedId(), module.CurrentScenario, object.coords.x, object.coords.y, object.coords.z - tonumber(object.verticalOffset), GetEntityHeading(object.name), 0, true, true)
  elseif module.CurrentScenario == object.scenario2 then
    module.CurrentScenario = object.scenario
    TaskStartScenarioAtPosition(PlayerPedId(), module.CurrentScenario, object.coords.x, object.coords.y, object.coords.z - tonumber(object.verticalOffset), GetEntityHeading(object.name), 0, true, true)
  end
end
