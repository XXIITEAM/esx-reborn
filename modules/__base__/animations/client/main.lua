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

module.Config = run('data/config.lua', {vector3 = vector3})['Config']

module.Init()

ESX.SetInterval(1, function()
	if IsControlJustPressed(0, module.Config.OpenMenuKey) and IsInputDisabled(0) and not module.MenuOpen then
		module.OpenAnimationsMenu()
	end

  if IsControlJustPressed(0, module.Config.CancelAnimKey) and IsInputDisabled(0) and module.InAnim then
    ClearPedTasks(PlayerPedId())
    module.InAnim = false
	end
end)