local TPZ    = exports.tpz_core:getCoreAPI()
local TPZInv = exports.tpz_inventory:getInventoryAPI()

local CraftingLocations = {}

-----------------------------------------------------------
--[[ Functions  ]]--
-----------------------------------------------------------

-- @GetTableLength returns the length of a table.
GetTableLength = function(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function GetCraftingLocations()
  return CraftingLocations
end


DoesRecipeExist = function(item)

  for index, recipe in pairs (Config.CraftingRecipes) do

    if item == recipe.Item then
      return true, recipe
    end

  end

  return false, nil

end
-----------------------------------------------------------
--[[ Base Events  ]]--
-----------------------------------------------------------

-- When resource starts, we load all the items from the database
-- The reason is that we want to get their data for displays such as labels.
AddEventHandler('onResourceStart', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then
    return
  end

  exports["ghmattimysql"]:execute("SELECT * FROM crafting", {}, function(result)

    local length = GetTableLength(result)

    if length > 0 then

      for index, res in pairs (result) do

        CraftingLocations[res.job]                   = {}
        CraftingLocations[res.job].job               = res.job
        CraftingLocations[res.job].unlocked_recipes  = json.decode(res.unlocked_recipes)
        CraftingLocations[res.job].level             = res.level
        CraftingLocations[res.job].experience        = res.experience
        CraftingLocations[res.job].actions           = res.actions

      end

    end

  end)

end)


-----------------------------------------------------------
--[[ Events  ]]--
-----------------------------------------------------------

RegisterServerEvent("tpz_crafting:server:repairCrafting")
AddEventHandler("tpz_crafting:server:repairCrafting", function(item, itemId)
  local _source = source
  local xPlayer = TPZ.GetPlayer(_source)

  -- 100% devtools injection.
  local DoesRecipeExist, RecipeData = DoesRecipeExist(item)
  if not DoesRecipeExist or item == nil then

    if Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Enabled then
      local _w, _c      = Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Url, Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Color
      local description = 'The specified user attempted to use devtools / injection cheat on stores for crafting - repairing products.'
      TPZ.SendToDiscordWithPlayerParameters(_w, Locales['DEVTOOLS_INJECTION_DETECTED_TITLE_LOG'], _source, PlayerData.steamName, PlayerData.username, PlayerData.identifier, PlayerData.charIdentifier, description, _c)
    end

    --xPlayer.disconnect(Locales['DEVTOOLS_INJECTION_DETECTED'])
    xPlayer.ban(Locales['DEVTOOLS_INJECTION_DETECTED'], -1)
    return
  end

  if RecipeData.IsWeapon then
    TPZInv.addWeaponDurability(_source, string.upper(item), 100, itemId)
  else
    TPZInv.addItemDurability(_source, item, 100, itemId)
  end

end)

RegisterServerEvent("tpz_crafting:server:receiveCraftingRecipe")
AddEventHandler("tpz_crafting:server:receiveCraftingRecipe", function(item)
  local _source = source
  local xPlayer = TPZ.GetPlayer(_source)

  -- 100% devtools injection.
  local DoesRecipeExist, RecipeData = DoesRecipeExist(item)
  if not DoesRecipeExist or item == nil then

    if Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Enabled then
      local _w, _c      = Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Url, Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Color
      local description = 'The specified user attempted to use devtools / injection cheat on stores for buying products.'
      TPZ.SendToDiscordWithPlayerParameters(_w, Locales['DEVTOOLS_INJECTION_DETECTED_TITLE_LOG'], _source, PlayerData.steamName, PlayerData.username, PlayerData.identifier, PlayerData.charIdentifier, description, _c)
    end

    --xPlayer.disconnect(Locales['DEVTOOLS_INJECTION_DETECTED'])
    xPlayer.ban(Locales['DEVTOOLS_INJECTION_DETECTED'], -1)
    return
  end

  local requiredIngredients = RecipeData.Ingredients
  local contains            = true

  -- We are checking again for ingredients in case the player performed a devtools injection / not.
  for _, ingredient in pairs(requiredIngredients) do

    local itemQuantity = xPlayer.getItemQuantity(ingredient.item)

    if itemQuantity == nil or itemQuantity == 0 or itemQuantity < ingredient.required_quantity then
      contains = false
    end

  end

  -- 100% devtools injection, player deleted the callback on client for checking the ingredients.
  if not contains then

    if Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Enabled then
      local _w, _c      = Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Url, Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Color
      local description = 'The specified user attempted to use devtools / injection cheat on stores for buying products.'
      TPZ.SendToDiscordWithPlayerParameters(_w, Locales['DEVTOOLS_INJECTION_DETECTED_TITLE_LOG'], _source, PlayerData.steamName, PlayerData.username, PlayerData.identifier, PlayerData.charIdentifier, description, _c)
    end

    xPlayer.ban(Locales['DEVTOOLS_INJECTION_DETECTED'], -1)
    --xPlayer.disconnect(Locales['DEVTOOLS_INJECTION_DETECTED'])
    return
  end

  -- We are removing the crafting ingredients.
  for _, ingredient in pairs(requiredIngredients) do
    xPlayer.removeItem(ingredient.item, ingredient.required_quantity)
  end

  -- We get the input metadata if available.
  local metadata = nil

  if RecipeData.Metadata then
    metadata = RecipeData.Metadata
  end

  -- We check if the crafted recipe is a weapon / not.
  if not RecipeData.IsWeapon then
  
    -- No need to check for canCarry, we already do on callback.
    xPlayer.addItem(item, RecipeData.Quantity, metadata)

  else

    local generatedItemId = nil

    if RecipeData.SerialNumberStart and RecipeData.SerialNumberStart ~= '' then
      local hours, minutes, seconds = os.date('%H'), os.date('%M'), os.date('%S')
      generatedItemId = RecipeData.SerialNumberStart .. "-" .. tonumber(hours) .. tonumber(minutes) .. tonumber(seconds) .. math.random(1, 9).. math.random(1, 9).. math.random(1, 9)
    end
    
    -- No need to check for canCarry, we already do on callback.
    xPlayer.addWeapon(string.upper(item), serialNumber, metadata)

  end

  -- webhook ?
  -- notification?
end)

-- The following event is triggered when picking up a placed object to receive its ingredients
-- that have been used for the craft.
RegisterServerEvent("tpz_crafting:server:pickupPlacedObject")
AddEventHandler("tpz_crafting:server:pickupPlacedObject", function(ingredients)
  local _source  = source

  local length   = GetTableLength(ingredients)

  if length <= 0 or ingredients == nil then
    -- how can ingredients be null?
    return
  end

  local totalWeight = 0

  for item, quantity in pairs(ingredients) do

    local itemWeight = TPZInv.getItemWeight(item)
    totalWeight      = totalWeight + (itemWeight * quantity)
  end

  -- @param totalWeight is the input weight you want to check if player inventory can carry.
  local canCarryWeight = TPZInv.canCarryWeight(_source, totalWeight)

  -- If somehow player had free inventory weight and not doesn't, we return.
  if not canCarryWeight then
    return
  end

  for item, quantity in pairs (ingredients) do
    TPZInv.addItem(_source, item, quantity)
  end

end)
 
-- The following event is triggered when reading a blueprint and the crafting was opened by a crafting book item
-- and not from a location, that way, we modify the item's metadata to add the unlocked blueprint properly.
RegisterServerEvent("tpz_crafting:server:unlockRecipeBasedOnItemId")
AddEventHandler("tpz_crafting:server:unlockRecipeBasedOnItemId", function(item, craftingBookItemId, craftingBookItem)
  local _source = source
  TPZInv.addItemMetadata(_source, craftingBookItem, craftingBookItemId, { ['crafting'] = { item } })
end)


RegisterServerEvent("tpz_crafting:server:unlockRecipeBasedOnCraftingLocation")
AddEventHandler("tpz_crafting:server:unlockRecipeBasedOnCraftingLocation", function(item, locationJob)

  if CraftingLocations[locationJob] == nil then
    return
  end

  table.insert(CraftingLocations[locationJob].unlocked_recipes, item)
end)

-----------------------------------------------------------
--[[ Threads  ]]--
-----------------------------------------------------------

-- Saving (Updating) Crafing Locations Data before server restart.
Citizen.CreateThread(function()
	while true do
		Wait(60000)

    local time        = os.date("*t") 
    local currentTime = table.concat({time.hour, time.min}, ":")

    local finished    = false
    local shouldSave  = false

    for index, restartHour in pairs (Config.RestartHours) do

        if currentTime == restartHour then
            shouldSave = true
        end

        if next(Config.RestartHours, index) == nil then
            finished = true
        end
    end

    while not finished do
      Wait(1000)
    end

    if shouldSave then

      local length = GetTableLength(CraftingLocations)

      if length > 0 then
          
          for _, location in pairs (CraftingLocations) do

              local Parameters = { 
                  ['job']               = location.job,
                  ['unlocked_recipes']  = json.encode(location.unlocked_recipes),
                  ['level']             = location.level,
                  ['experience']        = location.experience,
                  ['actions']           = location.actions,
              }
          
              exports.ghmattimysql:execute("UPDATE `crafting` SET `unlocked_recipes` = @unlocked_recipes, `level` = @level, `experience` = @experience,"
                  .. " `actions` = @actions WHERE job = @job", 
              Parameters)

              if Config.Debug then
                print("The following Crafting Location: " .. location.job .. " has been saved.")
            end

          end

        end
        
      end

    end

end)