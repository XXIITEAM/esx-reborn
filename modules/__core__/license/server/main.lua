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

M('command')

local addLicenseCommand = Command("addlicense", "admin", "Add a license to a player")
addLicenseCommand:addArgument("targetPlayer", "player", "The player to add the license to")
addLicenseCommand:addArgument("license", "string", "The license to add")
addLicenseCommand:setRconAllowed(true)
addLicenseCommand:setHandler(function(player, args)
  local license = args.license
  local targetPlayer = args.targetPlayer

  if license == nil then
    return emitClient("chat:addMessage", player.source, {args = {'^1SYSTEM', _U('commanderror_nolicense')}})
  end

  local targetIdentity = targetPlayer.identity

  if targetIdentity == nil then
    return emitClient("chat:addMessage", player.source, {args = {'^1SYSTEM', _U('commanderror_noidentity')}})
  end

  local result = targetIdentity:getLicenses():addLicense(license)

  if result then
    targetIdentity:save()
  end

end)

local removeLicenseCommand = Command("removelicense", "admin", "Removes a license from a player")
removeLicenseCommand:addArgument("targetPlayer", "player", "The player to remove the role from")
removeLicenseCommand:addArgument("license", "string", "The license to remove")
removeLicenseCommand:setRconAllowed(true)
removeLicenseCommand:setHandler(function(player, args)
  local license = args.license
  local targetPlayer = args.targetPlayer

  if license == nil then
    return emitClient("chat:addMessage", player.source, {args = {'^1SYSTEM', _U('commanderror_nolicense')}})
  end

  local targetIdentity = targetPlayer.identity

  if targetIdentity == nil then
    return emitClient("chat:addMessage", player.source, {args = {'^1SYSTEM', _U('commanderror_noidentity')}})
  end

  local result = targetIdentity:getLicenses():removeLicense(license)

  if result then
    targetIdentity:save()
  end

end)

local revokeLicenseCommand = Command("revokelicense", "admin", "Revokes a license of a player")
revokeLicenseCommand:addArgument("targetPlayer", "player", "The player to revoke the license to")
revokeLicenseCommand:addArgument("license", "string", "The license to revoke")
revokeLicenseCommand:setRconAllowed(true)
revokeLicenseCommand:setHandler(function(player, args)
  local license = args.license
  local targetPlayer = args.targetPlayer

  if license == nil then
    return emitClient("chat:addMessage", player.source, {args = {'^1SYSTEM', _U('commanderror_nolicense')}})
  end

  local targetIdentity = targetPlayer.identity

  if targetIdentity == nil then
    return emitClient("chat:addMessage", player.source, {args = {'^1SYSTEM', _U('commanderror_noidentity')}})
  end

  local result = targetIdentity:getLicenses():revokeLicense(license, reason)

  if result then
    targetIdentity:save()
  end

end)


local validateLicenseCommand = Command("validatelicense", "admin", "Validates a license of a player")
validateLicenseCommand:addArgument("targetPlayer", "player", "The player to validate the license to")
validateLicenseCommand:addArgument("license", "string", "The license to validate")
validateLicenseCommand:setRconAllowed(true)
validateLicenseCommand:setHandler(function(player, args)
  local license = args.license
  local targetPlayer = args.targetPlayer

  if license == nil then
    return emitClient("chat:addMessage", player.source, {args = {'^1SYSTEM', _U('commanderror_nolicense')}})
  end

  local targetIdentity = targetPlayer.identity

  if targetIdentity == nil then
    return emitClient("chat:addMessage", player.source, {args = {'^1SYSTEM', _U('commanderror_noidentity')}})
  end

  local result = targetIdentity:getLicenses():validateLicense(license)

  if result then
    targetIdentity:save()
  end

end)

addLicenseCommand:register()
removeLicenseCommand:register()
revokeLicenseCommand:register()
validateLicenseCommand:register()
