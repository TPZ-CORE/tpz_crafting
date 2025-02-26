local TPZInv = exports.tpz_inventory:getInventoryAPI()

-----------------------------------------------------------
--[[ Items Registration  ]]--
-----------------------------------------------------------

Citizen.CreateThread(function ()
	
	for item, book in pairs (Config.CraftingBookItems) do

		TPZInv.registerUsableItem(item, "tpz_crafting", function(data)
			local _source = data.source
		
			TriggerClientEvent('tpz_crafting:client:onCraftingBookUse', _source, item, data.itemId )
		
			TPZInv.closeInventory(_source)
		end)

	end

	
end)