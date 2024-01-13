
local CraftingType            = nil
local CraftingLocationIndex   = 0
local SelectedRecipeItem      = nil

local CurrentCraftingBookItem = nil
local CurrentItemId           = nil

local UnlockedRecipes         = {}

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

        local length = GetTableLength(data.Jobs)

        -- We are checking in case if required jobs != {} (Empty Table).
        if length > 0 then

            TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_crafting:getCraftingLocationData", function(cb)

                for _, v in pairs (cb) do
                    UnlockedRecipes[v] = true
                end

            end, { currentJob = ClientData.Job } )

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
    if ClientData.HasCraftingOpen or ClientData.HasCooldown then 
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
    local itemData          = Config.CraftingBookItems[item]

    CurrentCraftingBookItem = item
    CurrentItemId           = itemId

    if ClientData.HasCraftingOpen or ClientData.HasCooldown then 
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

    local categoryLength = GetTableLength(data.Categories)

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
	SetNuiFocus(display,display)

	ClientData.HasCraftingOpen = display

    if not display then
        ClearPedTasks(PlayerPedId())

        SelectedRecipeItem = nil
        CraftingLocationIndex = 0
    end

    SendNUIMessage({ action = 'toggle', toggle = display })
end

CloseNUI = function()
    if ClientData.HasCraftingOpen then SendNUIMessage({action = 'close'}) end
end

SendNotification = function(message, type)

    if ClientData.HasCraftingOpen then
		local notify_color = Config.NotificationColors[type]
		SendNUIMessage({ action = 'sendNotification', notification_data = {message = message, type = type, color = notify_color} })
	end

end

---------------------------------------------------------------
-- NUI Callbacks
---------------------------------------------------------------

-- @param category - Returns the selected category.
RegisterNUICallback('requestCategoryRecipes', function(data)

    local categoryLength = GetTableLength(Config.CraftingRecipes)

    if categoryLength <= 0 then
        return
    end

    local elements = {}


    -- CurrentItemMetadata

    -- First we create a loop which will add as first elements, the recipes
    -- which are not locked (not requiring any blueprint)
    for _, recipe in pairs (Config.CraftingRecipes) do

        if (recipe.Category == data.category) and (not recipe.RequiredBlueprint or recipe.RequiredBlueprint and UnlockedRecipes[_]) then

            recipe.Label = "undefined"
            
            if ClientData.ItemsList[_]  then
                recipe.Label = ClientData.ItemsList[_].label
            end

            recipe.item = _
            recipe.locked = false
            table.insert(elements, recipe)
        end

    end

    -- Secondary, we create another loop which will add as last elements, the recipes
    -- which are locked (Having blueprint and are not unlocked)
    for _, recipe in pairs (Config.CraftingRecipes) do

        if recipe.Category == data.category and recipe.RequiredBlueprint and UnlockedRecipes[_] == nil then

            recipe.Label = "undefined"
            
            if ClientData.ItemsList[_]  then
                recipe.Label = ClientData.ItemsList[_].label
            end

            recipe.item = _
            recipe.locked = true
            table.insert(elements, recipe)

        end

    end

    -- At last, we load all recipes based on their index ORDER for displaying
    -- all recipes properly (locked / not).
    for _, recipe in pairs (elements) do
        SendNUIMessage({ action = 'loadCategoryRecipe', recipe = recipe.item, label = recipe.Label, locked = recipe.locked })
    end

end)

-- @param recipe - Returns the selected recipe name.
RegisterNUICallback('requestRecipe', function(data)

    if ClientData.ItemsList[data.recipe] == nil then
        return
    end

    Wait(500)

    local recipe = Config.CraftingRecipes[data.recipe]

    recipe.Label = "undefined"
            
    -- If has an existing item, we load the item label.
    if ClientData.ItemsList[data.recipe]  then
        recipe.Label = ClientData.ItemsList[data.recipe].label
    end

    -- If has required blueprint and is an existing item, we create and load the blueprints label.
    if recipe.RequiredBlueprint then
        recipe.RequiredBlueprintLabel = "undefined"

        if ClientData.ItemsList[recipe.RequiredBlueprint]  then
            recipe.RequiredBlueprintLabel = ClientData.ItemsList[recipe.RequiredBlueprint].label
        end

    end

    SelectedRecipeItem = data.recipe

    -- Loading the selected recipe data.
    SendNUIMessage({ action = 'loadSelectedRecipe', result = recipe, locked = data.locked })

    
    for _, ingredient in pairs (recipe.Ingredients) do

        local label = "undefined"

        if ClientData.ItemsList[_]  then
            label = ClientData.ItemsList[_].label
        end

        SendNUIMessage({ action = 'loadSelectedRecipeIngredients', label = label, quantity = ingredient })

    end

end)



RegisterNUICallback('readSelectedRecipeBlueprint', function()
    local item      = SelectedRecipeItem
    local playerPed = PlayerPedId()

    ClientData.HasCooldown = true

    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_crafting:startReadingRecipe", function(cb)

        if not cb then
            SendNUIMessage({ action = 'resetCooldown' })
            ClientData.HasCooldown = false

            SendNotification(Locales['NOT_BLUEPRINT'], 'error')
            return
        end

        ClearPedTasksImmediately(playerPed)
        CloseNUI()

        Wait(1000)

        TaskStartScenarioInPlace(playerPed, joaat('WORLD_HUMAN_WRITE_NOTEBOOK'), -1)

        exports.tpz_core:rClientAPI().DisplayProgressBar(Config.BlueprintReadingDuration * 1000, Locales['READING_RECIPE'])

        if CraftingType == 'LOCATION' then
            print("location")
            TriggerServerEvent("tpz_crafting:unlockRecipeBasedOnCraftingLocation", item, ClientData.Job)
            
        elseif CraftingType == 'ITEM' then
            TriggerServerEvent("tpz_crafting:unlockRecipeBasedOnItemId", item, CurrentItemId, CurrentCraftingBookItem)
        end

        ClearPedTasks(playerPed)

        Wait(2000)
        ClientData.HasCooldown = false

        local NotifyData = Locales['BLUEPRINT_READ_ACHIEVEMENT']
        TriggerEvent("tpz_notify:sendNotification", NotifyData.title, NotifyData.message, NotifyData.icon, "info", NotifyData.duration)

    end, { blueprint = Config.CraftingRecipes[item].RequiredBlueprint })

end)


RegisterNUICallback('craftSelectedRecipe', function()
    local item      = SelectedRecipeItem
    local type      = CraftingType
    local index     = CraftingLocationIndex

    local playerPed = PlayerPedId()

    local recipe    = Config.CraftingRecipes[item]

    -- For locations, we don't have to check for nearby objects, in that way,
    -- we do the crafting instantly if the player has the required weight or ingredients.
    if type == "LOCATION" then
            
        TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_crafting:startedCraftingRecipe", function(cb)

            -- If the player does not have enough weight or not ingredients, we cancel the crafting.
            if not cb then
                SendNUIMessage({ action = 'resetCooldown' })
                ClientData.HasCooldown = false
                return
            end

            ClearPedTasksImmediately(playerPed)
            CloseNUI()
        
            ClientData.HasCooldown = true
        
            Wait(1000)
    
            local locationData = Config.Locations[index]
        
            if locationData.Animations then
    
                SetEntityHeading(playerPed, locationData.Coords.h)

                PerformCraftingAction(playerPed, locationData.Animations, recipe)
    
                TriggerServerEvent("tpz_crafting:onCraftingRecipeReceive", item)
           
            else
                FreezeEntityPosition(playerPed, true)
                exports.tpz_core:rClientAPI().DisplayProgressBar(recipe.Duration * 1000, recipe.ProgressDisplay)

                ClientData.HasCooldown = false
                FreezeEntityPosition(playerPed, false)

                TriggerServerEvent("tpz_crafting:onCraftingRecipeReceive", item)
            end
                
        
        end, { item = item } )

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
                ClientData.HasCooldown = false
                return
            end

            isAllowedToCraft = true
        end

        if isAllowedToCraft then

            TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_crafting:startedCraftingRecipe", function(cb)

                -- If the player does not have enough weight or not ingredients, we cancel the crafting.
                if not cb then
                    SendNUIMessage({ action = 'resetCooldown' })
                    ClientData.HasCooldown = false
                    return
                end

                ClearPedTasksImmediately(playerPed)
                CloseNUI()
            
                ClientData.HasCooldown = true
            
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
                    TriggerServerEvent("tpz_crafting:onCraftingRecipeReceive", item)
                end

            end, { item = item } )

        end

    end
end)

RegisterNUICallback('close', function()
	ToggleNUI(false)
end)
