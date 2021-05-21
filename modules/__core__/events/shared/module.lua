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

M('class')

-- Gobal events
module.handlers         = {}
module.callbacks        = {}
module.requestCallbacks = {}
module.eventId          = 2
module.requestId        = 2

local getEventId = function()

  if (module.eventId + 1) == 1000000 then
    module.eventId = 2
  else
    module.eventId = module.eventId + 1
  end

  return module.eventId

end

local getRequestId = function()

  if (module.requestId + 1) == 1000000 then
    module.requestId = 2
  else
    module.requestId = module.requestId + 1
  end

  return module.requestId

end
--- A same-side (client -> client, server -> server) event listener
--- these are *not* serialized as they do not flow within the regular cfx event system
---
--- @param name string The event name to listen for
--- @param cb function The callback function
--- @return number The event id for
on = function(name, cb)

  local id = getEventId()

  module.handlers[name]     = module.handlers[name] or {}
  module.handlers[name][id] = cb

  return id

end

--- An event listener that only listens for an event once before
--- deregistering itself
--- @param name string The event name to listen for
--- @param cb function The callback function that will execute once
--- @return void
once = function(name, cb)

  local id

  id = on(name, function(...)
    off(id)
    cb(...)
  end)

end

--- Deregisters a same-side event listener if it exists for a specific id
--- if an ID is not passed then all listeners will be deregistered
--- @param name string The event name to listen for
--- @param id number The callback function that will execute once
--- @return void
off = function(name, id)

  module.handlers[name]     = module.handlers[name] or {}
  module.handlers[name][id] = nil

end

--- Emits to event listeners of the specified name if registered
--- @param name string The name of the event to emit to
--- @param ...  any[] Additional arguments to pass to the event listener
--- @return void
emit = function(name, ...)

  module.handlers[name] = module.handlers[name] or {}

  for k,v in pairs(module.handlers[name]) do
    v(...)
  end

end

--- @class EventHandler
--- @field key number The unique key
--- @field name string The name of the event

if IsDuplicityVersion() then
  --- A Server Event Listener for listening to events emitted from the client
  --- @param name string The name of the event to listen for
  --- @param cb function The callback function to be executed
  --- @return EventHandler A tab
  onClient = function(name, cb)
    RegisterNetEvent(name)
    return AddEventHandler(name, cb)
  end
  --- Deregisters a server event listener
  --- @param table EventHandler A table returned from onClient
  --- @return void
  offClient = function(table)
    RemoveEventHandler(table)
  end
  --- Trigger a client event based on name and netID
  --- @param name string The name of the event to listen for
  --- @param client number The netID (source) of the client to emit too
  --- @return void
  emitClient = function(name, client, ...)
    TriggerClientEvent(name, client, ...)
  end
  --- Will trigger a cross-network RPC event from the server on a client
  --- that will return data to the callback function
  --- @param name string The name of the event to listen for
  --- @param client number The netID (source) of the client to emit too
  --- @param cb function Callback function passed data returned from the client
  --- @param ... any[] Any additional arguments that *will* be serialized
  --- @return void
  request = function(name, client, cb, ...)

    local id           = getRequestId()
    module.callbacks[id] = cb

    emitClient('esx:request', client, name, id, ...)

  end

else
  --- A Client Event Listener for listening to events emitted from the server
  --- @param name string The name of the event to listen for
  --- @param cb function The callback function to be executed
  --- @return EventHandler A table with fields key & name
  onServer = function(name, cb)
    RegisterNetEvent(name)
    return AddEventHandler(name, cb)
  end

  --- Deregisters a client event listener
  --- @param table EventHandler A table returned from onServer
  --- @return void
  offServer = function(table)
    RemoveEventHandler(table)
  end

  --- Emits to a server event from the client
  --- @param name string The name of the event to trigger
  --- @param ... any[] Any additional arguments that *will* be serialized
  --- @return void
  emitServer = function(name, ...)
    TriggerServerEvent(name, ...)
  end

  --- Will trigger a cross-network RPC event from the server on a client
  --- that will return data to the callback function
  --- @param name string The name of the event to listen for
  --- @param cb function The callback function that return data is passed too
  --- @param ... any[] Any additional arguments that *will* be serialized
  --- @return void
  request = function(name, cb, ...)

    local id           = getRequestId()
    module.callbacks[id] = cb

    emitServer('esx:request', name, id, ...)

  end

end
--- A request listener for RPC network requests
--- that will return data to the callback function
--- @param name string The name of the event to listen for
--- @param cb function The callback function that return data is passed too
--- @param ... any[]
--- @return void
onRequest = function(name, cb)
  module.requestCallbacks[name] = cb
end

--- @class EventEmitter
--- @return EventEmitter
EventEmitter = Extends(nil, 'EventEmitter')

--- Constructor for EventEmitter class
function EventEmitter:constructor()
  self.handlers = {}
end

--- Registers an event listener for an event on a EventEmitter
--- @param name string The name of the event
--- @param cb function The callback function
--- @return number The id for the event listener
function EventEmitter:on(name, cb)

  local id = getEventId()

  self.handlers[name]     = self.handlers[name] or {}
  self.handlers[name][id] = cb

  return id

end
--- Deregisters an event listener for an event on an EventEmitter
--- @param name string The name of the event
--- @param id number The id return of the event as returned by EventEmitter:on
function EventEmitter:off(name, id)

  self.handlers[name]     = self.handlers[name] or {}
  self.handlers[name][id] = nil

end
--- Emits an event on the parent EventEmitter
--- @param name string The name of the event
--- @param ... any[] Any additional arguments that will *not* be serialized.
function EventEmitter:emit(name, ...)

  for k,v in pairs(self.handlers[name] or {}) do
    v(...)
  end

end
--- Will listen to an event once before deregistering it
--- @param name string The name of the event
--- @param cb function The callback function passed event data.
function EventEmitter:once(name, cb)

  local id

  id = self:on(name, function(...)
    off(id)
    cb(...)
  end)

  return id

end
