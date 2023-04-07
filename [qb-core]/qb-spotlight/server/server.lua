local QBCore = exports['qb-core']:GetCoreObject()
local activeVehicleSpotlights = {}

local function getVehicleSpotlightStatus(vehicleKey)
    for i, networkId in ipairs(activeVehicleSpotlights) do
        if networkId[1] == vehicleKey then
            return i
        end
    end
    return false
end

local function removeByValue(tbl, val)
    for i, v in ipairs(tbl) do
        if v[1] == val then
            table.remove(tbl, i)
        end
    end
end

RegisterServerEvent("qb-spotlight:server:syncSpotlights")
AddEventHandler("qb-spotlight:server:syncSpotlights", function()
    local _source = source
    TriggerClientEvent("qb-spotlight:client:syncSpotlights", _source, activeVehicleSpotlights)
end)

RegisterServerEvent("qb-spotlight:server:updateSpotlight")
AddEventHandler("qb-spotlight:server:updateSpotlight", function(key, direction)
    if activeVehicleSpotlights[key] == nil then return end
    activeVehicleSpotlights[key][2] = direction
    TriggerClientEvent("qb-spotlight:client:syncSpotlights", -1, activeVehicleSpotlights)
end)

RegisterServerEvent("qb-spotlight:server:toggleSpotlight")
AddEventHandler("qb-spotlight:server:toggleSpotlight", function(networkId, direction)
    if getVehicleSpotlightStatus(networkId) ~= false then
        removeByValue(activeVehicleSpotlights, networkId)
    else
        table.insert(activeVehicleSpotlights, {networkId, direction})
    end
    TriggerClientEvent("qb-spotlight:client:syncSpotlights", -1, activeVehicleSpotlights)
end)

QBCore.Commands.Add(Config.Command, "Enables / Disables Spotlight", {}, false, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(source)
    if Config.JobCheck then
        if Player.PlayerData.job.name ~= "police" then
            TriggerClientEvent('QBCore:Notify', src, "You are not police!", 'error')
        else
            TriggerClientEvent('qb-spotlight:client:Spotlight', src)
        end
    else
        TriggerClientEvent('qb-spotlight:client:Spotlight', src)
    end
end)