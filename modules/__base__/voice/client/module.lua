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

local Input = M('input')

module.Init = function()
  Input.RegisterControl(1, 74)
  Input.RegisterControl(1, 21)
  local translations = run('data/locales/' .. Config.Locale .. '.lua')['Translations']
  LoadLocale('voice', Config.Locale, translations)
  module.voice = {default = 5.0, shout = 12.0, whisper = 1.0, current = 0, level =  _U('voice:normal')}
end

module.DrawLevel = function(r,g,b,a)
	SetTextFont(4)
	SetTextScale(0.5, 0.5)
	SetTextColour(r, g, b, a)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()

	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(_U('voice:voice', module.voice.level))
	EndTextCommandDisplayText(0.175, 0.92)
end
