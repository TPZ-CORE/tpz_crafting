local TPZ                     = exports.tpz_core:getCoreAPI()
local TPZInv                  = exports.tpz_inventory:getInventoryAPI()

local CraftingType            = nil
local CraftingLocationIndex   = 0
local SelectedRecipeItem      = nil

local CurrentCraftingBookItem = nil
local CurrentItemId           = nil

local UnlockedRecipes         = {}

-----------------------------------------------------------
--[[ Local Functions  ]]--
-----------------------------------------------------------

local DoesRecipeExist = function(item)

    for index, recipe in pairs (Config.CraftingRecipes) do
  
      if item == recipe.item then
        return true, recipe
      end
  
    end
  
    return false, nil
  
end

-----------------------------------------------------------
--[[ Events  ]]--
-----------------------------------------------------------

RegisterNetEvent("tpz_crafting:SendNotification")
AddEventHandler("tpz_crafting:SendNotification", function(message, type)
    SendNotification(message, type)
end)


-----------------------------------------------------------
--[[ Loading Data Functions ]]--
-----------------------------------------------------------

-- @LoadCraftingLocationUnlockedRecipes is used for @OpenCraftingByLocationIndex, to load its data.

local LoadCraftingLocationUnlockedRecipes = function(data)
    UnlockedRecipes = {}

    -- We are checking if required jobs != false (Crafting location can be public).
    if data.Jobs ~= false then

        local length = TPZ.GetTableLength(data.Jobs)

        -- We are checking in case if required jobs != {} (Empty Table).
        if length > 0 then

            TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_crafting:getCraftingLocationData", function(cb)

                for _, v in pairs (cb) do
                    UnlockedRecipes[v] = true
                end

            end, { currentJob = GetPlayerData().Job } )

        end

    end

end

-- @LoadItemMetadataUnlockedRecipes is used for @OpenCraftingByItem, to load its metadata.
local LoadItemMetadataUnlockedRecipes = function(item, itemId)

    UnlockedRecipes = {}
    
    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_crafting:getCraftingBookMetadata", function(metadata)

        for _, v in pairs (metadata) do

            if type(v) == 'table' and v['crafting'] ~= nil then
                
                for i, recipe in pairs (v['crafting']) do
                
                    UnlockedRecipes[recipe] = true
                end
    
            end
    
        end

    end, { item = item, itemId = itemId })

end

-----------------------------------------------------------
--[[ Functions ]]--
-----------------------------------------------------------

OpenCraftingByLocationIndex = function(index)
    local PlayerData = GetPlayerData()

    if PlayerData.HasCraftingOpen or PlayerData.HasCooldown then 
        return 
    end

    UnlockedRecipes, UnlockedRecipes = nil, {}

    CraftingType = "LOCATION"
    CraftingLocationIndex = index

    TaskStartScenarioInPlace(PlayerPedId(), joaat('WORLD_HUMAN_WRITE_NOTEBOOK'), -1)

    Wait(500)

    local data = Config.Locations[index]

    LoadCraftingLocationUnlockedRecipes(data)

    OpenCrafting(data)
end

OpenCraftingByItem = function(item, itemId)
    local PlayerData        = GetPlayerData()
    local itemData          = Config.CraftingBookItems[item]

    CurrentCraftingBookItem = item
    CurrentItemId           = itemId

    if PlayerData.HasCraftingOpen or PlayerData.HasCooldown then 
        return 
    end

    TaskStartScenarioInPlace(PlayerPedId(), joaat('WORLD_HUMAN_WRITE_NOTEBOOK'), -1)

    LoadItemMetadataUnlockedRecipes(item, itemId)
    
    Wait(500)
    CraftingType = "ITEM"
    OpenCrafting(itemData)
end

-----------------------------------------------------------
--[[ NUI Functions ]]--
-----------------------------------------------------------

OpenCrafting = function(data)

    SendNUIMessage({ 
        action = 'loadInformation',
        crafting_det = {header = data.Header, description = data.Description},
    })

    local categoryLength = TPZ.GetTableLength(data.Categories)

    if categoryLength > 0 then

        for _, category in pairs (data.Categories) do

            if Config.Categories[category] then
                SendNUIMessage({ action = 'loadCategory', category = category, label = Config.Categories[category].Label })
            end

        end


    end

    Wait(250)
    ToggleNUI(true)
end


ToggleNUI = function(display)
    local PlayerData = GetPlayerData()

	SetNuiFocus(display,display)

	PlayerData.HasCraftingOpen = display

    if not display then
        ClearPedTasks(PlayerPedId())

        SelectedRecipeItem = nil
        CraftingLocationIndex = 0
    end

    SendNUIMessage({ action = 'toggle', toggle = display })
end

CloseNUI = function()
    if GetPlayerData().HasCraftingOpen then SendNUIMessage({action = 'close'}) end
end

SendNotification = function(message, type)

    if GetPlayerData().HasCraftingOpen then
		local notify_color = Config.NotificationColors[type]
		SendNUIMessage({ action = 'sendNotification', notification_data = {message = message, type = type, color = notify_color} })
	end

end

---------------------------------------------------------------
-- NUI Callbacks
---------------------------------------------------------------

-- @param category - Returns the selected category.
RegisterNUICallback('requestCategoryRecipes', function(data)
    local PlayerData     = GetPlayerData()
    local categoryLength = TPZ.GetTableLength(Config.CraftingRecipes)

    if categoryLength <= 0 then
        return
    end

    local elements = {}

    -- CurrentItemMetadata

    -- First we create a loop which will add as first elements, the recipes
    -- which are not locked (not requiring any blueprint)
    for _, recipe in pairs (Config.CraftingRecipes) do

        if (recipe.Category == data.category) and (not recipe.RequiredBlueprint or recipe.RequiredBlueprint and UnlockedRecipes[recipe.Item]) then

            if recipe.Label == nil then 
                recipe.Label = "undefined"
            end
            
            if recipe.Label == "undefined" then
                recipe.Label = TPZInv.getItemData(recipe.Item).label
            end

            recipe.item = recipe.Item
            recipe.locked = false
            table.insert(elements, recipe)
        end

    end

    -- Secondary, we create another loop which will add as last elements, the recipes
    -- which are locked (Having blueprint and are not unlocked)
    for _, recipe in pairs (Config.CraftingRecipes) do

        if recipe.Category == data.category and recipe.RequiredBlueprint and UnlockedRecipes[recipe.Item] == nil then

            if recipe.Label == nil then 
                recipe.Label = "undefined"
            end
            
            if recipe.Label == "undefined" then
                recipe.Label = TPZInv.getItemData(recipe.Item).label
            end

            recipe.item = recipe.Item
            recipe.locked = true
            table.insert(elements, recipe)

        end

    end

    -- At last, we load all recipes based on their index ORDER for displaying
    -- all recipes properly (locked / not).
    for _, recipe in pairs (elements) do
        SendNUIMessage({ action = 'loadCategoryRecipe', recipe = recipe.Item, label = recipe.Label, locked = recipe.locked })
    end

end)

-- @param recipe - Returns the selected recipe name.
RegisterNUICallback('requestRecipe', function(data)
    local PlayerData = GetPlayerData()

    local doesRecipeExist, recipe = DoesRecipeExist(data.recipe)

    if recipe.Label == nil then 
        recipe.Label = "undefined"
    end

    -- If has an existing item, we load the item label.
    if recipe.Label == "undefined" then
        recipe.Label = TPZInv.getItemData(data.recipe).label
    end

    -- If has required blueprint and is an existing item, we create and load the blueprints label.
    if recipe.RequiredBlueprint then
        recipe.RequiredBlueprintLabel = "undefined"

        if TPZInv.getItemData(recipe.RequiredBlueprint) then
            recipe.RequiredBlueprintLabel = TPZInv.getItemData(recipe.RequiredBlueprint).label
        end

    end

    SelectedRecipeItem = data.recipe

    -- Loading the selected recipe data.
    SendNUIMessage({ action = 'loadSelectedRecipe', result = recipe, locked = data.locked })

    
    for _, ingredient in pairs (recipe.Ingredients) do

        local label = "undefined"

        if TPZInv.getItemData(ingredient.item) then
            label = TPZInv.getItemData(ingredient.item).label
        end

        SendNUIMessage({ action = 'loadSelectedRecipeIngredients', label = label, quantity = ingredient.required_quantity })

    end

end)



RegisterNUICallback('readSelectedRecipeBlueprint', function()
    local PlayerData = GetPlayerData()
    local item       = SelectedRecipeItem
    local playerPed  = PlayerPedId()

    PlayerData.HasCooldown = true

    local doesRecipeExist, recipe = DoesRecipeExist(item)

    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_crafting:startReadingRecipe", function(cb)

        if not cb then
            SendNUIMessage({ action = 'resetCooldown' })
            PlayerData.HasCooldown = false

            SendNotification(Locales['NOT_BLUEPRINT'], 'error')
            return
        end

        ClearPedTasksImmediately(playerPed)
        CloseNUI()

        Wait(1000)

        TaskStartScenarioInPlace(playerPed, joaat('WORLD_HUMAN_WRITE_NOTEBOOK'), -1)

        exports.tpz_core:getCoreAPI().DisplayProgressBar(Config.BlueprintReadingDuration * 1000, Locales['READING_RECIPE'])

        if CraftingType == 'LOCATION' then
            TriggerServerEvent("tpz_crafting:server:unlockRecipeBasedOnCraftingLocation", item, PlayerData.Job)
            
        elseif CraftingType == 'ITEM' then
            TriggerServerEvent("tpz_crafting:server:unlockRecipeBasedOnItemId", item, CurrentItemId, CurrentCraftingBookItem)
        end

        ClearPedTasks(playerPed)

        Wait(2000)
        PlayerData.HasCooldown = false

        local NotifyData = Locales['BLUEPRINT_READ_ACHIEVEMENT']
        TriggerEvent("tpz_notify:sendNotification", NotifyData.title, NotifyData.message, NotifyData.icon, "info", NotifyData.duration)

    end, { blueprint = recipe.RequiredBlueprint })

end)


-- @data.uniqueId : returns unique item or weapon id for repairs.
RegisterNUICallback('craftSelectedRecipe', function(data)
    local PlayerData = GetPlayerData()
    local item       = SelectedRecipeItem
    local type       = CraftingType
    local index      = CraftingLocationIndex

    local playerPed  = PlayerPedId()
    local doesRecipeExist, recipe = DoesRecipeExist(item)

    -- For locations, we don't have to check for nearby objects, in that way,
    -- we do the crafting instantly if the player has the required weight or ingredients.
    if type == "LOCATION" then
            
        TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_crafting:canCraftRecipe", function(cb)

            -- If the player does not have enough weight or not ingredients, we cancel the crafting.
            if not cb then
                SendNUIMessage({ action = 'resetCooldown' })
                PlayerData.HasCooldown = false
                return
            end

            ClearPedTasksImmediately(playerPed)
            CloseNUI()
        
            PlayerData.HasCooldown = true
        
            Wait(1000)
    
            local locationData = Config.Locations[index]
        
            if locationData.AnimationType ~= false then
    
                SetEntityHeading(playerPed, locationData.Coords.h)

                PerformCraftingAction(playerPed, locationData.AnimationType, recipe)
    
                if not recipe.IsRepairable then
                    TriggerServerEvent("tpz_crafting:server:receiveCraftingRecipe", item)
                else
                    TriggerServerEvent("tpz_crafting:server:repairCrafting", item, data.uniqueId)
                end
           
            else
                TaskStandStill(playerPed, -1)
                exports.tpz_core:getCoreAPI().DisplayProgressBar(recipe.Duration * 1000, recipe.ProgressDisplay)

                PlayerData.HasCooldown = false
                TaskStandStill(playerPed, 1)

                if not recipe.IsRepairable then
                    TriggerServerEvent("tpz_crafting:server:receiveCraftingRecipe", item)
                else
                    TriggerServerEvent("tpz_crafting:server:repairCrafting", item, data.uniqueId)
                end
            end
                
        
        end, { item = item, uniqueId = data.uniqueId } )

    elseif type == "ITEM" then

        local isAllowedToCraft = true

        local found            = 0
        local foundType        = nil

        if recipe.IsCookable then
            isAllowedToCraft = false

            local coords = GetEntityCoords(playerPed)

            for _, object in pairs (Config.CookableObjects) do
                local objectId = GetClosestObjectOfType(coords, Config.CookingObjectDistance, joaat(object.Object), false)
                
                if objectId ~= 0 then
                    found     = objectId
                    foundType = object.Type
                    break
                end
            end

            if found == 0 then
                SendNotification(Locales['NOT_COOKABLE_LOCATION_FOUND'], 'error')
                SendNUIMessage({ action = 'resetCooldown' })
                PlayerData.HasCooldown = false
                return
            end

            isAllowedToCraft = true
        end

        if isAllowedToCraft then

            TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_crafting:canCraftRecipe", function(cb)

                -- If the player does not have enough weight or not ingredients, we cancel the crafting.
                if not cb then
                    SendNUIMessage({ action = 'resetCooldown' })
                    PlayerData.HasCooldown = false
                    return
                end

                ClearPedTasksImmediately(playerPed)
                CloseNUI()
            
                PlayerData.HasCooldown = true
            
                Wait(1000)

                local animationType = "HANDCRAFT"

                if recipe.IsCookable then
                    TaskTurnPedToFaceEntity(playerPed, found, -1)
                    animationType = foundType 
                end
    
                -- We start the building right before animation and progress starts.
                if recipe.IsBuildable then
                    animationType = "BUILD"
                    PerformCraftingBuildByType(recipe, recipe.IsBuildable)
                end

                PerformCraftingAction(playerPed, animationType, recipe)

                if not recipe.IsBuildable then
                    TriggerServerEvent("tpz_crafting:server:receiveCraftingRecipe", item)
                    
                elseif recipe.IsRepairable then
                    TriggerServerEvent("tpz_crafting:server:repairCrafting", item, data.uniqueId)
                end

            end, { item = item, uniqueId = data.uniqueId } )

        end

    end
end)

RegisterNUICallback('close', function()
	ToggleNUI(false)
end)
