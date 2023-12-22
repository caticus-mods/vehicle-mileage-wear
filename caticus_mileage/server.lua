if Config.framework == 'esx' then
    ESX = nil
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
elseif Config.framework == 'qbcore' then
    QBCore = exports['qb-core']:GetCoreObject()
end

RegisterServerEvent('vehicle-mileage:updateMileage')
AddEventHandler('vehicle-mileage:updateMileage', function(plate, mileage)
    print("Updating mileage for plate: " .. plate .. " with mileage: " .. mileage)  -- Debug print
    UpdateMileageInDatabase(plate, mileage)
end)

function UpdateMileageInDatabase(plate, mileage)
    MySQL.Async.execute('INSERT INTO calticus_mileage (plate, miles) VALUES (@plate, @miles) ON DUPLICATE KEY UPDATE miles = @miles', {
        ['@plate'] = plate,
        ['@miles'] = mileage
    }, function(affectedRows)
        if affectedRows == 0 then
            print('Error updating mileage for plate: ' .. plate)
        end
    end)
end

RegisterServerEvent('vehicle-mileage:requestMileage')
AddEventHandler('vehicle-mileage:requestMileage', function(plate)
    local src = source
    MySQL.Async.fetchScalar('SELECT miles FROM calticus_mileage WHERE plate = @plate', {
        ['@plate'] = plate
    }, function(mileage)
        if mileage then
            TriggerClientEvent('vehicle-mileage:receiveMileage', src, mileage)
        else
            TriggerClientEvent('vehicle-mileage:receiveMileage', src, 0)
        end
    end)
end)
