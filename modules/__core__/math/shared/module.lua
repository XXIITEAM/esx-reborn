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
--- Rounds a number to a specific decimal place
---@param num number Number to round
---@param numDecimalPlaces number Decimal places to round to
math.round = function(num, numDecimalPlaces)
  local mult = 10 ^ (numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end
--- Rounds a vector3 to a specified number of digits
---@param vec vector3 Vector3 to round
---@param digits number Number of digits to round to
math.roundVec3 = function(vec, digits)

  if not(digits) then
    digits = 0
  end

  return vec3(
    math.round(vec.x, digits),
    math.round(vec.y, digits),
    math.round(vec.z, digits)
  )
end

-- credit http://richard.warburton.it
--- Group digits of a passed value
---@param value string Digits to group
math.groupDigits = function(value)
	local left, num, right = string.match(value,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1' .. _U('locale_digit_grouping_symbol')):reverse())..right
end
