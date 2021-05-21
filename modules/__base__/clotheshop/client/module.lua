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

M('events')
M('serializable')
M('cache')
M('ui.menu')

local Interact = M('interact')
local Input    = M('input')
local HUD      = M('game.hud')
local utils    = M("utils")
local camera   = M("camera")
local skin     = M("skin")

on('ui.menu.mouseChange', function(value)
  if module.IsInShopMenu then
		camera.setMouseIn(value)
	end
end)

-----------------------------------------
--                INIT                 --
-----------------------------------------

module.Saved, module.SavedDrawableVariation, module.SavedTextureVariation, module.SavedPaletteVariation = nil, nil, nil, nil
module.inMarker, module.InteractRegistered, module.IsInShopMenu, module.Exited = false, false, false, true
module.DrawableIndex, module.TextureIndex, module.PaletteIndex = 0, 0, 0
module.DrawableId, module.TextureId, module.ComponentId = 0, 0, 0

module.Config = run('data/config.lua', {vector3 = vector3})['Config']

module.Init = function()

  local translations = run('data/locales/' .. Config.Locale .. '.lua')['Translations']
  LoadLocale('clotheshop', Config.Locale, translations)

  module.RegisterControls()

  for k,v in pairs(module.Config.Ponsonbys) do
    if v ~= nil then
			local blip = AddBlipForCoord(v)

			SetBlipSprite(blip, 73)
			SetBlipDisplay(blip, 4)
			SetBlipScale(blip, 1.0)
      SetBlipColour(blip, 4)
      SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(_U('clotheshop:ponsonbys'))
      EndTextCommandSetBlipName(blip)
    end
  end

  for k,v in pairs(module.Config.SubUrban) do
    if v ~= nil then
			local blip = AddBlipForCoord(v)

			SetBlipSprite(blip, 73)
			SetBlipDisplay(blip, 4)
			SetBlipScale(blip, 1.0)
      SetBlipColour(blip, 30)
      SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(_U('clotheshop:suburban'))
      EndTextCommandSetBlipName(blip)
    end
  end

  for k,v in pairs(module.Config.Binco) do
    if v ~= nil then
			local blip = AddBlipForCoord(v)

			SetBlipSprite(blip, 73)
			SetBlipDisplay(blip, 4)
			SetBlipScale(blip, 1.0)
      SetBlipColour(blip, 69)
      SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(_U('clotheshop:binco'))
      EndTextCommandSetBlipName(blip)
    end
  end

  for k,v in pairs(module.Config.DiscountStore) do
    if v ~= nil then
			local blip = AddBlipForCoord(v)

			SetBlipSprite(blip, 73)
			SetBlipDisplay(blip, 4)
			SetBlipScale(blip, 1.0)
      SetBlipColour(blip, 81)
      SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(_U('clotheshop:discountstore'))
      EndTextCommandSetBlipName(blip)
    end
  end

  for k,v in pairs(module.Config.MovieMasks) do
    if v ~= nil then
			local blip = AddBlipForCoord(v)

			SetBlipSprite(blip, 362)
			SetBlipDisplay(blip, 4)
			SetBlipScale(blip, 1.0)
      SetBlipColour(blip, 2)
      SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(_U('clotheshop:moviemasks'))
      EndTextCommandSetBlipName(blip)
    end
  end

  for k,v in pairs(module.Config.Shops) do
    for j,r in pairs(v) do
      for m,n in pairs(r) do
        local key = 'clotheshop:' .. k .. ':' .. j .. ':' .. m

        Interact.Register({
          name = key,
          type = 'marker',
          distance = module.Config.DrawDistance,
          radius = 1.0,
          pos = n.Pos,
          heading = n.Heading,
          size = module.Config.Size.z,
          mtype = module.Config.Type,
          color = module.Config.Color,
          rotate = true,
          bobUpAndDown = false,
          faceCamera   = true,
          groundMarker = true,
          clothes = j,
          store = k
        })

        on('esx:interact:enter:' .. key, function(data)
          Interact.ShowHelpNotification(_U('clotheshop:press_menu', data.clothes, data.store))

          module.CurrentAction = function()
            if utils.game.isFreemodeModel(GetEntityModel(PlayerPedId())) then
              emit('clotheshop:openShopMenu', data.store, data.clothes, data.pos, data.heading)
            end
          end

          module.Exited = false
        end)

        on('esx:interact:exit:' .. key, function()
          Interact.StopHelpNotification()
          module.CurrentAction = nil

          module.Exited = true
        end)
      end
    end
  end
end

-----------------------------------------
--                 Menu                --
-----------------------------------------

module.ActivateShopMenu = function(action, ...)
  module.OpenShopMenu(action, ...)
end

module.EnterShop = function(pos, heading)
  module.IsInShopMenu = true
  camera.start()
  camera.resetCamera()
  TaskGoStraightToCoord(PlayerPedId(), pos.x, pos.y, pos.z, 0.5, 2000, heading, 0)
  module.SetCamera(SKEL_ROOT)
  Interact.StopHelpNotification()
end

module.OpenShopMenu = function(store, clothes, pos, heading)
  module.EnterShop(pos, heading)

  module.DrawableId = module.Config.Components[store][clothes][1]["drawableId"]
  
  if clothes == "Masks" then
    module.SetCamera(SKEL_Head)
    module.ComponentId = 1
  elseif clothes == "Arms" then
    module.SetCamera(SKEL_ROOT)
    module.ComponentId = 3
  elseif clothes == "Legs" then
    module.SetCamera(SKEL_ROOT)
    module.ComponentId = 4
  elseif clothes == "Bags" then
    module.SetCamera(SKEL_ROOT)
    module.ComponentId = 5
  elseif clothes == "Shoes" then
    module.SetCamera(SKEL_ROOT)
    module.ComponentId = 6
  elseif clothes == "Accessories" then
    module.SetCamera(SKEL_ROOT)
    module.ComponentId = 7
  elseif clothes == "Undershirt" then
    module.SetCamera(SKEL_ROOT)
    module.ComponentId = 8
  elseif clothes == "Body Armor" then
    module.SetCamera(SKEL_ROOT)
    module.ComponentId = 9
  elseif clothes == "Decals" then
    module.SetCamera(SKEL_ROOT)
    module.ComponentId = 10
  elseif clothes == "Top" then
    module.SetCamera(SKEL_ROOT)
    module.ComponentId = 11
  end

  if not module.Saved then
    module.Saved = true
    if not module.SavedDrawableVariation then
      module.SavedDrawableVariation = GetPedDrawableVariation(PlayerPedId(), module.ComponentId)
    end

    if not module.SavedTextureVariation then
      module.SavedTextureVariation  = GetPedTextureVariation(PlayerPedId(), module.ComponentId)
    end
  end

  module.clotheshopMenu = Menu(store..":"..clothes, {
    title = store .. " | " .. clothes,
    float = 'top|left',
    items = {
      {name = 'drawable', label = clothes .. " Type", type = 'slider', value = module.GetDrawableValue(store, clothes), min = 1, max = #module.Config.Components[store][clothes]},
      {name = 'texture',  label = "Texture: " .. module.GetTextureLabel() .. "/16",  type = 'slider', value = module.GetTextureValue(store, clothes),   max = 16},
      {name = 'buy',    label = 'Buy',   type = 'button'},
      {name = 'exit',   label = 'Exit',  type = 'button'}
    }
  })

  module.clotheshopMenu:on('item.change', function(item, index)
    PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FREEMODE_SOUNDSET", 1)

    if item.name == "drawable" then
      module.RestoreOutfit(store, clothes, module.ComponentId, false)
      module.OnDrawableChanged(store, clothes, item, module.ComponentId)
      item.label = module.GetDrawableLabel(store, clothes)
    elseif item.name == "texture" then
      module.OnTextureChanged(store, clothes, item, module.ComponentId)
      item.label = "Texture: " .. module.GetTextureValue(store, clothes) .. "/16"
    end
  end)

  module.clotheshopMenu:on('item.click', function(item, index)
    PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FREEMODE_SOUNDSET", 1)

    if item.name == 'exit' then
      module.RestoreOutfit(store, clothes, module.ComponentId, true)
      module.Exit()

      if not module.Exited then
        Interact.ShowHelpNotification(_U('clotheshop:press_menu', clothes, store))
        
        module.CurrentAction = function()
          emit('clotheshop:openShopMenu', store, clothes, pos, heading)
        end
      end
    elseif item.name == "buy" then
      skin.SaveUpdatedComponent(module.ComponentId, module.DrawableId, module.TextureId)
      -- skin.alterSkinComponent(module.ComponentId, module.DrawableId, module.TextureId)
      module.ExitAfterBuying(store, clothes)

      if not module.Exited then
        Interact.ShowHelpNotification(_U('clotheshop:press_menu', clothes, store))
        
        module.CurrentAction = function()
          emit('clotheshop:openShopMenu', store, clothes, pos, heading)
        end
      end
    end
  end)
end

module.Exit = function()
  module.clotheshopMenu:destroy()
  module.clotheshopMenu = nil
  module.IsInShopMenu   = false
  module.DrawableIndex  = nil
  module.TextureIndex   = nil
  module.DrawableId     = 1
  module.TextureId      = 0
  module.PaletteId      = 0
  module.ComponentId    = 0

  camera.destroy()
  module.stopanim()
end

module.ExitAfterBuying = function(store, clothes)
  module.clotheshopMenu:destroy()
  module.clotheshopMenu = nil
  module.IsInShopMenu   = false
  module.DrawableIndex  = nil
  module.TextureIndex   = nil
  module.DrawableId     = 1
  module.TextureId      = 0
  module.PaletteId      = 0
  module.ComponentId    = 0

  Wait(500)
  utils.game.StartTempAnimation("clothingshirt","try_shirt_positive_d",2000,2)

  camera.destroy()
  module.stopanim()
end

module.OnDrawableChanged = function(store, clothes, item, componentId)
  module.DrawableIndex = item.value
  module.CommitDrawable(store, clothes, item, componentId, module.DrawableIndex)
end

module.OnTextureChanged = function(store, clothes, item, componentId)
  module.TextureIndex = item.value
  module.CommitTexture(store, clothes, item, componentId, module.TextureIndex)
end

module.CommitDrawable = function(store, clothes, item, componentId, index)
  module.DrawableId = module.Config.Components[store][clothes][index]["drawableId"]

  if IsPedComponentVariationValid(PlayerPedId(), componentId, module.DrawableId, module.TextureId) then
    SetPedComponentVariation(PlayerPedId(), componentId, module.DrawableId, module.TextureId, 0)
  end
end

module.CommitTexture = function(store, clothes, item, componentId, index)
  module.TextureId = index

  if IsPedComponentVariationValid(PlayerPedId(), componentId, module.DrawableId, module.TextureId) then
    SetPedComponentVariation(PlayerPedId(), componentId, module.DrawableId, module.TextureId, 0)
  end
end

-----------------------------------------
--                Logic                --
-----------------------------------------

module.RestoreOutfit = function(store, clothes, componentId, destroy)
  if module.Saved then
    if IsPedComponentVariationValid(PlayerPedId(), componentId, module.SavedDrawableVariation, module.SavedTextureVariation, module.SavedPaletteVariation) then
      SetPedComponentVariation(PlayerPedId(), componentId, module.SavedDrawableVariation, module.SavedTextureVariation, module.SavedPaletteVariation)
    end

    if destroy then
      module.Saved                  = nil
      module.SavedDrawableVariation = nil
      module.SavedTextureVariation  = nil
      module.SavedPaletteVariation  = nil
    end
  end
end

module.GetDrawableValue = function(store, clothes)
  return module.DrawableId
end

module.GetTextureValue = function(store, clothes)
  return module.TextureId
end

module.GetPaletteValue = function(store, clothes)
  return module.PaletteId
end

module.GetDrawableLabel = function(store, clothes)
  if module.Config[clothes] then
    if module.Config[clothes][module.DrawableId] then
      return module.Config[clothes][module.DrawableId] .. " ($" .. module.GetPrice(store, clothes) .. ")"
    else
      return module.DrawableId
    end
  else
    return module.DrawableId
  end
end

module.GetTextureLabel = function(store, clothes)
  return module.TextureId
end

module.GetPaletteLabel = function(store, clothes)
  return module.PaletteId
end

module.GetDrawableId = function(store, clothes)
  return module.DrawableId
end

module.GetTextureId = function(store, clothes)
  return module.DrawableId
end

module.GetPaletteId = function(store, clothes)
  return module.DrawableId
end

module.GetPrice = function(store, clothes)
  if module.Config.Components[store][clothes][module.DrawableIndex]["price"] then
    return module.Config.Components[store][clothes][module.DrawableIndex]["price"]
  else
    return module.Config.DefaultPrice
  end
end

module.RegisterControls = function()
  Input.RegisterControl(Input.Groups.MOVE, Input.Controls.PICKUP)
  Input.RegisterControl(Input.Groups.MOVE, Input.Controls.REPLAY_SHOWHOTKEY)
  Input.RegisterControl(Input.Groups.MOVE, Input.Controls.SPRINT)
  Input.RegisterControl(Input.Groups.MOVE, Input.Controls.JUMP)
end

module.stopanim = function()
  ClearPedTasks(PlayerPedId())
end

module.SetCamera = function(bone)
  local pedCoords = GetEntityCoords(PlayerPedId())
  local forward   = GetEntityForwardVector(PlayerPedId())

  camera.setRadius(2.25)
  camera.setCoords(pedCoords + forward * 1.25)
  camera.setPolarAzimuthAngle(utils.math.world3DtoPolar3D(pedCoords, pedCoords + forward * 1.25))
  camera.pointToBone(bone, vector3(0.0,0.0,0.0))
end