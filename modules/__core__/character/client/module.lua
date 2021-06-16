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

local utils    = M('utils')
local identity = M('identity')
local camera   = M("camera")
M("table")

-- /config/default/config.character.lua, is it the right place ?
local characterConfig = Config.Modules.character

module.registrationMenu       = nil
module.characterSelectionMenu = nil
module.isInMenu               = false
module.CharacterSelected      = false

module.AreMenuInUse = function()
  return not(module.characterSelectionMenu.isDestroyed and module.characterSelectionMenu.isDestroyed)
end

module.OpenMenu = function(cb)

  utils.ui.showNotification(_U('identity_register'))

  module.registrationMenu = Menu("character_creation", {
    float = "center|middle",
    title = "Create Character",
    items = {
      {name = "firstName", label = "First name",    type = "text", placeholder = "John"},
      {name = "lastName",  label = "Last name",     type = "text", placeholder = "Smith"},
      {name = "dob",       label = "Date of birth", type = "text", placeholder = "01/02/1234"},
      {name = "submit",    label = "Submit",        type = "button"}
    }
  })

  module.registrationMenu:on("item.click", function(item, index)

    if item.name == "submit" then

      local props = module.registrationMenu:kvp()

      if (props.firstName ~= '') and (props.lastName ~= '') and (props.dob ~= '') then
        module.registrationMenu:destroy()

        request('esx:character:creation', cb, props)

        utils.ui.showNotification(_U('identity_welcome', props.firstName, props.lastName))
      else
        utils.ui.showNotification(_U('identity_fill_in'))
      end

    end

  end)

end

module.DoSpawn = function(data, cb)
  exports.spawnmanager:spawnPlayer(data, cb)
end

-- Temporary solution to preventing movement on resource restart
-- @TODO: Find a more permanent solution
module.InitiateCharacterSelectionSpawn = function()

  local spawnCoords = characterConfig.spawnCoords

  module.DoSpawn({
    x        = spawnCoords.x,
    y        = spawnCoords.y,
    z        = spawnCoords.z,
    heading  = spawnCoords.heading,
    model    = 'mp_m_freemode_01',
    skipFade = false
  })

  module.isInMenu = true

  Citizen.Wait(2000)

  ShutdownLoadingScreen()
  ShutdownLoadingScreenNui()

  local serverId = GetPlayerServerId(PlayerId())
  emitServer('utils:AddPlayerToHideList', serverId)
end

module.mainCameraScene = function()
  local ped       = PlayerPedId()
  local pedCoords = GetEntityCoords(ped)
  local forward   = GetEntityForwardVector(ped)

  camera.setRadius(1.25)
  camera.setCoords(pedCoords + forward * 1.25)
  camera.setPolarAzimuthAngle(utils.math.world3DtoPolar3D(pedCoords, pedCoords + forward * 1.25))

  camera.pointToBone(SKEL_ROOT)
end

module.RequestIdentitySelection = function(identities)

  -- TP the player to a spawn point defined in the config file
  module.InitiateCharacterSelectionSpawn()

  -- Start a camera on the player (skin preview)
  camera.start()
  module.mainCameraScene()

  -- Fetch the loaded player
  local player = ESX.Player

  local menuElements = {}

  if identities then
    -- for each identities, insert a button to select it
    menuElements = table.map(identities, function(identity)
      return {type = 'button', name = identity:getId(), label = identity:getFirstName() .. " " .. identity:getLastName(), identity = identity:serialize()}
    end)
  end

  table.insert(menuElements, {name = "register", label = ">> Create a New Identity <<", type = "button", shouldDestroyMenu = true})

  module.characterSelectionMenu = Menu('character.select', {
      title = 'Choose An Identity',
      float = 'top|left',
      items = menuElements
  })

  module.characterSelectionMenu:on('item.click', function(item)

    if item.name == 'register' then
      -- delegate to the identity module, responsible of the registration
      emit("esx:identity:openRegistration")

      module.characterSelectionMenu:hide()

      camera.stop()
      camera.setMouseIn(false)
    else
      request("esx:character:getSkin", function(skinContent)
        module.CharacterSelected = true
        if skinContent then
            module.SelectCharacter(item.name, item.label, item.identity, skinContent)
        else
          module.SelectCharacter(item.name, item.label, item.identity)
        end
      end, item.name)
    end
  end)
end

module.ReOpenCharacterSelect = function()
  module.characterSelectionMenu:show()
  module.characterSelectionMenu:focus()
  camera.start()
  module.mainCameraScene()
  camera.setMouseIn(false)
end

module.DestroyCharacterSelect = function()
  module.characterSelectionMenu:destroy()
  camera.stop()
  module.isInMenu = false
  camera.setMouseIn(false)
end

module.SelectCharacter = function(name, label, identity, skinContent)
  if skinContent then
    module.LoadPreviewSkin(skinContent)
  end

  local items = {
    {name = "submit", label = "Start", type = "button"},
    {name = "back", label = "Go Back", type = "button"}
  }

  if module.characterSelectionMenu.visible then
    module.characterSelectionMenu:hide()
  end

  module.confirmMenu = Menu('character.confirm', {
    title = 'Start with ' .. label .. '?',
    float = 'top|left',
    items = items
  })

  module.confirmMenu:on('destroy', function()
    module.characterSelectionMenu:show()
  end)

  module.confirmMenu:on('item.click', function(item, index)
    if item.name == "submit" then
      module.SelectIdentity(identity)
      module.confirmMenu:destroy()
      module.characterSelectionMenu:destroy()
      camera.stop()
      module.isInMenu = false
    elseif item.name == "back" then
      module.DestroyCharacterModel()
      module.confirmMenu:destroy()
      module.characterSelectionMenu:focus()
    end
  end)
end

module.LoadPreviewSkin = function(skin)
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

      -- Colors
      SetPedHairColor(PlayerPedId(), skin.hairColor, skin.hairHighlightColor)
      SetPedHeadOverlayColor(PlayerPedId(), 1, 1, skin.beardColor, 0)
      SetPedHeadOverlayColor(PlayerPedId(), 2, 1, skin.eyebrowColor, 0)
      SetPedHeadOverlayColor(PlayerPedId(), 4, 2, skin.makeupColor, 0)
      SetPedHeadOverlayColor(PlayerPedId(), 5, 2, skin.blushColor, 0)
      SetPedHeadOverlayColor(PlayerPedId(), 8, 2, skin.lipstickColor, 0)
      SetPedHeadOverlayColor(PlayerPedId(), 10, 1, skin.chestHairColor, 0)
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
      SetPedHeadOverlay(PlayerPedId(), 10, skin.chestHair, skin.chestHairOpacity)
      SetPedHeadOverlay(PlayerPedId(), 11, skin.bodyBlemishes, skin.bodyBlemishesOpacity)
      SetPedHeadOverlay(PlayerPedId(), 12, skin.moreBodyBlemishes, skin.moreBodyBlemishesOpacity)
      SetPedComponentVariation(PlayerPedId(), 2, skin.hair, 0, 2)


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

  SetEntityVisible(PlayerPedId(), true)

  Wait(500)

  camera.pointToBone(SKEL_ROOT)
end

module.DestroyCharacterModel = function()
  camera.pointToBone(SKEL_ROOT)

  SetEntityVisible(PlayerPedId(), false)
end

module.SelectIdentity = function(identity)
  emit("esx:identity:selectIdentity", Identity(identity))
  camera.setMouseIn(false)
end
