-- QBCore Ped Spawner
-- A standalone script for spawning and managing peds in QBCore

local spawnedPeds = {}
local Config = {
    Debug = true,
    DefaultScenario = "WORLD_HUMAN_STAND_IMPATIENT",
    DefaultModel = "a_m_y_skater_01"
}

-- Function to print debug messages
local function Debug(msg)
    if Config.Debug then
        print("[PED-SPAWNER] " .. msg)
    end
end

-- Function to spawn a ped
local function SpawnPed(model, coords, heading, scenario, blockEvents, freeze)
    -- Default values
    model = model or Config.DefaultModel
    scenario = scenario or Config.DefaultScenario
    blockEvents = blockEvents ~= false -- Default to true
    freeze = freeze ~= false -- Default to true
    
    -- Convert string model to hash
    local modelHash = type(model) == "string" and GetHashKey(model) or model
    
    -- Request the model
    RequestModel(modelHash)
    local timeout = 0
    Debug("Requesting model: " .. model)
    
    -- Wait for model to load with timeout
    while not HasModelLoaded(modelHash) do
        timeout = timeout + 100
        Wait(100)
        if timeout > 5000 then
            Debug("Failed to load model in time")
            return nil
        end
    end
    
    -- Create the ped
    local ped = CreatePed(4, modelHash, coords.x, coords.y, coords.z - 1.0, heading, false, true)
    
    -- Set ped properties
    SetEntityAsMissionEntity(ped, true, true)
    SetPedFleeAttributes(ped, 0, 0)
    SetBlockingOfNonTemporaryEvents(ped, blockEvents)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetPedDiesWhenInjured(ped, false)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, freeze)
    
    -- Apply scenario if provided
    if scenario then
        TaskStartScenarioInPlace(ped, scenario, 0, true)
    end
    
    -- Clean up the model
    SetModelAsNoLongerNeeded(modelHash)
    
    -- Add to our tracking table
    table.insert(spawnedPeds, {
        pedId = ped,
        model = model,
        coords = coords,
        scenario = scenario
    })
    
    Debug("Spawned ped ID: " .. ped)
    return ped
end

-- Function to delete a specific ped
local function DeletePed(ped)
    if DoesEntityExist(ped) then
        DeleteEntity(ped)
        Debug("Deleted ped ID: " .. ped)
        
        -- Remove from tracking table
        for i, spawnedPed in ipairs(spawnedPeds) do
            if spawnedPed.pedId == ped then
                table.remove(spawnedPeds, i)
                break
            end
        end
        return true
    end
    return false
end

-- Function to delete all spawned peds
local function DeleteAllPeds()
    local count = 0
    for _, spawnedPed in ipairs(spawnedPeds) do
        if DoesEntityExist(spawnedPed.pedId) then
            DeleteEntity(spawnedPed.pedId)
            count = count + 1
        end
    end
    spawnedPeds = {}
    Debug("Deleted " .. count .. " peds")
    return count
end

-- Function to get closest ped to coords
local function GetClosestPed(coords, maxDistance)
    maxDistance = maxDistance or 5.0
    local closestPed = nil
    local closestDistance = maxDistance
    
    for _, spawnedPed in ipairs(spawnedPeds) do
        if DoesEntityExist(spawnedPed.pedId) then
            local pedCoords = GetEntityCoords(spawnedPed.pedId)
            local distance = #(coords - pedCoords)
            
            if distance < closestDistance then
                closestDistance = distance
                closestPed = spawnedPed.pedId
            end
        end
    end
    
    return closestPed, closestDistance
end

-- Function to list all spawned peds
local function ListSpawnedPeds()
    for i, spawnedPed in ipairs(spawnedPeds) do
        if DoesEntityExist(spawnedPed.pedId) then
            Debug(string.format("Ped [%d]: ID=%d, Model=%s, Scenario=%s", 
                i, spawnedPed.pedId, spawnedPed.model, spawnedPed.scenario or "None"))
        else
            Debug(string.format("Ped [%d]: ENTITY NO LONGER EXISTS", i))
        end
    end
    return #spawnedPeds
end

-- Command to spawn a ped
RegisterCommand("spawnped", function(source, args)
    local model = args[1] or Config.DefaultModel
    local scenario = args[2] or Config.DefaultScenario
    
    local playerPed = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 2.0, 0.0)
    local heading = GetEntityHeading(playerPed)
    
    local ped = SpawnPed(model, coords, heading, scenario)
    if ped then
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 0},
            multiline = true,
            args = {"PED-SPAWNER", "Spawned ped " .. model .. " with ID " .. ped}
        })
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"PED-SPAWNER", "Failed to spawn ped " .. model}
        })
    end
end, false)

-- Command to delete closest ped
RegisterCommand("deleteped", function(source, args)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local maxDistance = tonumber(args[1]) or 5.0
    
    local closestPed, distance = GetClosestPed(coords, maxDistance)
    if closestPed then
        if DeletePed(closestPed) then
            TriggerEvent('chat:addMessage', {
                color = {255, 255, 0},
                multiline = true,
                args = {"PED-SPAWNER", "Deleted ped ID " .. closestPed .. " at distance " .. string.format("%.2f", distance)}
            })
        end
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"PED-SPAWNER", "No peds found within " .. maxDistance .. " meters"}
        })
    end
end, false)

-- Command to delete all peds
RegisterCommand("deleteallpeds", function(source, args)
    local count = DeleteAllPeds()
    TriggerEvent('chat:addMessage', {
        color = {255, 255, 0},
        multiline = true,
        args = {"PED-SPAWNER", "Deleted " .. count .. " peds"}
    })
end, false)

-- Command to list all spawned peds
RegisterCommand("listpeds", function(source, args)
    local count = ListSpawnedPeds()
    TriggerEvent('chat:addMessage', {
        color = {255, 255, 0},
        multiline = true,
        args = {"PED-SPAWNER", "Listed " .. count .. " peds"}
    })
end, false)

-- Export functions to be used by other resources
exports('SpawnPed', SpawnPed)
exports('DeletePed', DeletePed)
exports('DeleteAllPeds', DeleteAllPeds)
exports('GetClosestPed', GetClosestPed)
exports('ListSpawnedPeds', ListSpawnedPeds)

-- Resource cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        DeleteAllPeds()
    end
end)

-- Example of how to use this in another resource:
--[[
-- To spawn a ped:
local pedId = exports['ped-spawner']:SpawnPed('a_m_y_skater_01', GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), 'WORLD_HUMAN_AA_COFFEE')

-- To delete a ped:
exports['ped-spawner']:DeletePed(pedId)

-- To delete all peds:
exports['ped-spawner']:DeleteAllPeds()
]]--
