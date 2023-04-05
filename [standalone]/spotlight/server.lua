-----------------------------------------
--- Spotlight, Made by FAXES & Slavko ---
------------ FaxSlav Devs :P ------------
-----------------------------------------

--- CONFIG IS IN CLIENT.LUA
--- CONFIG IS IN CLIENT.LUA
--- CONFIG IS IN CLIENT.LUA
--- CONFIG IS IN CLIENT.LUA

local activeVehicleSpotlights = {}

function getVehicleSpotlightStatus(vehicleKey)
    for i, networkId in ipairs(activeVehicleSpotlights) do
        if networkId[1] == vehicleKey then
            return i
        end
    end
    return false
end

function removeByValue(tbl, val)
    for i, v in ipairs(tbl) do
        if v[1] == val then
            table.remove(tbl, i)
        end
    end
end

RegisterServerEvent("spotlight:syncSpotlights")
AddEventHandler("spotlight:syncSpotlights", function()
    local _source = source
    TriggerClientEvent("spotlight:syncSpotlights", _source, activeVehicleSpotlights)
end)

RegisterServerEvent("spotlight:updateSpotlight")
AddEventHandler("spotlight:updateSpotlight", function(key, direction)
    if activeVehicleSpotlights[key] == nil then return end
    activeVehicleSpotlights[key][2] = direction
    TriggerClientEvent("spotlight:syncSpotlights", -1, activeVehicleSpotlights)
end)

RegisterServerEvent("spotlight:toggleSpotlight")
AddEventHandler("spotlight:toggleSpotlight", function(networkId, direction)
    if getVehicleSpotlightStatus(networkId) ~= false then
        removeByValue(activeVehicleSpotlights, networkId)
    else
        table.insert(activeVehicleSpotlights, {networkId, direction})
    end
    TriggerClientEvent("spotlight:syncSpotlights", -1, activeVehicleSpotlights)
end)