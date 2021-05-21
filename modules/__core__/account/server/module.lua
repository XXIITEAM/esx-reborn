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

M('table')
M('serializable')

Account = Extends(Serializable, 'Account')

function Account:constructor(data, defaultFields)

  if defaultFields then

    for k,v in pairs(defaultFields) do

      if data[k] == nil then
        data[k] = v
      end

    end

    for k,_ in pairs(data) do

      if defaultFields[k] == nil then
        data[k] = nil
      end

    end

  end

  self.super:ctor(data)

end

Account.all = setmetatable({}, {
  __index    = function(t, k) return rawget(t, tostring(k)) end,
  __newindex = function(t, k, v) rawset(t, tostring(k), v) end,
})

function Account:addMoney(account, amount, cb)

  local oldAmount = self[account]

  if oldAmount then
    self[account] = oldAmount + amount
    if cb ~= nil then cb(true) end
  else
    -- Acount does not exists
    if cb ~= nil then cb(false) end
  end

end

function Account:removeMoney(account, amount, cb)

  local oldAmount = self[account]

  if oldAmount then
    self[account] = oldAmount - amount
    if cb ~= nil then cb(true) end
  else
    -- Acount does not exists
    if cb ~= nil then cb(false) end
  end

end
