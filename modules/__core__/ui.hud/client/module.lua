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

module.Ready      = false
module.Frames     = {}
module.FocusOrder = {}
module.CursorPos  = {x = 0, y = 0}

---Make sure module and Frame is ready for messages
---@param fn function Callback function to execute when ready
local ensureReady = function(fn)

  if module.Ready then
    fn()
  else

    local tick

    tick = ESX.SetTick(function()

      if module.Ready then
        ESX.ClearTick(tick)
        fn()
      end

    end)

  end

end

--- Create a new NUI Frame
---@param name string Name of the frame
---@param url string URL of the frame
---@param visible boolean Whether to show the frame or not
local createFrame = function(name, url, visible)

  if visible == nil then
    visible = true
  end
  --- First ensure NUI frame is ready before sending initial SendNUIMessage
  ensureReady(function()
    SendNUIMessage({action = 'create_frame', name = name, url = url, visible = visible})
  end)

end
--- Show NUI Frame method
---@param name string Name of the app to show
local showFrame = function(name)
  ensureReady(function()
    SendNUIMessage({action = 'show_frame', name = name})
  end)

end
--- Hide NUI Frame
---@param name string Name of the app to hide
local hideFrame = function(name)

  ensureReady(function()
    SendNUIMessage({action = 'hide_frame', name = name})
  end)

end
--- Destroy NUI Frame
---@param name string Name of the app to destroy
local destroyFrame = function(name)

  ensureReady(function()
    SendNUIMessage({action = 'destroy_frame', name = name})
  end)

end

--- Send Data to a Frame instance
---@param name string Name of the app to send data to
---@param msg table Data to send to the NUI frame
local sendFrameMessage = function(name, msg)

  ensureReady(function()
    SendNUIMessage({target = name, data = msg})
  end)

end
--- Focus a specific NUI frame
---@param name string Name of the app to focus
---@param cursor boolean Whether to show the mouse or not
local focusFrame = function(name, cursor)

  ensureReady(function()
    SendNUIMessage({action = 'focus_frame', name = name})
    SetNuiFocus(true, cursor)
  end)

end

Frame = Extends(EventEmitter, 'Frame')

--- Unfocus all frames
Frame.unfocusAll = function()
  module.FocusOrder = {}
  SetNuiFocus(false)
end

function Frame:constructor(name, url, visible)

  self.super:ctor();

  self.name      = name
  self.url       = url
  self.loaded    = false
  self.destroyed = false
  self.visible   = visible
  self.hasFocus  = false
  self.hasCursor = false
  self.mouse     = {down = {}, pos = {x = -1, y = -1}}

  self:on('load', function()
    self.loaded = true
  end)

  createFrame(self.name, self.url, self.visible)

  module.Frames[self.name] = self

  self:on('message', function(msg)
    if msg.__esxinternal then
      self:emit('internal', msg.action, table.unpack(msg.args or {}))
    else
      self:emit(msg.action, msg.data)
    end
  end)

  self:on('internal', function(action, ...)
    emit(action, ...)
    self:emit(action, ...)
  end)
  -- Listen for mouse:down event and set instance property
  self:on('mouse:down', function(button)
    self.mouse.down[button] = true
  end)
  -- Listen for mouse:up event and set instance property
  self:on('mouse:up', function(button)
    self.mouse.down[button] = false
  end)

  self:on('mouse:move', function(x, y)

    local last = table.clone(self.mouse)
    local data = table.clone(last)

    data.pos.x, data.pos.y = x, y

    if (last.x ~= -1) and (last.y ~= -1) then

      local offsetX = x - last.pos.x
      local offsetY = y - last.pos.y

      data.direction = {left = offsetX < 0, right = offsetX > 0, up = offsetY < 0, down = offsetY > 0}

      emit('mouse:move:offset', offsetX, offsetY, data)
      self:emit('mouse:move:offset', offsetX, offsetY, data)

    end

    self.mouse = data

  end)

end
--- Unmount/destroy a NUI frame
---@param name string Name of the app to destroy/unmount
function Frame:destroy(name)
  self:unfocus()
  self.destroyed = true
  destroyFrame(self.name)
  self:emit('destroy')
end
--- Send message to a frame
---@param msg table Data to send to the NUI Frame
function Frame:postMessage(msg)
  sendFrameMessage(self.name, msg)
end
--- Focus an NUI Frame
---@param cursor boolean Whether to show a cursor or not
function Frame:focus(cursor)

  self.hasFocus  = true
  self.hasCursor = cursor

  local newFocusOrder = {}

  for i=1, #module.FocusOrder, 1 do

    local frame = module.FocusOrder[i]

    if frame ~= self then
      newFocusOrder[#newFocusOrder + 1] = frame
    end

  end

  newFocusOrder[#newFocusOrder + 1] = self

  module.FocusOrder = newFocusOrder

  focusFrame(self.name, self.hasCursor)

  self:emit('focus')

end
--- Unfocus the frame
function Frame:unfocus()

  local newFocusOrder = {}

  for i=1, #module.FocusOrder, 1 do

    local frame = module.FocusOrder[i]

    if frame ~= self then
      newFocusOrder[#newFocusOrder + 1] = frame
    end

  end

  if #newFocusOrder > 0 then
    local previousFrame = newFocusOrder[#newFocusOrder]
    SetNuiFocus(true, previousFrame.hasCursor)
  else
    SetNuiFocus(false, false)
  end

  module.FocusOrder = newFocusOrder

  self:emit('unfocus')

end
--- Show the frame
function Frame:show()
  self.visible = true
  showFrame(self.name)
end

--- Hide the frame
function Frame:hide()
  self.visible = false
  hideFrame(self.name)
end
