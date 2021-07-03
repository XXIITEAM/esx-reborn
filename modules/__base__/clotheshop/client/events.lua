
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

local Input = M('input')
local Menu = M('ui.menu')

on('esx_clotheshop:hasEnteredMarker', function(zone)

  module.CurrentAction = 'shop_menu'
  module.CurrentActionMsg = _U('clotheshop:press_menu')
  module.CurrentActionData = { }
end)

on('esx_clotheshop:hasExitedMarker', function(zone)

  Menu.CloseAll()
  module.CurrentAction = nil

end)

on('clotheshop:openShopMenu', function(...)
  module.ActivateShopMenu(...)
end)

-- Key Controls
Input.On('released', Input.Groups.MOVE, Input.Controls.PICKUP, function(lastPressed)

  if module.CurrentAction and not ESX.IsDead then
    module.CurrentAction()
    module.CurrentAction = nil
  end

end)
