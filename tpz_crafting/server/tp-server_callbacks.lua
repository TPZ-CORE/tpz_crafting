
local TPZ    = exports.tpz_core:getCoreAPI()
local TPZInv = exports.tpz_inventory:getInventoryAPI()

-----------------------------------------------------------
--[[ General Callbacks  ]]--
-----------------------------------------------------------

exports.tpz_core:getCoreAPI().addNewCallBack("tpz_crafting:canCraftRecipe", function(source, cb, data)
  local _source      = source
    
  local xPlayer = TPZ.GetPlayer(_source)

  if xPlayer.hasLostConnection() then
    return 
  end
    
  local DoesRecipeExist, recipe = DoesRecipeExist(data.item)

  -- If for some reason the recipe does not exist, we return false.
  if not DoesRecipeExist or recipe == nil then
    print("Error: " .. data.item .. " does not seem to exist for crafting this recipe.")
    return cb(false)
  end

  local canCarry = true
  
  if not recipe.IsBuildable and not recipe.IsRepairable then
    
    canCarry = TPZInv.canCarryItem(_source, data.item, recipe.Quantity)

    if recipe.IsWeapon then
      canCarry = TPZInv.canCarryWeapon(_source, string.upper(data.item))
    end

  end

  -- If the player does not have enough inventory weight, we return false.
  if not canCarry then
    TriggerClientEvent("tpz_crafting:SendNotification", _source, Locales['NOT_ENOUGH_INVENTORY_SPACE'], 'error')
    return cb(false)
  end

  local inventory       = TPZInv.getInventoryContents(_source)
  local inventoryLength = GetTableLength(inventory)

  -- If the player has not inventory contents, we return false.
  if inventoryLength <= 0 then
    return cb(false)
  end

  local requiredIngredients = recipe.Ingredients
  local contains            = true

  for _, ingredient in pairs(requiredIngredients) do

    local itemQuantity = TPZInv.getItemQuantity(_source, ingredient.item)

    if itemQuantity == nil or itemQuantity == 0 or itemQuantity < ingredient.required_quantity then
      contains = false
    end

  end

  local hasRequiredItemId = true

  if contains and recipe.IsRepairable then

    if data.uniqueId == nil then
      data.unique = 'unknown-xxxxx'
    end

    if recipe.IsWeapon then
      hasRequiredItemId = TPZInv.doesPlayerHaveWeapon(_source, data.item, data.uniqueId)
    else
      hasRequiredItemId = TPZInv.doesPlayerHaveItemId(_source, data.item, data.uniqueId)
    end

    Wait(250)

    if not hasRequiredItemId then
      contains = false

      TriggerClientEvent("tpz_crafting:SendNotification", _source, Locales['TARGET_ID_DOES_NOT_EXIST'], 'error')
    end

  end

  if contains then

    for _, ingredient in pairs(requiredIngredients) do
      TPZInv.removeItem(_source, ingredient.item, ingredient.required_quantity)
    end

  end

  if (not contains and hasRequiredItemId) or (not contains and not hasRequiredItemId) then
    TriggerClientEvent("tpz_crafting:SendNotification", _source, Locales['NOT_ENOUGH_INGREDIENTS'], 'error')
  end

  return cb(contains)

end)

-----------------------------------------------------------
--[[ Blueprint Callbacks  ]]--
-----------------------------------------------------------

exports.tpz_core:getCoreAPI().addNewCallBack("tpz_crafting:getCraftingLocationData", function(source, cb, data)
  
  local CraftingLocations = GetCraftingLocations()
  local currentJob        = data.currentJob

  -- In case the crafting location does not exist, we create it.
  if CraftingLocations[currentJob] == nil then
    CraftingLocations[currentJob]                   = {}

    CraftingLocations[currentJob].job               = currentJob
    CraftingLocations[currentJob].unlocked_recipes  = {}
    CraftingLocations[currentJob].level             = 1
    CraftingLocations[currentJob].experience        = 0
    CraftingLocations[currentJob].actions           = 0

    exports.ghmattimysql:execute("INSERT INTO `crafting` ( `job` ) VALUES ( @job )", { ['job'] = currentJob } )

  end

  cb(CraftingLocations[currentJob].unlocked_recipes)
end)


exports.tpz_core:getCoreAPI().addNewCallBack("tpz_crafting:getCraftingBookMetadata", function(source, cb, data)
  local _source  = source
  local metadata = TPZInv.getItemMetadata(_source, data.item, data.itemId)

  cb(metadata)
end)

exports.tpz_core:getCoreAPI().addNewCallBack("tpz_crafting:startReadingRecipe", function(source, cb, data)
  local _source = source
    
  local xPlayer = TPZ.GetPlayer(_source)

  if xPlayer.hasLostConnection() then
    return 
  end

  local itemQuantity = TPZInv.getItemQuantity(_source, data.blueprint)

  if itemQuantity == nil or itemQuantity <= 0 then
    return cb(false)
  end

  TPZInv.removeItem(_source, data.blueprint, 1)

  return cb(true)
end)

-----------------------------------------------------------
--[[ Placed Object Callbacks  ]]--
-----------------------------------------------------------

exports.tpz_core:getCoreAPI().addNewCallBack("tpz_crafting:startPlacedObjectPickupAction", function(source, cb, data)
  local _source = source

  local finished  = false

  local requiredIngredients = data.ingredients

  -- If for any reason the length of Ingredients is 0, we return as true.
  local length = GetTableLength(requiredIngredients)
  if length <= 0 then
    return cb(true)
  end

  local totalWeight = 0

  for _, ingredient in pairs(requiredIngredients) do

    local itemWeight = TPZInv.getItemWeight(ingredient.item)
    totalWeight      = totalWeight + (itemWeight * ingredient.required_quantity)

    if next(requiredIngredients, _) == nil then
      finished = true
    end

  end

  while not finished do
    Wait(100)
  end

  -- @param totalWeight is the input weight you want to check if player inventory can carry.
  local canCarryWeight = TPZInv.canCarryWeight(_source, totalWeight)

  cb(canCarryWeight)

end)
