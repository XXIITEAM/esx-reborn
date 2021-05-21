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

M('ui.menu')
M('events')

local utils = M('utils')

module.InAnim = false
module.Config = run('data/config.lua', {vector3 = vector3})['Config']

module.Init = function()
  local translations = run('data/locales/' .. Config.Locale .. '.lua')['Translations']
  LoadLocale('animations', Config.Locale, translations)
end

module.StartAttitude = function(lib, anim)
  utils.game.StartAttitude(lib, anim)
end

module.StartAnim = function(lib, anim)
  module.InAnim = true
  utils.game.LoopAnimation(lib, anim, -1, 0)
end

module.StartScenario = function(anim)
  module.InAnim = true
  utils.game.StartScenarioInPlace(anim)
end

module.OpenAnimationsMenu = function()
  module.MenuOpen = true
  local items = {}

  for k,_ in pairs(module.Config.Animations) do
    items[#items + 1] = {type= 'button', name = k, label = _U('animations:'..k)}
  end

  items[#items + 1] = {type= 'button', name = 'exit', label = '>> ' .. _U('exit') .. ' <<'}

	module.AnimationsMenu = Menu("animations", {
		title = _U('animations:main_title'),
		float = 'top|left',
		items = items
	})

	module.AnimationsMenu:on('item.click', function(item, index)
		PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FREEMODE_SOUNDSET", 1)

		if item.name == 'exit' then
      module.Exit()
		else
      module.OpenAnimationsSubMenu(item.name)
		end
	end)
end

module.OpenAnimationsSubMenu = function(category)
  local items = {}

  for k,v in ipairs(module.Config.Animations[category]) do
    items[#items + 1] = {type= 'button', name = v.name, label = _U('animations:'..v.name), data = v.data, action = v.type}
  end

  items[#items + 1] = {type= 'button', name = 'back', label = '>> ' .. _U('back') .. ' <<'}
  items[#items + 1] = {type= 'button', name = 'exit', label = '>> ' .. _U('exit') .. ' <<'}

  if module.AnimationsMenu.visible then
    module.AnimationsMenu:hide()
  end

  module.AnimationsSubMenu = Menu("animations:sub", {
		title = _U('animations:'..category),
		float = 'top|left',
		items = items
  })

  module.AnimationsSubMenu:on('item.click', function(item, index)
		PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FREEMODE_SOUNDSET", 1)

    if item.name == 'exit' then
      module.ExitFromSubMenu()
    elseif item.name == 'back' then
      module.BackToMainMenu()
    else
      if item.action == "anim" then
        module.StartAnim(item.data.lib, item.data.anim)
      elseif item.action == "scenario" then
        module.StartScenario(item.data.anim)
      elseif item.action == "attitude" then
        module.StartAttitude(item.data.lib, item.data.anim)
      end

      module.ExitFromSubMenu()
		end
	end)
end

module.BackToMainMenu = function()
  if module.AnimationsSubMenu then
    module.AnimationsSubMenu:destroy()
  end

  if module.AnimationsMenu then
    module.AnimationsMenu:show()
    module.AnimationsMenu:focus()
  end
end

module.Exit = function()
  if module.AnimationsMenu then
    module.AnimationsMenu:destroy()
  end

  module.MenuOpen = false
end

module.ExitFromSubMenu = function()
  if module.AnimationsSubMenu then
    module.AnimationsSubMenu:destroy()
  end

  if module.AnimationsMenu then
    module.AnimationsMenu:destroy()
  end

  module.MenuOpen = false
end