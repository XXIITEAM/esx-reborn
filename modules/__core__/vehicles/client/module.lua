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

module.VehicleAction = function(action, intType, model, object)
  if DoesEntityExist(object) then
    if IsEntityAVehicle(object) then
      if action == "in" then
        local seats = GetVehicleModelNumberOfSeats(model)

        for i = 1, seats do
          local seat = i - 2

          if IsVehicleSeatFree(object, seat) then
            local ped = PlayerPedId()

            TaskEnterVehicle(ped, object, 20000, seat, 1.5, 1, 0)

            break
          end
        end
      elseif action == "frontleft" then
        local door = GetEntityBoneIndexByName(object, "door_dside_f")
        if door ~= -1 then
          if GetVehicleDoorAngleRatio(object, 0) > 0.0 then 
            SetVehicleDoorShut(object, 0, 0)
          else
            SetVehicleDoorOpen(object, 0, 0)  
          end
        end
      elseif action == "frontright" then
        local door = GetEntityBoneIndexByName(object, "door_pside_f")
        if door ~= -1 then
          if GetVehicleDoorAngleRatio(object, 1) > 0.0 then 
            SetVehicleDoorShut(object, 1, 0)
          else
            SetVehicleDoorOpen(object, 1, 0)  
          end
        end
      elseif action == "backleft" then
        local door = GetEntityBoneIndexByName(object, "door_dside_r")
        if door ~= -1 then
          if GetVehicleDoorAngleRatio(object, 2) > 0.0 then 
            SetVehicleDoorShut(object, 2, 0)
          else
            SetVehicleDoorOpen(object, 2, 0)  
          end
        end
      elseif action == "backright" then
        local door = GetEntityBoneIndexByName(object, "door_pside_r")
        if door ~= -1 then
          if GetVehicleDoorAngleRatio(object, 3) > 0.0 then 
            SetVehicleDoorShut(object, 3, 0)
          else
            SetVehicleDoorOpen(object, 3, 0)  
          end
        end
      elseif action == "hood" then
        local door = GetEntityBoneIndexByName(object, "bonnet")
        if door ~= -1 then
          if GetVehicleDoorAngleRatio(object, 4) > 0.0 then 
            SetVehicleDoorShut(object, 4, 0)
          else
            SetVehicleDoorOpen(object, 4, 0)  
          end
        end
      elseif action == "trunk" then
        local door = GetEntityBoneIndexByName(object, "boot")
        if door ~= -1 then
          if GetVehicleDoorAngleRatio(object, 5) > 0.0 then 
            SetVehicleDoorShut(object, 5, 0)
          else
            SetVehicleDoorOpen(object, 5, 0)  
          end
        end
      elseif action == "lockpick" then
        print("Lockpicking Function TBD. Awaiting Inventory.")
      end
    end
  end
end