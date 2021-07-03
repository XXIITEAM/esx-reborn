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

onRequest("vehicleshop:isAnyoneInShopMenu", function(source, cb)
  if module.ShopInUse then
    cb(true)
  else
    module.Updated   = true
    module.ShopInUse = true
    cb(nil)
  end
end)

onClient('vehicleshop:stillUsingMenu', function()
  module.Updated = true
end)

onClient('vehicleshop:exitedMenu', function()
  module.Updated   = false
  module.ShopInUse = false
end)