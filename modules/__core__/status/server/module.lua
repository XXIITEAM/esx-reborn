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

-----------------------------------------------------------------------------
--- STATUS OOP
-----------------------------------------------------------------------------

Status = Extends(Serializable, 'Status')

function Status:constructor(data, defaultFields)

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

Status.all = setmetatable({}, {
  __index    = function(t, k) return rawget(t, tostring(k)) end,
  __newindex = function(t, k, v) rawset(t, tostring(k), v) end,
})

function Status:addStatus(statusName, value)

  local stat = self[statusName]

  if not stat then return end

  local newValue = stat + value

  if newValue > Config.Modules.Status.StatusMax then
    newValue = Config.Modules.Status.StatusMax
  elseif newValue < 0 then
    newValue = 0
  end

  self[statusName] = newValue


end

function Status:removeStatus(statusName, value)

  local stat = self[statusName]

  if not stat then return end

  local newValue = stat - value

  if newValue > Config.Modules.Status.StatusMax then
    newValue = Config.Modules.Status.StatusMax
  elseif newValue < 0 then
    newValue = 0
  end

  self[statusName] = newValue


end

function Status:setStatus(statusName, value)

  if not self[statusName] then return end

  if value > 100 then
    value = 100
  elseif value < 0 then
    value = 0
  end

  self[statusName] = value


end

function Status:tick()

  for name, _ in pairs(self.__ACCESSORS) do

    local stat = self[name]

    if stat > 0 then
      self[name] = stat - 1
    end

  end

end

-----------------------------------------------------------------------------
--- Functions
-----------------------------------------------------------------------------

module.UpdateStatus = function()

  for _, playerId in ipairs(GetPlayers()) do

    local player    = Player.fromId(playerId)
    local identity  = player and player.identity

    if identity ~= nil then

      if Config.Modules.Status.UseDebugging then
        print("Ticking status for player with ID " .. playerId)
      end

      local status    = identity:getStatus()

      status:tick()

      Citizen.CreateThread(function()
        module.CheckPlayerStatus(player.source, status:serialize())
      end)

    end

  end

end

-- Maximum efficiency to check if table is empty or not
local next = next

-- TODO: REFACTOR and implement a better way to send the icons.
module.CheckPlayerStatus = function(playerId, statuses)

  local status = {}
  local statusLow        = false
  local statusDying      = false
  local statusDrunk      = 0
  local drugName         = ""
  local statusDrugs      = 0
  local statusStress     = 0

  for k,v in pairs(statuses) do

    if Config.Modules.Status.UseDebugging then
      print("statuses["..k.."] = " .. v)
    end

    if Config.Modules.Status.StatusInfo[k].fadeType == "asc" then

      if v > 0 then

        if k == "drunk" then
          statusDrunk  = v
        elseif k == "weed" and statusDrugs < v then
          drugName    = "weed"
          statusDrugs  = v
        elseif k == "coicain" and statusDrugs < v then
          drugName    = "cocaine"
          statusDrugs  = v
        elseif k == "meth" and statusDrugs < v then
          drugName    = "meth"
          statusDrugs  = v
        elseif k == "heroin" and statusDrugs < v then
          drugName    = "heroin"
          statusDrugs  = v
        elseif k == "stress" then
          statusStress = v
        end


        local stat = {}
        stat["id"]       = k
        stat["color"]    = Config.Modules.Status.StatusInfo[k].color
        stat["value"]    = v
        stat["icon"]     = Config.Modules.Status.StatusInfo[k].icon
        stat["iconType"] = Config.Modules.Status.StatusInfo[k].iconType
        stat["fadeType"] = Config.Modules.Status.StatusInfo[k].fadeType
        table.insert(status, stat)
      end

    else

      if v == 0 then
        statusDying = true
      elseif v <= 10 then
        statusLow = true
      end

      if v < 50 or v == 75 or v == 100  then

        local stat = {}
        stat["id"]       = k
        stat["color"]    = Config.Modules.Status.StatusInfo[k].color
        stat["value"]    = v
        stat["icon"]     = Config.Modules.Status.StatusInfo[k].icon
        stat["iconType"] = Config.Modules.Status.StatusInfo[k].iconType
        stat["fadeType"] = Config.Modules.Status.StatusInfo[k].fadeType
        table.insert(status, stat)
      end

    end

  end

  if next(status) ~= nil then
    emitClient('esx:status:updateStatus', playerId, status)
  end

  emitClient('esx:status:statCheck', playerId, statusLow, statusDying, statusDrunk, drugName, statusDrugs, statusStress)

end
