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

M('events')
M('constants')
local utils  = M("utils")
local camera = M("camera")

module.Components = {
  PV_COMP_BERD,
  PV_COMP_UPPR,
  PV_COMP_LOWR,
  PV_COMP_HAND,
  PV_COMP_FEET,
  PV_COMP_TEEF,
  PV_COMP_ACCS,
  PV_COMP_TASK,
  PV_COMP_DECL,
  PV_COMP_JBIB
}

module.Defaults = {
  gender = 'male', model = 'mp_m_freemode_01',
  -- Left Menu
  shapeFirstID = 0, shapeSecondID = 0, shapeThirdID = 0, skinFirstID = 0, skinSecondID = 0, skinThirdID = 0,
  shapeMix = 0.5, skinMix = 0.5, thirdMix = 0, eyeState = 0, eyeColor = 0, eyebrow = 1, eyebrowColor1 = 1,
  eyebrowWidth = 0, eyebrowShape = 0, eyebrowOpacity = 0.99, noseWidth = 0, noseHeight = 0, noseLength = 0,
  noseBridge = 0, noseTip = 0, chinLength = 0, chinPosition = 0, chinWidth = 0, chinHeight = 0, jawWidth = 0,
  jawHeight = 0, cheekboneHeight = 0, cheekboneWidth = 0, cheeksWidth = 0, lipsWidth = 0, neckThickness = 0,
  -- Right Menu
  blemishes = 0, freckles = 0, complexion = 0, blush = 0, blushColor = 0, blemishesOpacity = 0, frecklesOpacity = 0,
  complexionOpacity = 0, blushOpacity = 0, hair = 2, hairColor = 1, hairHighlightColor = 0, beard = 0, beardColor = 0,
  beardOpacity = 0, makeup = 0, lipstick = 0, lipstickColor = 0, makeupOpacity = 0, lipstickOpacity = 0, aging = 0,
  agingOpacity = 0, chesthair = 0, chesthairColor = 0, chesthairOpacity = 0, sunDamage = 0, bodyBlemishes = 0,
  moreBodyBlemishes = 0, sunDamageOpacity = 0, bodyBlemishesOpacity = 0, moreBodyBlemishesOpacity = 0,
  components = {
    [PV_COMP_BERD] = {0, 0},
    [PV_COMP_UPPR] = {15, 0},
    [PV_COMP_LOWR] = {28, 0},
    [PV_COMP_HAND] = {0, 0},
    [PV_COMP_FEET] = {5, 0},
    [PV_COMP_TEEF] = {0, 0},
    [PV_COMP_ACCS] = {15, 0},
    [PV_COMP_TASK] = {0, 0},
    [PV_COMP_DECL] = {1, 0},
    [PV_COMP_JBIB] = {15, 0}
  }
}

module.Humans  = table.concat({MP_M_FREEMODE_01, MP_F_FREEMODE_01}, table.filter(PED_MODELS_HUMANS, function(x) return (x ~= MP_M_FREEMODE_01) and (t ~= MP_F_FREEMODE_01) end))
module.Animals = table.clone(PED_MODELS_ANIMALS)
module.Mouse   = {down = {}, pos = {x = -1, y = -1}}
module.Ready, module.InMenu, module.HasSkin, module.SavedCoords, module.PedData = false, false, false, nil, {}

module.Init = function()
  while not module.Ready do
    Wait(0)
  end

  module.Frame:postMessage({
    type = "initData",
    hairColors = module.GetColorData(module.GetHairColors(), true),
    lipstickColors = module.GetColorData(module.GetLipstickColors(), false),
    blushColors = module.GetColorData(module.GetBlushColors(), false),
    humanPeds = #module.Humans - 1,
    animalPeds = #module.Animals - 1
  })
end

module.OpenCharacterCreator = function(byCommand)
  emit('esx:identity:preventSaving', true)

  if byCommand then
    utils.ui.showNotification("Opening skin menu...")
    DoScreenFadeOut(500)
	  Wait(750)
	  SetEntityCoords(PlayerPedId(), -269.4, -955.3, 31.2, 0.0, 0.0, 0.0, true)
    SetEntityHeading(PlayerPedId(), 205.8)
	  utils.game.UnloadCharacter()
	  Wait(500)
	  camera.start()
	  module.Frame:postMessage({ type = "open" })
	  Wait(500)
	  module.Open()
	  DoScreenFadeIn(1000)
	else
	  DoScreenFadeOut(500)
	  Wait(750)
	  module.HasSkin = false
	  module.CreateDefaultSkin()
	  module.PedData = module.Defaults
	  camera.start()
	  module.Frame:postMessage({ type = "open" })
	  Wait(500)
	  module.Open()
	  DoScreenFadeIn(1000)
	end
end

module.Open = function()
  module.Frame:focus(true)
  Wait(250)
  module.FaceCam()
end

module.MainCameraScene = function()
  local pedCoords = GetEntityCoords(PlayerPedId())
  local forward   = GetEntityForwardVector(PlayerPedId())

  camera.setRadius(2.5)
  camera.setCoords(pedCoords + forward * 1.25)
  camera.setPolarAzimuthAngle(utils.math.world3DtoPolar3D(pedCoords, pedCoords + forward * 1.25))

  camera.pointToBone(SKEL_Head)
end

module.Frame = Frame('skin', 'https://cfx-nui-' .. __RESOURCE__ .. '/modules/__core__/skin/data/html/index.html', true)

module.Frame:on('load', function()
  module.Ready = true
end)

module.Frame:on('message', function(msg)
  if msg.action == 'skin.confirm' then
    module.Confirm()
  elseif msg.action == 'mouse.move' then
    module.MouseMove(msg)
  elseif msg.action == 'mouse.wheel' then
    module.MouseWheel(msg)
  elseif msg.action == 'mouse.in' then
    camera.setMouseIn(true)
  elseif msg.action == 'mouse.out' then
    camera.setMouseIn(false)
  elseif msg.action == 'changeGender' then
    module.ChangeGender(msg)
  elseif msg.action == "changeModel" then
    module.ChangePed(msg)
  elseif msg.action == "changeComponent" then
    module.ChangeComponent(msg)
  end
end)

module.Confirm = function()
  module.InMenu = false
  module.Frame:unfocusAll()
  DoScreenFadeOut(1000)
  module.SavePlayerSkin()
  emit('esx:identity:preventSaving', false)
end

module.MouseMove = function(msg)
  local last = table.clone(module.Mouse)
  local data = table.clone(last)

  data.pos.x, data.pos.y = msg.data.x, msg.data.y

  if (last.x ~= -1) and (last.y ~= -1) then

    local offsetX = msg.data.x - last.pos.x
    local offsetY = msg.data.y - last.pos.y
    local data = {}
    data.down = {}

    if msg.data.leftMouseDown then
      data.down[0] = true
    else
      data.down[0] = false
    end

    if msg.data.rightMouseDown then
      data.down[2] = true
    else
      data.down[2] = false
    end

    data.direction = {left = offsetX < 0, right = offsetX > 0, up = offsetY < 0, down = offsetY > 0}
    emit('mouse:move:offset', offsetX, offsetY, data)
  end

  module.Mouse = data
end

module.MouseWheel = function(msg)
  emit('mouse:wheel', msg.data)
end

module.FaceCam = function()
  camera.setRadius(2.5)
  camera.pointToBone(SKEL_Head, vector3(0.0,0.0,0.0))
end

module.ChangeGender = function(msg)
  local value = tonumber(msg.data)

  if value == 0 then
    module.PedData.gender = "male"
  elseif value == 1 then
    module.PedData.gender = "female"
  elseif value == 2 then
    module.PedData.gender = "non-binary"
  end
end

module.ChangePed = function(msg)
  local value = tonumber(msg.data.value)

  module.PedData.model = PED_MODELS_BY_HASH[module.Humans[value + 1]]

  local skin = module.PedData

  module.LoadSkin(skin, false)
end

module.ChangeComponent = function(msg)
  local name       = msg.data.name
  local value      = tonumber(msg.data.value)

  module.PedData[name] = tonumber(value)

  local skin = module.PedData

  module.UpdateSkin(skin)
end

module.LoadSkin = function(skin, hasSkin)
  local model = skin.model
  local modelHash = GetHashKey(model)

  utils.game.requestModel(modelHash, function()
    if (utils.game.isFreemodeModel(model)) then
      SetPlayerModel(PlayerId(), modelHash)
      -- Heritage
      SetPedHeadBlendData(PlayerPedId(), skin.shapeFirstID, skin.shapeSecondID, skin.shapeThirdID, skin.skinFirstID, skin.skinSecondID, skin.skinThirdID, skin.shapeMix, skin.skinMix, skin.thirdMix, true)

      -- Features
      SetPedFaceFeature(PlayerPedId(), 0,  skin.noseWidth)
      SetPedFaceFeature(PlayerPedId(), 1,  skin.noseHeight)
      SetPedFaceFeature(PlayerPedId(), 2,  skin.noseLength)
      SetPedFaceFeature(PlayerPedId(), 3,  skin.noseBridge)
      SetPedFaceFeature(PlayerPedId(), 4,  skin.noseTip)
      SetPedFaceFeature(PlayerPedId(), 5,  skin.noseShift)
      SetPedFaceFeature(PlayerPedId(), 6,  skin.eyebrowWidth)
      SetPedFaceFeature(PlayerPedId(), 7,  skin.eyebrowShape)
      SetPedFaceFeature(PlayerPedId(), 8,  skin.cheekboneHeight)
      SetPedFaceFeature(PlayerPedId(), 9,  skin.cheekboneWidth)
      SetPedFaceFeature(PlayerPedId(), 10, skin.cheeksWidth)
      SetPedFaceFeature(PlayerPedId(), 11, skin.eyeState)
      SetPedFaceFeature(PlayerPedId(), 12, skin.lipsWidth)
      SetPedFaceFeature(PlayerPedId(), 13, skin.jawWidth)
      SetPedFaceFeature(PlayerPedId(), 14, skin.jawHeight)
      SetPedFaceFeature(PlayerPedId(), 15, skin.chinHeight)
      SetPedFaceFeature(PlayerPedId(), 16, skin.chinLength)
      SetPedFaceFeature(PlayerPedId(), 17, skin.chinWidth)
      SetPedFaceFeature(PlayerPedId(), 18, skin.chinPosition)
      SetPedFaceFeature(PlayerPedId(), 19, skin.neckThickness)

      -- Hair
      SetPedComponentVariation(PlayerPedId(), 2, skin.hair, 0, 2)
      -- Colors
      SetPedHairColor(PlayerPedId(), skin.hairColor, skin.hairHighlightColor)
      SetPedHeadOverlayColor(PlayerPedId(), 1, 1, skin.beardColor, 0)
      SetPedHeadOverlayColor(PlayerPedId(), 2, 1, skin.eyebrowColor, 0)
      SetPedHeadOverlayColor(PlayerPedId(), 5, 2, skin.blushColor, 0)
      SetPedHeadOverlayColor(PlayerPedId(), 8, 2, skin.lipstickColor, 0)
      SetPedHeadOverlayColor(PlayerPedId(), 10, 1, skin.chesthairColor, 0)
      SetPedEyeColor(PlayerPedId(), skin.eyeColor)

      -- Body Components
      SetPedHeadOverlay(PlayerPedId(), 0, skin.blemishes, skin.blemishesOpacity)
      SetPedHeadOverlay(PlayerPedId(), 1, skin.beard, skin.beardOpacity)
      SetPedHeadOverlay(PlayerPedId(), 2, skin.eyebrow, skin.eyebrowOpacity)
      SetPedHeadOverlay(PlayerPedId(), 3, skin.aging, skin.agingOpacity)
      SetPedHeadOverlay(PlayerPedId(), 4, skin.makeup, skin.makeupOpacity)
      SetPedHeadOverlay(PlayerPedId(), 5, skin.blush, skin.blushOpacity)
      SetPedHeadOverlay(PlayerPedId(), 6, skin.complexion, skin.complexionOpacity)
      SetPedHeadOverlay(PlayerPedId(), 7, skin.sunDamage, skin.sunDamageOpacity)
      SetPedHeadOverlay(PlayerPedId(), 8, skin.lipstick, skin.lipstickOpacity)
      SetPedHeadOverlay(PlayerPedId(), 9, skin.freckles, skin.frecklesOpacity)
      SetPedHeadOverlay(PlayerPedId(), 10, skin.chesthair, skin.chesthairOpacity)
      SetPedHeadOverlay(PlayerPedId(), 11, skin.bodyBlemishes, skin.bodyBlemishesOpacity)
      SetPedHeadOverlay(PlayerPedId(), 12, skin.moreBodyBlemishes, skin.moreBodyBlemishesOpacity)


      for componentId,component in pairs(skin.components) do
        SetPedComponentVariation(PlayerPedId(), componentId, component[1], component[2], 1)
      end
    else
      SetPedDefaultComponentVariation(PlayerPedId())
      SetPlayerModel(PlayerId(), modelHash)
      SetPedDefaultComponentVariation(PlayerPedId())
    end

    SetModelAsNoLongerNeeded(modelHash)
  end)

  SetEntityVisible(PlayerPedId(), true, false)

  if hasSkin then
    camera.destroy()
    utils.game.CharacterLoaded()
    emit('esx:characterLoaded')
    Citizen.Wait(1000)
    DoScreenFadeIn(1000)
  end
end

module.UpdateSkin = function(skin)
  local model = skin.model

  if (utils.game.isFreemodeModel(model)) then
    -- Heritage
    SetPedHeadBlendData(PlayerPedId(), skin.shapeFirstID, skin.shapeSecondID, skin.shapeThirdID, skin.skinFirstID, skin.skinSecondID, skin.skinThirdID, skin.shapeMix, skin.skinMix, skin.thirdMix, true)

    -- Features
    SetPedFaceFeature(PlayerPedId(), 0,  skin.noseWidth)
    SetPedFaceFeature(PlayerPedId(), 1,  skin.noseHeight)
    SetPedFaceFeature(PlayerPedId(), 2,  skin.noseLength)
    SetPedFaceFeature(PlayerPedId(), 3,  skin.noseBridge)
    SetPedFaceFeature(PlayerPedId(), 4,  skin.noseTip)
    SetPedFaceFeature(PlayerPedId(), 5,  skin.noseShift)
    SetPedFaceFeature(PlayerPedId(), 6,  skin.eyebrowWidth)
    SetPedFaceFeature(PlayerPedId(), 7,  skin.eyebrowShape)
    SetPedFaceFeature(PlayerPedId(), 8,  skin.cheekboneHeight)
    SetPedFaceFeature(PlayerPedId(), 9,  skin.cheekboneWidth)
    SetPedFaceFeature(PlayerPedId(), 10, skin.cheeksWidth)
    SetPedFaceFeature(PlayerPedId(), 11, skin.eyeState)
    SetPedFaceFeature(PlayerPedId(), 12, skin.lipsWidth)
    SetPedFaceFeature(PlayerPedId(), 13, skin.jawWidth)
    SetPedFaceFeature(PlayerPedId(), 14, skin.jawHeight)
    SetPedFaceFeature(PlayerPedId(), 15, skin.chinHeight)
    SetPedFaceFeature(PlayerPedId(), 16, skin.chinLength)
    SetPedFaceFeature(PlayerPedId(), 17, skin.chinWidth)
    SetPedFaceFeature(PlayerPedId(), 18, skin.chinPosition)
    SetPedFaceFeature(PlayerPedId(), 19, skin.neckThickness)

    -- Colors
    SetPedHairColor(PlayerPedId(), skin.hairColor, skin.hairHighlightColor)
    SetPedHeadOverlayColor(PlayerPedId(), 1, 1, skin.beardColor, 0)
    SetPedHeadOverlayColor(PlayerPedId(), 2, 1, skin.eyebrowColor, 0)
    SetPedHeadOverlayColor(PlayerPedId(), 5, 2, skin.blushColor, 0)
    SetPedHeadOverlayColor(PlayerPedId(), 8, 2, skin.lipstickColor, 0)
    SetPedHeadOverlayColor(PlayerPedId(), 10, 1, skin.chesthairColor, 0)
    SetPedEyeColor(PlayerPedId(), skin.eyeColor)

    -- Body Components
    SetPedHeadOverlay(PlayerPedId(), 0, skin.blemishes, skin.blemishesOpacity)
    SetPedHeadOverlay(PlayerPedId(), 1, skin.beard, skin.beardOpacity)
    SetPedHeadOverlay(PlayerPedId(), 2, skin.eyebrow, skin.eyebrowOpacity)
    SetPedHeadOverlay(PlayerPedId(), 3, skin.aging, skin.agingOpacity)
    SetPedHeadOverlay(PlayerPedId(), 4, skin.makeup, skin.makeupOpacity)
    SetPedHeadOverlay(PlayerPedId(), 5, skin.blush, skin.blushOpacity)
    SetPedHeadOverlay(PlayerPedId(), 6, skin.complexion, skin.complexionOpacity)
    SetPedHeadOverlay(PlayerPedId(), 7, skin.sunDamage, skin.sunDamageOpacity)
    SetPedHeadOverlay(PlayerPedId(), 8, skin.lipstick, skin.lipstickOpacity)
    SetPedHeadOverlay(PlayerPedId(), 9, skin.freckles, skin.frecklesOpacity)
    SetPedHeadOverlay(PlayerPedId(), 10, skin.chesthair, skin.chesthairOpacity)
    SetPedHeadOverlay(PlayerPedId(), 11, skin.bodyBlemishes, skin.bodyBlemishesOpacity)
    SetPedHeadOverlay(PlayerPedId(), 12, skin.moreBodyBlemishes, skin.moreBodyBlemishesOpacity)
    SetPedComponentVariation(PlayerPedId(), 2, skin.hair, 0, 2)
  end
end

module.SavePlayerSkin = function()
  local skin = module.PedData

  request('esx:skin:save', function()
    DoScreenFadeOut(1000)
    Wait(1000)
    if module.HasSkin then
      module.ReturnPlayer()
    else
      module.RespawnPlayer()
      module.HasSkin = true
    end
  end, skin.gender, skin)
end

module.SaveUpdatedSkin = function()
  local skin = module.PedData

  request('esx:skin:save', function()

  end, skin.gender, skin)
end

module.RespawnPlayer = function()
  SetEntityCoords(PlayerPedId(), -269.4, -955.3, 31.2, 0.0, 0.0, 0.0, true)
  SetEntityHeading(PlayerPedId(), 205.8)
  camera.destroy()
  utils.game.CharacterLoaded()
  emit('esx:characterLoaded')
  Wait(1000)
  DoScreenFadeIn(1000)
end

module.ReturnPlayer = function()
  camera.destroy()
  utils.game.CharacterLoaded()
  SetEntityCoords(PlayerPedId(), module.SavedCoords.x, module.SavedCoords.y, module.SavedCoords.z, 0.0, 0.0, 0.0, true)
  module.SavedCoords = nil
  Wait(1000)
  DoScreenFadeIn(1000)
end

module.CreateDefaultSkin = function()
  local skin      = module.Defaults
  local modelHash = GetHashKey(skin.model)

  utils.game.requestModel(modelHash, function()
    SetPlayerModel(PlayerId(), modelHash)

    if (utils.game.isFreemodeModel(skin.model)) then
      SetPedHeadBlendData(PlayerPedId(), skin.shapeFirstID, skin.shapeSecondID, skin.shapeThirdID, skin.skinFirstID, skin.skinSecondID, skin.skinThirdID, skin.shapeMix, skin.skinMix, skin.thirdMix, true)

      SetPedComponentVariation(PlayerPedId(), 2, skin.hair, 0, 2)
      SetPedHairColor(PlayerPedId(), skin.hairColor, skin.hairHighlightColor)
      SetPedHeadOverlay(PlayerPedId(), 2, skin.eyebrow, skin.eyebrowOpacity)
      SetPedHeadOverlayColor(PlayerPedId(), 2, 1, skin.eyebrowColor, 0)

      for componentId,component in pairs(skin.components) do
        SetPedComponentVariation(PlayerPedId(), componentId, component[1], component[2], 1)
      end
    end

    SetModelAsNoLongerNeeded(modelHash)
  end)

  module.MainCameraScene()
  SetEntityVisible(PlayerPedId(), true, false)
end

module.SaveUpdatedComponent = function(componentId, drawableId, textureId)
  if module.PedData.components[componentId] then
    module.PedData.components[componentId] = {tonumber(drawableId), tonumber(textureId)}
    module.SaveUpdatedSkin()
  end
end

module.GetLipstickColors = function()
  local result = {}
  local i = 0

  for i = 0, 31 do
      table.insert(result, i)
  end
  table.insert(result, 48)
  table.insert(result, 49)
  table.insert(result, 55)
  table.insert(result, 56)
  table.insert(result, 62)
  table.insert(result, 63)

  return result
end

module.GetHairColors = function()
  local result = {}
  local i = 0


  for i = 0, 63 do
      table.insert(result, i)
  end

  return result
end

module.GetFacepaintColors = function()
  local result = {}
  local i = 0

  for i = 0, 63 do
      table.insert(result, i)
  end

  return result
end

module.GetBlushColors = function()
  local result = {}
  local i = 0

  for i = 0, 22 do
      table.insert(result, i)
  end
  table.insert(result, 25)
  table.insert(result, 26)
  table.insert(result, 51)
  table.insert(result, 60)

  return result
end

module.ConvertToHex = function(r, g, b)
  local result = string.format('#%x', ((r << 16) | (g << 8) | b))
  return result
end

module.GetColorData = function(indexes, isHair)
  local result = {}
  local GetRgbColor = nil

  if isHair then
      GetRgbColor = function(index)
          return GetPedHairRgbColor(index)
      end
  else
      GetRgbColor = function(index)
          return GetPedMakeupRgbColor(index)
      end
  end

  for i, index in ipairs(indexes) do
      local r, g, b = GetRgbColor(index)
      local hex = module.ConvertToHex(r, g, b)
      table.insert(result, { index = index, hex = hex })
  end

  return result
end
