print('PRIME SCRIPT | Script crée par Brad')

local cruiseControlActive = false
local maxSpeed = 0.0
local currentVehicle = nil

function SetCruiseControl(speed)
    cruiseControlActive = speed ~= nil
    maxSpeed = speed or 0.0

    if cruiseControlActive then
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            currentVehicle = GetVehiclePedIsIn(playerPed, false)
        else
            currentVehicle = nil
            cruiseControlActive = false
            lib.notify({ type = 'error', description = 'Vous devez être dans un véhicule pour activer le limiteur.' })
        end
    else
        currentVehicle = nil
    end
end

CreateThread(function()
    while true do
        if cruiseControlActive and currentVehicle then
            local playerPed = PlayerPedId()
            if IsPedInAnyVehicle(playerPed, false) and GetVehiclePedIsIn(playerPed, false) == currentVehicle then
                local currentSpeed = GetEntitySpeed(currentVehicle) * 3.6 

                if currentSpeed > maxSpeed then
                    SetVehicleMaxSpeed(currentVehicle, maxSpeed / 3.6)
                else
                    SetVehicleMaxSpeed(currentVehicle, 0.0)
                end
            else
                cruiseControlActive = false
                currentVehicle = nil
            end
        end

        Wait(0)
    end
end)

AddEventHandler('gameEventTriggered', function(eventName, eventData)
    if eventName == 'CEventNetworkPlayerLeftVehicle' then
        local playerPed = PlayerPedId()
        if not IsPedInAnyVehicle(playerPed, false) then
            cruiseControlActive = false
            currentVehicle = nil
        end
    end
end)
