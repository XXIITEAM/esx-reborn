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
module.Ready = false
module.Frame = nil

local atmOpen = false

onServer('esx:atm:visibility', function()
  if not atmOpen then
    atmOpen = true
    module.Frame:postMessage({
      method = 'setVisibility',
      data = atmOpen
    })
    module.Frame:focus()
    SetNuiFocus(true, true)
  else
    atmOpen = false;
    module.Frame:postMessage({
      method = 'setVisibility',
      data = atmOpen
    })
    SetNuiFocus(false, false)
  end
end)
-- Callbacks for each function

RegisterNUICallback('esx:atm:deposit', function(data)
  emitServer('esx:atm:depositMoney', data.amount)
end)

RegisterNUICallback('esx:atm:withdraw', function(data)
  emitServer('esx:atm:withdrawMoney', data.amount)
  --print('amount: ', data.amount)
end)

RegisterNUICallback('esx:atm:transfer', function(data)
    emitServer('esx:atm:transferMoney', data.amount, data.playerId)
end)

RegisterNUICallback('esx:atm:close', function ()
  atmOpen = false;
  module.Frame:postMessage({
    method = 'setVisibility',
    data = false
  })
  SetNuiFocus(false, false)
end)
