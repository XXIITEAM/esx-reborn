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

M('string')
-- This module holds table/array utility functions

--- Get Table size
---@param t table Table to calculate size for
table.sizeOf = function(t)

  local count = 0

  for k,v in pairs(t) do
    count = count + 1
  end

  return count

end
--- Check if table is an array
---@param t table Table to check
table.isArray = function(t)

  local keys = {}

  for k,v in pairs(t) do

    local num = tonumber(k)

    if num ~= k then
      return false
    end

    table.insert(keys, num)

  end

  table.sort(keys, function(a, b) return a < b end)

  for i=1, #keys, 1 do
    if keys[i] ~= i then
      return false
    end
  end

  return true

end
--- Get the index of a table value
---@param t table The table to find value in
---@param val any The value to find the index of
table.indexOf = function(t, val)

  for i=1, #t, 1 do
    if t[i] == val then
      return i
    end
  end

  return -1

end
--- Get last index for a table value
---@param t table Table to parse
---@param val any Value to find last index of
table.lastIndexOf = function(t, val)

  for i=#t, 1, -1 do
    if t[i] == val then
      return i
    end
  end

  return -1
end
--- Returns the value of the first element matching testing function
---@param t table Table to parse
---@param cb function A function used to test what value to return
table.find = function(t, cb)

  for i=1, #t, 1 do
    if cb(t[i]) then
      return t[i]
    end
  end

  return nil

end
--- Returns the index of the first element in an array matching testing function
---@param t table Table to parse
---@param cb function A function used to test what value to return
table.findIndex = function(t, cb)

  for i=1, #t, 1 do
    if cb(t[i]) then
      return i
    end
  end

  return -1
end
--- Creates a new array with all elements that passed the testing function
---@param t table Table to parse
---@param cb function Filter function for the array
table.filter = function(t, cb)

  local newTable = {}

  for i=1, #t, 1 do
    if cb(t[i]) then
      table.insert(newTable, t[i])
    end
  end

  return newTable

end
--- Creates a new array populated with the result of function on each element
---@param t table Table to parse
---@param cb function Function to mutate passed values
table.map = function(t, cb)

  local newTable = {}

  for i=1, #t, 1 do
    newTable[i] = cb(t[i], i)
  end

  return newTable

end
--- Reverses the table
---@param t table Table to parse
table.reverse = function(t)

  local newTable = {}

  for i=#t, 1, -1 do
    table.insert(newTable, t[i])
  end

  return newTable

end
--- Clones the table into a new table
--- @param t table Table to clone
table.clone = function(t)

  if type(t) ~= 'table' then
    return t
  end

  local copy = {}

  for k,v in pairs(t) do
    copy[k] = table.clone(v)
  end

  return copy

end
--- Merges two tables and returns a new array
---@param t1 table Table 1
---@param t2 table Table 2
table.concat = function(t1, t2)

  if type(t2) == 'string' then
    local separator = t2
    return table.join(t1, separator)
  end

  local t3 = table.clone(t1)

  for i=1, #t2, 1 do
    table.insert(t3, t2[i])
  end

  return t3

end
--- Returns a string from a parsed array
---@param t table Table to parse
---@param sep string Separator to parse with
table.join = function(t, sep)

  local sep = sep or ','
  sep       = tostring(sep)
  local str = ''

  for i=1, #t, 1 do

    if i > 1 then
      str = str .. sep
    end

    str = str .. tostring(t[i])

  end

  return str

end
--- Merge two tables together
---@param t1 table First table
---@param t2 table Second table
---@return table Merged table
table.merge = function(t1, t2)

  local t3 = {}

  for k,v in pairs(t1) do
    if type(v) == 'table' then
      t3[k] = table.merge(v, t2[k] or {})
    else
      t3[k] = v
    end
  end

  for k,v in pairs(t2) do
    if type(v) == 'table' then
      t3[k] = table.merge(v, t1[k] or {})
    else
      t3[k] = v
    end
  end

  return t3

end

table.by = function(t, k)

  local t2 = {}

  for i=1, #t, 1 do
    local entry = t[i]
    local val   = entry[k]

    if val ~= nil then
      t2[val] = entry
    end

  end

  return t2

end
--- Get the value from specific table's path
---@param t table Table to search
---@param path string The path to the value in dot notation
table.get = function(t, path)

  local split = string.split(path, '.')
  local obj   = t

  for i=1, #split, 1 do

    local key    = split[i]
    local keyNum = tonumber(key)

    if keyNum ~= nil then
      key = keyNum
    end

    obj = obj[key]

  end

  return obj

end
--- Set the value of a table value based on the path
---@param t table Table to set the value of
---@param path string Path in dot notation for the value to alter
---@param v any The data to set the provided key equal to
table.set = function(t, path, v)

  local split = string.split(path, '.')
  local obj   = t

  for i=1, #split, 1 do

    local key    = split[i]
    local keyNum = tonumber(key)

    if keyNum ~= nil then
      key = keyNum
    end

    if i == #split then
      obj[key] = v
    else
      obj = obj[key]
    end

  end

end
--- Return the keys for a table
---@param t table Table to return keys for
table.keys = function(t)

  local keys = {}

  for k,v in pairs(t) do
    keys[#keys + 1] = k
  end

  return keys

end
--- Return the values for a table
---@param t table Table to return values for
table.values = function(t)

  local values = {}

  for k,v in pairs(t) do
    values[#values + 1] = v
  end

  return values

end
