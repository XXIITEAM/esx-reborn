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

module.Effects = {
  NONE      = 0,
  WEED      = 1,
  COCAINE   = 2,
  METH      = 3,
  HEROIN    = 4,
  DRUNK     = 5,
  STRESS    = 6,
  LOW       = 7,
  DYING     = 8
}

module.Anims = {
  DYING           = "MOVE_M@DRUNK@MODERATEDRUNK_HEAD_UP",
  BUZZED          = "MOVE_M@BUZZED",
  SLIGHTLYDRUNK   = "MOVE_M@DRUNK@SLIGHTLYDRUNK",
  DRUNK           = "MOVE_M@DRUNK@A",
  VERYDRUNK       = "MOVE_M@DRUNK@VERYDRUNK"
}

module.StatusEffectActive = module.Effects.NONE

module.Ready, module.Frame, module.Sick, module.CurrentAnimSet, module.CurrentStrength = false, nil, false, false, nil, 0

module.Frame = Frame('status', 'https://cfx-nui-' .. __RESOURCE__ .. '/modules/__core__/status/data/html/index.html', true)

module.Frame:on('load', function()
  module.Ready = true
  emit('status:ready')
end)


module.UpdateStatus = function(statuses)

  module.Frame:postMessage({
    app = "STATUS",
    method = "setStatus",
    data = statuses
  })

end

module.StatCheck = function(low, dying, drunk, drugName, drugs, stress)

  if Config.Modules.Status.UseEffects then

    if not dying and not low and drunk == 0 and drugs == 0 and stress == 0 then
      module.ClearStatus()
    elseif dying then
      module.Dying()
    elseif low then
      module.Low()
    elseif stress > 0 and (stress >= drunk or stress >= drugs) then
      module.Stress(stress)
    elseif drunk > 0 and drunk >= drugs then
      module.Drunk(drunk)
    elseif drugs > 0 then
      module.Drugs(drugName, drugs)
    end

  else

    if dying then
      ApplyDamageToPed(PlayerPedId(), 10, false)
    end

  end
end

--------------------------------------------------------------
--                    Status Effects                        --
--------------------------------------------------------------

module.Dying = function()

  local playerPed = PlayerPedId()

  if module.StatusEffectActive ~= module.Effects.DYING then

    module.StatusEffectActive = module.Effects.DYING
    SetPedMoveRateOverride(playerPed,0.8)
    SetRunSprintMultiplierForPlayer(playerPed,0.8)
    utils.game.LoopModifier("REDMIST_blend", 16, 0.02, 0.0, 1.0)
    utils.game.StartAttitude(module.Anims.DYING, module.Anims.DYING)

  else

    if math.random(0,100) < Config.Modules.Status.TripChance then
      module.Trip(2000)
    end

  end

  ApplyDamageToPed(playerPed, 10, false)

end

module.Low = function()

  if module.StatusEffectActive ~= module.Effects.LOW then

    if module.StatusEffectActive == module.Effects.Dying then
      RemoveAnimSet(module.Anims.DYING)
    end

    module.StatusEffectActive = module.Effects.LOW
    utils.game.LoopModifier("BlackOut", 100, 0.02, 0.0, 0.5)

  else

    if math.random(0,100) < Config.Modules.Status.FacePalmChance then
      utils.game.StartTempAnimation("anim@mp_player_intupperface_palm","idle_a",4000,49)
    end

  end

end

module.ClearStatus = function()

  if module.StatusEffectActive > module.Effects.NONE then


    if module.StatusEffectActive == module.Effects.DYING then
      local playerPed = PlayerPedId()
      RemoveAnimSet(module.Anims.DYING)
      SetPedMoveRateOverride(playerPed, 1.0)
      SetRunSprintMultiplierForPlayer(playerPed,1.0)
      utils.game.BreakLoopModifier()
    elseif module.StatusEffectActive == module.Effects.LOW then
      utils.game.BreakLoopModifier()
    end

    module.Init()

  end

end

module.Stress = function(value)
  module.StatusEffectActive = module.Effects.STRESS
end

module.Drunk = function(drunk)

  local playerPed = PlayerPedId()

  local clipset  = nil
  local max      = nil
  local sick     = 0
  local fall     = 0

  if module.StatusEffectActive ~= module.Effects.DRUNK and drunk >= 10 then
    SetPedConfigFlag(playerPed, 100, true)
    SetPedIsDrunk(playerPed, true)
    module.StatusEffectActive = module.Effects.DRUNK
  end

  if drunk <= 9 then
    if module.CurrentModifier then
      utils.game.FadeOutModifier(100, 0.0025)
      module.CurrentModifier = nil
      module.CurrentStrength = 0
    end

    SetPedConfigFlag(playerPed, 100, false)
    SetPedIsDrunk(playerPed, false)
    module.StatusEffectActive = module.Effects.NONE

    if module.CurrentAnimSet then
      RemoveAnimSet(module.CurrentAnimSet)
      module.CurrentAnimSet = nil
    end
    ResetPedMovementClipset(playerPed, 0.0)

  elseif drunk >= 10 and drunk <= 24 then
    clipset  = module.Anims.BUZZED
    max      = 0.2
  elseif drunk >= 25 and drunk <= 49 then
    clipset  = module.Anims.SLIGHTLYDRUNK
    max      = 0.3
  elseif drunk >= 50 and drunk <= 75 then
    clipset  = module.Anims.DRUNK
    max      = 0.5
    fall     = math.random(10,100)
    sick     = math.random(10,100)
  elseif drunk >= 76 and drunk <= 89 then
    clipset  = module.Anims.VERYDRUNK
    max      = 0.75
    fall     = math.random(20,100)
    sick     = math.random(20,100)
  elseif drunk >= 90 and drunk <= 100 then
    clipset  = module.Anims.VERYDRUNK
    max      = 1.0
    fall     = math.random(25,100)
    sick     = math.random(35,100)
  end

  if max and module.CurrentStrength ~= max then
    module.CurrentStrength = max
    module.IsDrunk("Drunk", 50, 0.0025, max)
  end

  if clipset then

    if module.CurrentAnimSet ~= clipset then
      RemoveAnimSet(module.CurrentAnimSet)
      module.CurrentAnimSet = clipset
    end

    utils.game.StartAttitude(module.CurrentAnimSet, module.CurrentAnimSet)

  end

  if sick > 55 then
    if IsPedInAnyVehicle(playerPed, false) then
      local veh = GetVehiclePedIsIn(playerPed)

      if GetPedInVehicleSeat(veh, -1) == playerPed then
        module.DrunkDriving(veh)
      end
    else
      module.DrunkEffects(fall, sick)
    end
  end

end

module.Weed = function(value)
  module.StatusEffectActive = module.Effects.WEED
end

module.Cocaine = function(value)
  module.StatusEffectActive = module.Effects.COCAIN
end

module.Meth = function(value)
  module.StatusEffectActive = module.Effects.METH
end

module.Heroin = function(value)
  module.StatusEffectActive = module.Effects.HEROIN
end

--------------------------------------------------------------
--                     Other Functions                      --
--------------------------------------------------------------

module.IsDrunk = function(modifier, speed, amount, max)
  module.CurrentModifier = modifier
  utils.game.FadeInModifier(modifier, speed, amount, max)
end

module.DrunkEffects = function(fallChance,sickChance)
  if sickChance >= (100 - Config.Modules.Status.SickChance) then
    module.Sick = true
    utils.game.StartTempAnimation("oddjobs@taxi@tie","vomit_outside",8000,49)
    ApplyDamageToPed(PlayerPedId(), 1, false)
  else
    module.Sick = false
  end

  if fallChance >= 75 and not module.Sick then
    module.Trip(2000)
  end

end

module.Drugs = function(name, value)
  if name == "weed" then
    module.Weed(value)
  elseif name == "cocaine" then
    module.Cocaine(value)
  elseif name == "meth" then
    module.Meth(value)
  elseif name == "heroin" then
    module.Heroin(value)
  end
end

module.DrunkDriving = function(veh)
  local generateRandomDrunkDrivingEvent = math.random(1, #Config.Modules.Status.RandomEvents)
  local randomDrunkEvent                = Config.Modules.Status.RandomEvents[generateRandomDrunkDrivingEvent]

  TaskVehicleTempAction(PlayerPedId(), veh, randomDrunkEvent.action, randomDrunkEvent.duration)
end

module.Trip = function(time)

  local playerPed = PlayerPedId()

  if not IsPedInVehicle(playerPed, GetVehiclePedIsIn(playerPed), false) then
    local shakeIntensity = math.random(1,10) * 0.1
    ShakeGameplayCam("DEATH_FAIL_IN_EFFECT_SHAKE", shakeIntensity)
    SetPedToRagdoll(playerPed, time, time, 0, 0, 0, 0)
    DisableAllControlActions(0)
    ApplyDamageToPed(playerPed, 1, false)
    Wait(time)
    EnableAllControlActions(0)
  end
end

module.Init = function()
  RemoveAnimSet(module.CurrentAnimSet)
  module.CurrentAnimSet = nil
  module.StatusEffectActive = module.Effects.NONE
  utils.game.ClearModifiers()
  ResetPedMovementClipset(PlayerPedId(), 0.0)
end
