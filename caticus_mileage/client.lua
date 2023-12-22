local lastVehicle = nil
local lastCoords = nil
local currentMileage = 0
local accumulatedDistance = 0
local Framework = nil
local displayInKilometers = false

if Config and Config.framework == 'esx' then
    TriggerEvent('esx:getSharedObject', function(obj) Framework = obj end)
elseif Config and Config.framework == 'qbcore' then
    Framework = exports['qb-core']:GetCoreObject()
end

function ShowNotification(message)
    if Config.framework == 'esx' and Framework then
        Framework.ShowNotification(message)
    elseif Config.framework == 'qbcore' and Framework then
        Framework.Functions.Notify(message, "primary", 5000)
    else
        SetNotificationTextEntry("STRING")
        AddTextComponentSubstringPlayerName(message)
        DrawNotification(false, true)
    end
end

function CalculateTravelledDistance(vehicle)
    local currentCoords = GetEntityCoords(vehicle)
    if lastCoords then
        return #(currentCoords - lastCoords)
    else
        return 0
    end
end

local wearThreshold = 50000 
function ApplyEngineDamageForTesting(vehicle)
  if currentMileage >= wearThreshold then
      SetVehicleEngineHealth(vehicle, -4000) 
      SetVehicleEngineOn(vehicle, true, true, false)
  end
end

Citizen.CreateThread(function()
  while true do
      Citizen.Wait(1000)
      local player = PlayerPedId()
      if IsPedInAnyVehicle(player, false) then
          local vehicle = GetVehiclePedIsIn(player, false)
          if DoesEntityExist(vehicle) then
              if lastVehicle == vehicle then
                  local distance = CalculateTravelledDistance(vehicle)
                  currentMileage = currentMileage + distance
                  accumulatedDistance = accumulatedDistance + distance

                  if accumulatedDistance >= 1000 then
                      TriggerServerEvent('vehicle-mileage:updateMileage', GetVehicleNumberPlateText(vehicle), currentMileage)
                      accumulatedDistance = 0
                  end


                  ApplyEngineDamageForTesting(vehicle)
              else
                  currentMileage = 0
                  accumulatedDistance = 0
              end
              lastCoords = GetEntityCoords(vehicle)
          end
          lastVehicle = vehicle
      else
          lastVehicle = nil
          lastCoords = nil
          currentMileage = 0
      end
  end
end)

RegisterCommand("checkmiles", function()
  local player = PlayerPedId()
  if IsPedInAnyVehicle(player, false) then
      local vehicle = GetVehiclePedIsIn(player, false)
      if vehicle and DoesEntityExist(vehicle) then
          local plate = GetVehicleNumberPlateText(vehicle)
          TriggerServerEvent('vehicle-mileage:requestMileage', plate)
      else
          ShowNotification("You are not in a vehicle with tracked mileage.")
      end
  else
      ShowNotification("You are not in a vehicle.")
  end
end, false)

RegisterCommand("checkkm", function()
    local player = PlayerPedId()
    if IsPedInAnyVehicle(player, false) then
        local vehicle = GetVehiclePedIsIn(player, false)
        if vehicle and DoesEntityExist(vehicle) then
            local plate = GetVehicleNumberPlateText(vehicle)
            displayInKilometers = true  
            TriggerServerEvent('vehicle-mileage:requestMileage', plate)
        else
            ShowNotification("You are not in a vehicle with tracked mileage.")
        end
    else
        ShowNotification("You are not in a vehicle.")
    end
end, false)

RegisterNetEvent('vehicle-mileage:receiveMileage')
AddEventHandler('vehicle-mileage:receiveMileage', function(mileage)
    local mileageDisplay = mileage
    local unit = "Miles"
    if displayInKilometers then
        mileageDisplay = mileage / 1000 
        unit = "KM"
        displayInKilometers = false  
    end
    ShowNotification("Current Mileage: " .. string.format("%.2f " .. unit, mileageDisplay))
    
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle and DoesEntityExist(vehicle) then
        -- Apply engine damage based on fetched mileage
        if mileage >= wearThreshold then
            SetVehicleEngineHealth(vehicle, -4000)
            SetVehicleEngineOn(vehicle, true, true, false)
        end
    end
end)


--[[
CATICUS
    ██████                      ██████    
    ██░░██████              ██████░░██    
    ██░░░░░░████  ██████  ████░░░░░░██    
    ██░░░░░░░░██████████████░░░░░░░░██    
    ████░░██████████████████████░░████    
      ██████████████████████████████      
        ██████████████████████████        
      ██████████████████████████████      
      ██████    ██████████    ██████      
      ████    ██  ██████  ██    ████      
██████████    ██  ██████  ██    ██████████
        ████    ██████████    ████        
      ██████████████░░██████████████      
    ████    ██████████████████    ████    
  ████        ▓▓██████████▓▓        ████  
              ██▓▓▓▓▓▓▓▓▓▓██              
    ██      ██████████████████            
  ████    ██████████████████████          
  ████  ██████████  ██  ██████████        
  ████████████  ██  ██  ██  ██████        
    ████████████    ██    ████████        
          ██████████████████████          

]]