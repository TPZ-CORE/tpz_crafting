
local TPZInv = exports.tpz_inventory:getInventoryAPI()

-----------------------------------------------------------
--[[ General Callbacks  ]]--
-----------------------------------------------------------

exports.tpz_core:getCoreAPI().addNewCallBack("tpz_crafting:canCraftRecipe", function(source, cb, data)
  local _source      = source
  local recipe       = Config.CraftingRecipes[data.item]

  -- If for some reason the recipe does not exist, we return false.
  if recipe == nil then
    print("Error: " .. data.item .. " does not seem to exist for crafting this recipe.")
    return cb(false)
  end

  local canCarry = true
  
  if not recipe.IsBuildable then
    
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

  for item, quantity in pairs(requiredIngredients) do

    local itemQuantity = TPZInv.getItemQuantity(_source, item)

    if itemQuantity == nil or itemQuantity == 0 or itemQuantity < quantity then
      contains = false
    end

  end

  --for item, quantity in pairs(requiredIngredients) do
  --  TPZInv.removeItem(_source, item, quantity)
  --end

  cb(contains)

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

  for item, quantity in pairs(requiredIngredients) do

    local itemWeight = TPZInv.getItemWeight(item)
    totalWeight      = totalWeight + (itemWeight * quantity)

    if next(requiredIngredients, item) == nil then
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