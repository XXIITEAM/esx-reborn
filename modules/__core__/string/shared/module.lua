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

-- The module contains additional string utility functions

--- Split a string according to a seperator
---@param inputstr string String to parse
---@param sep string Seperator to split the string by
---@return string
string.split = function(inputstr, sep)

	if sep == nil then
		sep = "%s"
	end

  local t, i = {}, 1

	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end

  return t

end
--- Check if a given string only contains numbers
---@param str string String to check
---@return boolean
string.onlyContainsDigit = function(str)
	return tonumber(str) ~= nil
end
