
--[[-------------------------------------------------------
 Handlers
]]---------------------------------------------------------

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    for _, v in pairs (Config.Locations) do

        if v.PropEntity then

            DeleteEntity(v.PropEntity)
            SetEntityAsNoLongerNeeded(v.PropEntity)

            if Config.exp_target_menu then
                TriggerEvent("exp_target_menu:RemoveEntityMenuItem", v.PropEntity, "tpz_crafting:OpenCraftingByLocationIndex")
            end
        end
        
    end

    ClearPedTasks(PlayerPedId())

end)

--[[-------------------------------------------------------
 Prompts
]]---------------------------------------------------------

Prompts       = GetRandomIntInRange(0, 0xffffff)
PromptsList   = {}

RegisterActionPrompt = function()

    --local str      = nil
    local keyPress = Config.PromptKey.key

    local dPrompt = PromptRegisterBegin()
    PromptSetControlAction(dPrompt, keyPress)
    --str = CreateVarString(10, 'LITERAL_STRING', str)
    --PromptSetText(dPrompt, str)
    PromptSetEnabled(dPrompt, 1)
    PromptSetVisible(dPrompt, 1)
    PromptSetStandardMode(dPrompt, 1)
    PromptSetHoldMode(dPrompt, 1000)
    PromptSetGroup(dPrompt, Prompts)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, dPrompt, true)
    PromptRegisterEnd(dPrompt)

    PromptsList = dPrompt
end


PickupPrompts       = GetRandomIntInRange(0, 0xffffff)
PickupPromptsList   = {}

RegisterPickupActionPrompt = function()

    local str      = Locales['PICKUP']
    local keyPress = Config.PickupObjectPromptKey.key

    local dPrompt = PromptRegisterBegin()
    PromptSetControlAction(dPrompt, keyPress)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(dPrompt, str)
    PromptSetEnabled(dPrompt, 1)
    PromptSetVisible(dPrompt, 1)
    PromptSetStandardMode(dPrompt, 1)
    PromptSetHoldMode(dPrompt, 1000)
    PromptSetGroup(dPrompt, PickupPrompts)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, dPrompt, true)
    PromptRegisterEnd(dPrompt)

    PickupPromptsList = dPrompt
end


--[[-------------------------------------------------------
 Props
]]---------------------------------------------------------


SpawnEntityProp = function(index)
    local propData = Config.Locations[index].CraftingProp
    local toVec    = vector3(propData.Coords.x, propData.Coords.y, propData.Coords.z)
    
    LoadModel(propData.Prop)

    local entity = CreateObject(joaat(propData.Prop), toVec, false, false, false, false, false)

    SetEntityVisible(entity, true)
    SetEntityHeading(entity, propData.Coords.yaw)
    SetEntityCollision(entity, true)
    FreezeEntityPosition(entity, true)

    Config.Locations[index].PropEntity = entity

    if Config.exp_target_menu then

        if Locales[propData.Prop] then
            TriggerEvent("exp_target_menu:SetModelName", GetHashKey(propData.Prop), Locales[propData.Prop])
        end

        TriggerEvent("exp_target_menu:AddEntityMenuItem", entity, "tpz_crafting:OpenCraftingByLocationIndex", Config.Locations[index].PromptActionDisplay, false)
   
    end
end


--[[-------------------------------------------------------
 General
]]---------------------------------------------------------

-- @GetTableLength returns the length of a table.
GetTableLength = function(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end


LoadModel = function(model)
    local model = joaat(model)
    RequestModel(model)

    while not HasModelLoaded(model) do RequestModel(model)
        Citizen.Wait(50)
    end
end

DrawText3D = function(x, y, z, text)
	local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)
	local px,py,pz=table.unpack(GetGameplayCamCoord())  
	local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
	local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
	if onScreen then
	  SetTextScale(0.30, 0.30)
	  SetTextFontForCurrentCommand(1)
	  SetTextColor(255, 255, 255, 215)
	  SetTextCentre(1)
	  DisplayText(str,_x,_y)
	  local factor = (string.len(text)) / 225
	  DrawSprite("feeds", "hud_menu_4a", _x, _y+0.0125,0.015+ factor, 0.03, 0.1, 35, 35, 35, 190, 0)
	end
end



PlayAnimation = function(ped, anim)
	if not DoesAnimDictExist(anim.dict) then
		return false
	end

	RequestAnimDict(anim.dict)

	while not HasAnimDictLoaded(anim.dict) do
		Wait(0)
	end

	TaskPlayAnim(ped, anim.dict, anim.base, 1.0, 1.0, -1, 1, 0.0, false, false, false, '', false)

	RemoveAnimDict(anim.dict)

	return true
end

