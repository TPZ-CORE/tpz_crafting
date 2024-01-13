local TPZInv       = exports.tpz_inventory:getInventoryAPI()

ItemsList          = {}
LoadedItemsList    = false

CraftingLocations  = {}

-----------------------------------------------------------
--[[ Functions  ]]--
-----------------------------------------------------------

-- @GetTableLength returns the length of a table.
GetTableLength = function(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
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

  local finished = false

  exports["ghmattimysql"]:execute("SELECT * FROM items", { }, function(result)

    for _, res in pairs (result) do 

      ItemsList[res.item] = {}
      ItemsList[res.item] = res

      if next(result, _) == nil then
        finished = true
      end

    end

    while not finished do
      Wait(250)
    end

    LoadedItemsList = true
  end)

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

RegisterServerEvent("tpz_crafting:onCraftingRecipeReceive")
AddEventHandler("tpz_crafting:onCraftingRecipeReceive", function(item)
  local _source      = source
  local recipe       = Config.CraftingRecipes[item]

  if recipe == nil or item == nil then
    -- a recipe which doesnt exist tried to be crafted?
    -- suspicious action?
    return
  end

  local metadata = nil

  if recipe.Metadata then
    metadata = recipe.Metadata
  end

  if not recipe.IsWeapon then

    TPZInv.addItem(_source, item, recipe.Quantity, metadata)

  else

    local serialNumber = nil

    if recipe.SerialNumber then
      serialNumber = recipe.SerialNumber .. "-" .. math.random(1, 9) .. math.random(1, 9) .. math.random(1, 9) .. math.random(1, 9) .. math.random(1, 9)
    end
    
    TPZInv.addWeapon(_source, string.upper(item), serialNumber, metadata)

  end

  
  -- webhook ?
  -- notification?
end)

-- The following event is triggered when picking up a placed object to receive its ingredients
-- that have been used for the craft.
RegisterServerEvent("tpz_crafting:pickupPlacedObjectIngredients")
AddEventHandler("tpz_crafting:pickupPlacedObjectIngredients", function(ingredients)
  local _source  = source

  local length   = GetTableLength(ingredients)

  if length <= 0 or ingredients == nil then
    return
  end

  for item, quantity in pairs (ingredients) do
    TPZInv.addItem(_source, item, quantity)
  end

end)
 
-- The following event is triggered when reading a blueprint and the crafting was opened by a crafting book item
-- and not from a location, that way, we modify the item's metadata to add the unlocked blueprint properly.
RegisterServerEvent("tpz_crafting:unlockRecipeBasedOnItemId")
AddEventHandler("tpz_crafting:unlockRecipeBasedOnItemId", function(item, craftingBookItemId, craftingBookItem)
  local _source = source
  TPZInv.addItemMetadata(_source, craftingBookItem, craftingBookItemId, { ['crafting'] = { item } })
end)


RegisterServerEvent("tpz_crafting:unlockRecipeBasedOnCraftingLocation")
AddEventHandler("tpz_crafting:unlockRecipeBasedOnCraftingLocation", function(item, locationJob)

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