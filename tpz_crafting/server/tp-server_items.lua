local TPZInv      = exports.tpz_inventory:getInventoryAPI()

-----------------------------------------------------------
--[[ Items Registration  ]]--
-----------------------------------------------------------

-- @param source     - returns the player source.
-- @param item       - returns the item name.
-- @param itemId     - returns the itemId (itemId exists only for non-stackable items) otherwise it will return as "0"
-- @param id         - returns the item id which is located in the tpz_items table.
-- @param label      - returns the item label name.
-- @param weight     - returns the item weight.
-- @param durability - returns the durability (exists only for non-stackable items).
-- @param metadata   - returns the metadata that you have created on the given item.

Citizen.CreateThread(function ()
	
	for item, book in pairs (Config.CraftingBookItems) do

		TPZInv.registerUsableItem(item, "tpz_crafting", function(data)
			local _source = data.source
		
			TriggerClientEvent('tpz_crafting:onCraftingBookUse', _source, item, data.itemId )
		
			TPZInv.closeInventory(_source)
		end)

	end

	
end)