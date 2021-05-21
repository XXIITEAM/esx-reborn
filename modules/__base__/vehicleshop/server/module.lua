-- Copyright (c) Jérémie N'gadi
--
-- All rights reserved.
--
-- Even if 'All rights reserved' is very clear :
--
--   You shall not use any piece of this software in a commercial product / service
--   You shall not resell this software
--   You shall not provide any facility to install this particular software in a commercial product / service
--   If you redistribute this software, you must link to ORIGINAL repository at https://github.com/ESX-Org/es_extended
--   This copyright should appear in every part of the project code

------------------------------------------------------------------------
----------                                                    ----------
--                              IMPORTS                               --
----------                                                    ----------
------------------------------------------------------------------------

local Vehicles = M("vehicles")

------------------------------------------------------------------------
----------                                                    ----------
--                             VARIABLES                              --
----------                                                    ----------
------------------------------------------------------------------------

module.Config = run('data/config.lua', {vector3 = vector3})['Config']
module.Cache = {}

module.Updated   = false
module.ShopInUse = false

------------------------------------------------------------------------
----------                                                    ----------
--                                INIT                                --
----------                                                    ----------
------------------------------------------------------------------------

module.Init = function()
  local translations = run('data/locales/' .. Config.Locale .. '.lua')['Translations']
  LoadLocale('vehicleshop', Config.Locale, translations)
end

module.isPlateTaken = function(plate)
  local usedPlates = Vehicles.GetUsedPlates()

  for _,value in ipairs(usedPlates) do
    if tostring(value) == tostring(plate) then
      return true
    end
  end

  return false
end

module.ExcessPlateLength = function(plate, plateUseSpace, plateLetters, plateNumbers)
  local checkedPlate = tostring(plate)
  local plateLength = string.len(checkedPlate)

  if plateLength > 8 then
      print("^1Generated plate is more than 8 characters. FiveM does not support this.^7")
      return true
  else
      return false
  end
end

module.GroupDigits = function(value)
local left,num,right = string.match(value,'^([^%d]*%d)(%d*)(.-)$')

return left..(num:reverse():gsub('(%d%d%d)','%1' .. ","):reverse())..right
end
