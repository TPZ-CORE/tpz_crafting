local CraftedObjects = {}
local AttachedEntity = nil

--[[-------------------------------------------------------
 Handlers
]]---------------------------------------------------------

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    if AttachedEntity then
        DeleteEntity(AttachedEntity)
        SetEntityAsNoLongerNeeded(AttachedEntity)
    end

    local length = GetTableLength(CraftedObjects)
    if length <= 0 then
        return
    end

    for _, v in pairs (CraftedObjects) do
        DeleteEntity(v.object)
        SetEntityAsNoLongerNeeded(v.object)

        if Config.exp_target_menu.enabled then
            TriggerEvent("exp_target_menu:RemoveEntityMenuItem", v.object, "tpz_crafting:PickupClosestCraftedObject")
        end
    end

end)

-- We remove the spawned crafted objects from the player if disconnects from the game for any reason.
-- We don't want those objects to stay since they are Synced Entities.
AddEventHandler('playerDropped', function (reason)
    local _source = source
    local list    = CraftedObjects

    if AttachedEntity then
        DeleteObject(AttachedEntity)
        DeleteEntity(AttachedEntity)
        SetEntityAsNoLongerNeeded(AttachedEntity)
    end

    local length = GetTableLength(list)
    if length <= 0 then
        return
    end

    for _, v in pairs (list) do
        DeleteEntity(v.object)
        SetEntityAsNoLongerNeeded(v.object)
    end

end)

--[[-------------------------------------------------------
 Functions
]]---------------------------------------------------------

PerformCraftingAction = function (playerPed, type, recipe)
    local PlayerData = GetPlayerData()
    local typeData   = Config.AnimationTypes[type]
    
    local data = {
        dict       = typeData.Animation,
        base       = typeData.AnimationBase,
        scenario   = typeData.AnimationScenario,
        attachment = typeData.ObjectAttachment
    }

    SetCurrentPedWeapon(playerPed, joaat("WEAPON_UNARMED"), true, 0, false, false)

    Wait(250)


    if not data.scenario and data.attachment ~= false then

        local coords         = GetEntityCoords(playerPed) 
        local attachmentData = data.attachment

        LoadModel(attachmentData.Object)

        local prop = CreateObject(joaat(attachmentData.Object), coords.x, coords.y, coords.z , 0.2, true, true, false, false, true)

        local boneIndex = GetEntityBoneIndexByName(playerPed, attachmentData.Attachment)
                
        AttachEntityToEntity(prop, playerPed, boneIndex, 
        attachmentData.x, attachmentData.y, attachmentData.z, attachmentData.xRot, attachmentData.yRot, attachmentData.zRot, 
        true, true, false, true, 1, true)

        AttachedEntity = prop

    end

    if data.scenario then
        TaskStartScenarioInPlace(playerPed, joaat(data.dict), -1)
    else
        PlayAnimation(playerPed, data)
    end

    exports.tpz_core:getCoreAPI().DisplayProgressBar(recipe.Duration * 1000, recipe.ProgressDisplay)

    if data.scenario then
        ClearPedTasks(playerPed)
    else
        StopAnimTask(playerPed, data.dict, data.base, 1.0)
    end

    PlayerData.HasCooldown = false
end

PerformCraftingBuildByType = function(data, object)
    local player = PlayerPedId()

    local x,y,z  = table.unpack(GetOffsetFromEntityInWorldCoords(player, 0.0, 1.0, -0.5))

    LoadModel(object)

    local entity = CreateObject(joaat(object), x, y, z, true, false, true)

    SetEntityVisible(entity, true)
    --SetEntityHeading(entity, propData.Coords.yaw)
    SetEntityCollision(entity, true)
    FreezeEntityPosition(entity, true)
    PlaceObjectOnGroundProperly(entity)

    SetEntityAlpha(entity, 100)

    TaskTurnPedToFaceEntity(PlayerPedId(), entity, -1)

    CraftedObjects[entity] = {}
    CraftedObjects[entity] = { model = object, object = entity, coords = {x = x, y = y, z = z}, recipe = data }

    if Config.exp_target_menu.enabled then

        local pickupLabel = Locales['PICKUP']

        if Locales[object] then
            pickupLabel = pickupLabel.. Locales[object]
            TriggerEvent("exp_target_menu:SetModelName", GetHashKey(object), Locales[object])
        end

        TriggerEvent("exp_target_menu:AddEntityMenuItem", entity, "tpz_crafting:PickupClosestCraftedObject", pickupLabel, false)
    end

    TriggerEvent("tpz_crafting:ResetEntityAlpha", entity, data.Duration)
end


PickupPlacedObject = function(objectEntity, model, recipe)
    local PlayerData = GetPlayerData()
    local playerPed  = PlayerPedId()

    PlayerData.HasCooldown = true

    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_crafting:startPlacedObjectPickupAction", function(cb)

        -- If the player does not have enough weight when picking up to collect the ingredients, we cancel the crafting.
        if not cb then
            SendNotification(nil, Locales['NOT_ENOUGH_INVENTORY_SPACE_PICKUP'], "error")
            PlayerData.HasCooldown = false
            return
        end

        local pickupLabel = Locales['PICKING_UP']

        if Locales[model] then
            pickupLabel = pickupLabel.. Locales[model]
        end
    
        local animationData = { Duration = Config.AnimationTypes['PICKUP'].Duration, ProgressDisplay = pickupLabel}
    
        PerformCraftingAction(playerPed, 'PICKUP', animationData)
    
        DeleteObject(objectEntity)
        DeleteEntity(objectEntity)
        SetEntityAsNoLongerNeeded(objectEntity)
    
        if Config.exp_target_menu.enabled then
            TriggerEvent("exp_target_menu:RemoveEntityMenuItem", objectEntity, "tpz_crafting:PickupClosestCraftedObject")
        end
    
        CraftedObjects[objectEntity] = nil

        TriggerServerEvent("tpz_crafting:server:pickupPlacedObject", recipe.Ingredients)

    end, { ingredients = recipe.Ingredients } )
end

--[[-------------------------------------------------------
 Events
]]---------------------------------------------------------

-- The following event is triggered to reset an entities alpha.
-- Unfortunately we cannot use a function because of the Wait function we are using.
RegisterNetEvent("tpz_crafting:ResetEntityAlpha")
AddEventHandler("tpz_crafting:ResetEntityAlpha", function(entity, duration)
    local _entity = entity

    Wait(duration * 1000)
    ResetEntityAlpha(_entity)

    if not AttachedEntity then
        return
    end

    DeleteObject(AttachedEntity)
    DeleteEntity(AttachedEntity)
    SetEntityAsNoLongerNeeded(AttachedEntity)

end)

-- The following event is triggered only for exp_target_menu for picking up crafted placed objects.
RegisterNetEvent("tpz_crafting:PickupClosestCraftedObject")
AddEventHandler("tpz_crafting:PickupClosestCraftedObject", function()
    if GetPlayerData().HasCooldown then
        return
    end

    local playerPed  = PlayerPedId()
    local coords     = GetEntityCoords(playerPed)

    local objectEntity, model, recipe = nil, nil, nil

    for _, object in pairs (CraftedObjects) do

        local objectId = GetClosestObjectOfType(coords, Config.exp_target_menu.range, joaat(object.model), false)
        
        if objectId ~= 0 then
            objectEntity, model, recipe = objectId, object.model, object.recipe
            break
        end

    end

    if objectEntity == 0 or objectEntity == nil then
        return
    end


    PickupPlacedObject(objectEntity, model, recipe)
end)


--[[-------------------------------------------------------
 Threads
]]---------------------------------------------------------

-- The following thread is used for picking up crafted placed objects
-- which are not exp_target_menu supported.

if not Config.exp_target_menu.enabled then

    Citizen.CreateThread(function ()

        RegisterPickupActionPrompt()

        while true do
            
            Wait(0)

            local sleep  = true

            local player = PlayerPedId()
    
            local coords = GetEntityCoords(player)
            local isDead = IsEntityDead(player)

            local PlayerData = GetPlayerData()
            
            if not isDead and PlayerData.Loaded and not PlayerData.HasCooldown and not PlayerData.HasCraftingOpen then

                local length = GetTableLength(CraftedObjects)
                if length > 0 then

                    for _, object in pairs (CraftedObjects) do
                        
                        local coordsDist  = vector3(coords.x, coords.y, coords.z)
                        local coordsBuild = vector3(object.coords.x, object.coords.y, object.coords.z)
                
                        local distance    = #(coordsDist - coordsBuild)

                        if distance <= Config.PickupObjectDistance then
                            sleep = false

                            local pickupLabel = "Object"

                            if Locales[object.model] then
                                pickupLabel = Locales[object.model]
                            end

                            local label = CreateVarString(10, 'LITERAL_STRING', pickupLabel)

                            PromptSetActiveGroupThisFrame(PickupPrompts, label)
        
                            if PromptHasHoldModeCompleted(PickupPromptsList) then
        
                                PickupPlacedObject(object.object, object.model, object.recipe)
    
                                Wait(1000)
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

end