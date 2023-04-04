QBCore = exports['qb-core']:GetCoreObject()
local activeVehicleSpotlights = {}

local function getVehicleSpotlightStatus(vehicleKey)
    for i, networkId in ipairs(activeVehicleSpotlights) do
        if networkId[1] == vehicleKey then
            return i
        end
    end
    return false
end

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    Wait(2000)
    TriggerServerEvent("qb-spotlight:server:syncSpotlights")
end)

RegisterNetEvent("qb-spotlight:client:syncSpotlights")
AddEventHandler("qb-spotlight:client:syncSpotlights", function(activeVehicleSpotlightsServer)
    activeVehicleSpotlights = activeVehicleSpotlightsServer
end)

RegisterNetEvent('qb-spotlight:client:Spotlight', function(source)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if Config.AllowAircraft then
        if GetVehicleClass(veh) ~= 15 then
            local vehicleNetworkId = VehToNet(veh)
            local direction = GetEntityForwardVector(veh)
            TriggerServerEvent("qb-spotlight:server:toggleSpotlight", vehicleNetworkId, {direction.x, direction.y, direction.z})        
            local spotlightStatus = getVehicleSpotlightStatus(vehicleNetworkId)     
            if spotlightStatus == false then
                QBCore.Functions.Notify("Spotlight On", 'success')
            else
                QBCore.Functions.Notify("Spotlight Off", 'success')
                Wait(300)
            end
        else
            QBCore.Functions.Notify("You are not in a helicopter!", 'error')
        end
    elseif IsPedInAnyVehicle(ped, false) then
        if Config.OnlyEmergencyAllowed then
            if GetVehicleClass(veh) ~= 18 then
                QBCore.Functions.Notify("You are not in a government vehicle!", 'error')
            end
        end

        local vehicleNetworkId = VehToNet(veh)
        local direction = GetEntityForwardVector(veh)
        TriggerServerEvent("qb-spotlight:server:toggleSpotlight", vehicleNetworkId, {direction.x, direction.y, direction.z})
        local spotlightStatus = getVehicleSpotlightStatus(vehicleNetworkId)
        if spotlightStatus == false then
            QBCore.Functions.Notify("Spotlight On", 'success')
        else
            QBCore.Functions.Notify("Spotlight Off", 'success')
            Wait(300)
        end
    else
        QBCore.Functions.Notify("You need be in a vehicle!", 'error')
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(1)
        for i, spotlightInformation in ipairs(activeVehicleSpotlights) do
            local ped = GetPlayerPed(-1)
            local vehicle = NetToVeh(spotlightInformation[1])
            local door = GetEntityBoneIndexByName(vehicle, "door_dside_f")
            local windscreen = GetEntityBoneIndexByName(vehicle, "windscreen")
            local coords = GetWorldPositionOfEntityBone(vehicle, door)
            local windowCoords = GetWorldPositionOfEntityBone(vehicle, windscreen)
            local direct = vector3(spotlightInformation[2][1], spotlightInformation[2][2], spotlightInformation[2][3])

            if not NetworkDoesEntityExistWithNetworkId(spotlightInformation[1]) then
                TriggerServerEvent("qb-spotlight:server:toggleSpotlight", vehicleNetworkId, {0, 0, 0})
                return
            end

            if GetVehiclePedIsIn(ped, false) == vehicle then
                local newY = 0
                local newZ = 0
                local forwardVector = GetEntityForwardVector(vehicle)
                local heading = GetEntityHeading(vehicle)
                if IsControlPressed(0, Config.UpKey) then
                    newZ = newZ + Config.ChangeRate
                end
                if IsControlPressed(0, Config.DownKey) then
                    newZ = newZ - Config.ChangeRate
                end
                if IsControlPressed(0, Config.LeftKey) then
                    if heading >= 180 and heading <= 365 then
                        newY = newY + Config.ChangeRate
                    else
                        newY = newY - Config.ChangeRate
                    end
                end
                if IsControlPressed(0, Config.RightKey) then
                    if heading >= 180 and heading <= 365 then
                        newY = newY - Config.ChangeRate
                    else
                        newY = newY + Config.ChangeRate
                    end
                end
                TriggerServerEvent("qb-spotlight:server:updateSpotlight", i, {forwardVector.x, (direct.y + newY), (direct.z + newZ)})
                TriggerEvent('QBCore:Notify', source, "Spotlight is on", 'error')
            end
            local veh = GetVehiclePedIsIn(ped, false)

            if GetVehicleClass(veh) == 15 then -- Increases the Distance for Aircraft
                DrawSpotLight(coords.x, windowCoords.y, coords.z, direct.x, direct.y, direct.z, 221, 221, 221, 200.0, 50.0, 4.3, 25.0, 28.6)
            else
                DrawSpotLight(coords.x, windowCoords.y, coords.z, direct.x, direct.y, direct.z, 221, 221, 221, 70.0, 50.0, 4.3, 25.0, 28.6)
            end
        end
    end
end)
