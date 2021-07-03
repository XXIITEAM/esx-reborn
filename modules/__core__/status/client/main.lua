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


-- ESX.SetInterval(1, function()
--     if module.Injured then
--         SetPedMovementClipset(PlayerPedId(), "move_m@injured", true)
--         SetPedMoveRateOverride(PlayerPedId(),0.9)
--         SetRunSprintMultiplierForPlayer(PlayerPedId(),0.9)
--     else
--         Wait(999)
--     end
-- end)

ESX.SetInterval(1, function()
  if module.StatusEffectActive == module.Effects.DYING then
    DisableControlAction(0,21,true)
  else
    Wait(999)
  end
end)

ESX.SetInterval(50, function()
  if Config.Modules.Status.UseExperimental then
    if module.StatusEffectActive == module.Effects.DYING then
      if not module.soundPlaying then
        module.soundID = GetSoundId()
        module.soundPlaying = true
        PlaySoundFrontend(module.soundID, "SwitchRedWarning", "SPECIAL_ABILITY_SOUNDSET", 0)
      end
    else
      if module.soundPlaying then
        module.soundPlaying = false
        StopSound(module.soundID)
        ReleaseSoundId(module.soundID)
      end
    end
  end
end)
