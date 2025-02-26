local PlayerData = { 
    HasCraftingOpen      = false,

    ClosestLocationIndex = 0,
    
    Job                  = nil,
    JobGrade             = 0,

    Loaded               = false,

    HasCooldown          = false,
}


-----------------------------------------------------------
-- Local Functions
-----------------------------------------------------------

-- @ContainsJob returns if the crafting location has required jobs and player exists on the required job
-- (!) In case the crafting location does not have any jobs, it will return true.
local ContainsJob = function (craftingLocation)
    local hasRequiredJob = true

    if craftingLocation.Jobs then
        hasRequiredJob = false

        for _, job in pairs (craftingLocation.Jobs) do
            if PlayerData.Job == job then
                hasRequiredJob = true
            end
        end
        
    end

    return hasRequiredJob
end

-----------------------------------------------------------
-- Functions
-----------------------------------------------------------

function GetPlayerData()
    return PlayerData
end

-----------------------------------------------------------
--[[ Base Events & Threads ]]--
-----------------------------------------------------------

-- Gets the player job when devmode set to false and character is selected.
AddEventHandler("tpz_core:isPlayerReady", function()
    Wait(2000)

    local data = exports.tpz_core:getCoreAPI().getPlayerClientData()

    if data == nil then
        return
    end

    PlayerData.Job      = data.job
    PlayerData.JobGrade = data.jobGrade

    PlayerData.Loaded   = true

end)

-- Gets the player job when devmode set to true.
if Config.DevMode then
    Citizen.CreateThread(function ()

        Wait(2000)

        local data = exports.tpz_core:getCoreAPI().getPlayerClientData()

        if data == nil then
            return
        end
    
        PlayerData.Job      = data.job
        PlayerData.JobGrade = data.jobGrade
    
        PlayerData.Loaded   = true

    end)
end

-- Updates the player job and job grade in case if changes.
RegisterNetEvent("tpz_core:getPlayerJob")
AddEventHandler("tpz_core:getPlayerJob", function(data)
    PlayerData.Job      = data.job
    PlayerData.JobGrade = data.jobGrade
end)


-- @param item returns the used item name to retrieve the data from configuration file.
-- @param metadata returns the used item metadata to retrieve unlocked recipes.
RegisterNetEvent('tpz_crafting:client:onCraftingBookUse')
AddEventHandler('tpz_crafting:client:onCraftingBookUse', function(item, itemId)
    local itemData  = Config.CraftingBookItems[item]

    local _itemId   = itemId

    -- Required for DevMode.
    while not PlayerData.Loaded do
        Wait(250)
    end

    local isAllowed = ContainsJob(itemData)

    if not isAllowed then
        -- message not allowed
        return
    end

    OpenCraftingByItem(item, _itemId)
end)

-- The following event is triggered by exp_target_menu which opens the closest crafting
-- When opening, the following event is also checking for job requirements.
RegisterNetEvent('tpz_crafting:OpenCraftingByLocationIndex')
AddEventHandler('tpz_crafting:OpenCraftingByLocationIndex', function()
    local index = ClosestLocationIndex

    -- If for some reason location index is null, we prevent from opening.
    if Config.Locations[index] == nil then
        return
    end

    local isCraftingAllowed = ContainsJob(Config.Locations[index])
                
    -- If is crafting not allowed because of job requirements, we also prevent from opening.
    if not isCraftingAllowed then
        return
    end

    OpenCraftingByLocationIndex(index)

end)

---------------------------------------------------------------
-- Threads
---------------------------------------------------------------

Citizen.CreateThread(function()
    RegisterActionPrompt()

    while true do
        Citizen.Wait(0)

        local sleep  = true

        local player = PlayerPedId()

        local coords = GetEntityCoords(player)
        local isDead = IsEntityDead(player)

        -- The following does not need a new thread for preventing opening the inventory.
        if PlayerData.HasCooldown then
            TriggerEvent('tpz_inventory:closePlayerInventory')
        end

        if not isDead and not PlayerData.HasCraftingOpen and PlayerData.Loaded and not PlayerData.HasCooldown then

            for index, craftingConfig in pairs(Config.Locations) do

                local coordsDist  = vector3(coords.x, coords.y, coords.z)
                local coordsCrafting = vector3(craftingConfig.Coords.x, craftingConfig.Coords.y, craftingConfig.Coords.z)
                
                local distance    = #(coordsDist - coordsCrafting)
                local propConfig  = craftingConfig.CraftingProp

                if Config.Locations[index].PropEntity and ( distance > propConfig.RenderDistance ) then

                    DeleteEntity(Config.Locations[index].PropEntity)
                    SetEntityAsNoLongerNeeded(Config.Locations[index].PropEntity)

                    Config.Locations[index].PropEntity = nil
                end
                
                if propConfig.Enabled and not Config.Locations[index].PropEntity and distance <= propConfig.RenderDistance then
                    SpawnEntityProp(index)
                end


                if Config.Locations[index].TargetEntity and ( distance > craftingConfig.ActionDistance ) then

                    TriggerEvent("exp_target_menu:RemoveEntityMenuItem", Config.Locations[index].TargetEntity, "tpz_crafting:OpenCraftingByLocationIndex")

                    Config.Locations[index].TargetEntity = nil
                end

                -- We are getting the index of the closest action for exp_target_menu.
                if distance <= craftingConfig.ActionDistance then
                    ClosestLocationIndex = index
                end
                

                local isCraftingAllowed = ContainsJob(craftingConfig)
                
                if isCraftingAllowed then

                    if craftingConfig.DrawText and distance <= craftingConfig.DrawTextRenderDistance then
                        sleep = false
                        DrawText3D(craftingConfig.Coords.x, craftingConfig.Coords.y, craftingConfig.Coords.z , craftingConfig.DrawText)
                    end
    
                    if distance <= craftingConfig.ActionDistance then

                        if not craftingConfig.TargetMenu.Enabled then
                            sleep = false
    
                            local label = CreateVarString(10, 'LITERAL_STRING', craftingConfig.PromptFooterDisplay)
                            local str   = CreateVarString(10, 'LITERAL_STRING', craftingConfig.PromptActionDisplay)
                            
                            PromptSetText(PromptsList, str)
                            PromptSetActiveGroupThisFrame(Prompts, label)
        
                            if PromptHasHoldModeCompleted(PromptsList) then
        
                                OpenCraftingByLocationIndex(index)
    
                                Wait(1000)
                            end

                        elseif craftingConfig.TargetMenu.Enabled and not propConfig.Enabled then

                            if Config.Locations[index].TargetEntity == nil then
                                local object   = craftingConfig.TargetMenu.Object
                                local objectId = GetClosestObjectOfType(coords, craftingConfig.ActionDistance, joaat(object), false)
                            
                                if objectId ~= 0 then
    
                                    if Locales[object] then
                                        TriggerEvent("exp_target_menu:SetModelName", GetHashKey(object), Locales[object])
                                    end
                            
                                    TriggerEvent("exp_target_menu:AddEntityMenuItem", objectId, "tpz_crafting:OpenCraftingByLocationIndex", Config.Locations[index].PromptActionDisplay, false)
                            

                                    Config.Locations[index].TargetEntity = objectId
                                end

                            end
                        end

                    end

                end    
            end
        end

        if sleep then
            Citizen.Wait(1000)
        end
    end
end)


