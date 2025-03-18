RegisterKeyMapping('+cruiseControlMenu', 'Ouvrir le menu véhicule', 'keyboard', '6')

RegisterCommand('+cruiseControlMenu', function()
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        OpenCruiseControlMenu()
    else
        lib.notify({ type = 'error', description = 'Vous devez être dans un véhicule.' })
    end
end, false)

RegisterCommand('cruiseControlMenu', function() end, false)

function OpenCruiseControlMenu()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    local vehicleModel = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))

    local mainMenuOptions = {
        {
            title = 'Régulateur de vitesse',
            description = 'Gérer la vitesse maximale',
            onSelect = function()
                OpenSpeedControlSubMenu(vehicleModel)
            end
        },
        {
            title = 'Gestion des portes',
            description = 'Ouvrir/fermer les portes',
            onSelect = function()
                OpenDoorsSubMenu(vehicle)
            end
        },
        {
            title = 'Contrôle moteur',
            description = 'Allumer/éteindre le moteur',
            onSelect = function()
                OpenEngineControlSubMenu(vehicle)
            end
        },
        {
            title = 'Changement de place',
            description = 'Changer de siège dans le véhicule',
            onSelect = function()
                OpenSeatChangeSubMenu(vehicle)
            end
        },        
        
        
    }

    lib.registerContext({
        id = 'vehicle_control_main',
        title = 'Contrôle véhicule - ' .. vehicleModel,
        options = mainMenuOptions
    })

    lib.showContext('vehicle_control_main')
end



function OpenSpeedControlSubMenu(vehicleModel)
    local options = {
        {
            title = 'Définir vitesse max',
            description = 'Régler la limite de vitesse',
            onSelect = function()
                local input = lib.inputDialog('Limiteur de vitesse', {
                    { type = 'number', label = 'Vitesse (km/h)', required = true, min = 1, max = 500 }
                })
                
                if input and input[1] then
                    SetCruiseControl(input[1])
                    lib.notify({ type = 'success', description = 'Limite fixée à ' .. input[1] .. ' km/h' })
                end
            end
        },
        {
            title = 'Désactiver limiteur',
            description = 'Réinitialiser la limitation',
            onSelect = function()
                SetCruiseControl(nil)
                lib.notify({ type = 'info', description = 'Limiteur désactivé' })
            end
        }
    }

    lib.registerContext({
        id = 'speed_control_submenu',
        title = 'Limiteur de vitesse',
        menu = 'vehicle_control_main',
        options = options
    })

    lib.showContext('speed_control_submenu')
end

function OpenDoorsSubMenu(vehicle)
    local doorStates = {
        [0] = 'Avant gauche',
        [1] = 'Avant droite',
        [2] = 'Arrière gauche',
        [3] = 'Arrière droite',
        [4] = 'Capot',
        [5] = 'Coffre'
    }

    local options = {}
    
    for doorId, doorName in pairs(doorStates) do
        local isOpen = GetVehicleDoorAngleRatio(vehicle, doorId) > 0.0
        local doorStatus = isOpen and '~r~Ouverte' or '~g~Fermée'

        table.insert(options, {
            title = doorName,
            description = 'Statut: ' .. doorStatus,
            onSelect = function()
                if isOpen then
                    SetVehicleDoorShut(vehicle, doorId, false)
                else
                    SetVehicleDoorOpen(vehicle, doorId, false, false)
                end
                lib.notify({ type = 'success', description = 'Porte ' .. doorName .. ' ' .. (isOpen and 'fermée' or 'ouverte') })
            end
        })
    end

    lib.registerContext({
        id = 'doors_control_submenu',
        title = 'Gestion des portes',
        menu = 'vehicle_control_main',
        options = options
    })

    lib.showContext('doors_control_submenu')
end

function OpenEngineControlSubMenu(vehicle)
    local engineState = GetIsVehicleEngineRunning(vehicle)
    local options = {
        {
            title = engineState and '~r~Éteindre le moteur' or '~g~Allumer le moteur',
            description = engineState and 'Couper l\'alimentation du moteur' or 'Démarrer le moteur',
            onSelect = function()
                SetVehicleEngineOn(vehicle, not engineState, true, true)
                lib.notify({ type = 'success', description = engineState and 'Moteur éteint' or 'Moteur allumé' })
            end
        }
    }

    lib.registerContext({
        id = 'engine_control_submenu',
        title = 'Contrôle moteur',
        menu = 'vehicle_control_main',
        options = options
    })

    lib.showContext('engine_control_submenu')
end

function OpenSeatChangeSubMenu(vehicle)
    local playerPed = PlayerPedId()
    local maxSeats = GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) - 1
    local options = {}

    local seatNames = {
        [-1] = "Conducteur",
        [0] = "Passager avant",
        [1] = "Siège arrière gauche",
        [2] = "Siège arrière droit",
        [3] = "Siège arrière milieu",
        [4] = "Siège supplémentaire 1",
        [5] = "Siège supplémentaire 2",
        [6] = "Siège supplémentaire 3",
        [7] = "Siège supplémentaire 4"
    }

    for seat = -1, maxSeats do
        if IsVehicleSeatFree(vehicle, seat) or GetPedInVehicleSeat(vehicle, seat) == playerPed then
            local seatName = seatNames[seat] or ("Siège " .. seat)
            table.insert(options, {
                title = seatName,
                description = 'Changer pour ' .. seatName,
                onSelect = function()
                    TaskWarpPedIntoVehicle(playerPed, vehicle, seat)
                    lib.notify({ type = 'success', description = 'Vous avez changé de place pour ' .. seatName })
                end
            })
        end
    end

    lib.registerContext({
        id = 'seat_change_submenu',
        title = 'Changement de place',
        menu = 'vehicle_control_main',
        options = options
    })

    lib.showContext('seat_change_submenu')
end
