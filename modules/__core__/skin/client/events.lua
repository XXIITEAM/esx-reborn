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

on('esx:ready', function()
  module.Init()
end)

onServer("esx:skin:openEditor", function()
  module.SavedCoords = GetEntityCoords(PlayerPedId(), true)
  module.OpenCharacterCreator(true)
end)

on("esx:skin:loadSkin", function(skin)
  if skin then
    module.HasSkin = true
    module.LoadSkin(skin, true)
    module.PedData = skin
  else
    module.HasSkin = false
    module.OpenCharacterCreator()
    module.PedData = module.Defaults
  end
end)
