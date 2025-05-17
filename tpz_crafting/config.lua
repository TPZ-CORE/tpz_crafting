Config = {}

Config.DevMode = false
Config.Debug   = false

Config.PromptKey              = { key = 0x760A9C6F } -- G
Config.PickupObjectPromptKey  = { key = 0x760A9C6F } -- G

-----------------------------------------------------------
--[[ General ]]--
-----------------------------------------------------------

-- The following option is saving all crafting locations data upon server restart hours (2-3 Minutes atleast before server restart is preferred).
Config.RestartHours = { "7:57" , "13:57", "19:57", "1:57"}

-- Set to true if you are using exp_target_menu (Made by Milyon James)
-- There is also an option for every location, but this option is focused only for
-- picking objects - buildables which have been crafted.
Config.exp_target_menu  = { enabled = false, range = 2.3 }

-- The following distance / range is used as above, but ONLY when exp_target_menu is not enabled.
Config.PickupObjectDistance = 2.0

-- The duration when a player is reading a Blueprint recipe for unlocking it.
Config.BlueprintReadingDuration = 10

-- The following is only when a notification sent while Crafting is open (It has its own notification system).
Config.NotificationColors = {
    ['error']   = "rgba(255, 0, 0, 0.79)",
    ['success'] = "rgba(0, 255, 0, 0.79)",
    ['info']    = "rgba(0, 0, 255, 0.79)"
}

-- The distance between the player and the cookable objects for allowing the player to cook a recipe.
Config.CookingObjectDistance = 2.0

-- Cookable Objects if a recipe isCookable and requires fire.
Config.CookableObjects = {
    { Object = 'p_campfire01x',      Type = 'CAMPFIRE' },
    { Object = 'p_campfire02x',      Type = 'CAMPFIRE' },
    { Object = 'p_campfire03x',      Type = 'CAMPFIRE' },
    { Object = 'p_campfire04x',      Type = 'CAMPFIRE' },
    { Object = 'p_campfire05x',      Type = 'CAMPFIRE' },
    { Object = 's_campfire01x',      Type = 'CAMPFIRE' },
    { Object = 's_campfire02x',      Type = 'CAMPFIRE' },
    { Object = 's_campfireset01x',   Type = 'CAMPFIRE' },
    { Object = 's_campfireset02x',   Type = 'CAMPFIRE' },
    { Object = 's_campfireset03x',   Type = 'CAMPFIRE' },
    { Object = 's_campfireset04x',   Type = 'CAMPFIRE' },
    { Object = 'p_campfirefresh01x', Type = 'CAMPFIRE' },
    { Object = 'p_furnace01x',       Type = 'FURNACE'  },
}

-- The animations based on every action (You can create as many as you'd like to have).
Config.AnimationTypes = {

    ['HANDCRAFT'] = { -- <- DO NOT MODIFY THE NAME
        Animation = "mech_dynamic@world_player_dynamic_kneel_ground@cook@grill1@male_a@use_idles_meat_a@idle_a",
        AnimationBase = "idle_c",

        -- If you want a scenario, set it to true and modify only the first parameter `Animation`.
        -- The second parameter `AnimationBase` is useless if animation is a scenario.
        AnimationScenario = false,

        ObjectAttachment  = false, -- Set to false if you don't want any object attachment.
    },

    ['BUILD'] = { -- <- DO NOT MODIFY THE NAME
        Animation = "amb_work@world_human_hammer_kneel_stakes@male@male_a@idle_a",
        AnimationBase = "idle_a",
        AnimationScenario = false,

        ObjectAttachment = {Object = "p_hammer04x", Attachment = "skel_r_hand", x = 0.08, y = -0.04, z = -0.05, xRot = -76.0, yRot = 10.0, zRot = 0.0},  
    },

    ['PICKUP'] = { -- <- DO NOT MODIFY THE NAME
        Animation = "amb_work@world_human_farmer_weeding@male_a@idle_b",
        AnimationBase = "idle_e",
        AnimationScenario = false,

        ObjectAttachment = false,

        Duration = 10, -- This feature is only for the following action which is for picking up objects.
    },

    ['CAMPFIRE'] = {
        Animation = "WORLD_HUMAN_FIRE_TEND_KNEEL",
        AnimationBase =  nil,
        AnimationScenario = true,

        ObjectAttachment  = false, -- Always false for Scenarios.
    },

    ['FURNACE'] = {
        Animation = "mech_dynamic@world_player_dynamic_kneel_ground@cook@grill1@male_a@use_idles_meat_a@idle_a",
        AnimationBase = "idle_c",
        AnimationScenario = false,

        ObjectAttachment  = false,
    },
}

-- The following crafting items allow you when opening, to display specific categories
-- For example, if a crafting book is based for fishermen and have fishing crafting recipes, this is the best way
-- of doing it.

-- (!) Crafting Book items must be NOT STACKABLE so they can contain metadata.
-- this is from `items` database table which has an option to be stackable / not when create a new item.
Config.CraftingBookItems = { 

    ['crafting_book'] = { 

        -- The following header will be displayed when opening the crafting menu.
        Header       = "Personal Crafting Knowledge Guide",

        -- The following description will be displayed when opening the crafting menu.
        -- Use \n for new lines.
        Description  = "Personal knowledge, a knowledge which is gained through firsthand observation or experience, as distinguished from a belief based on what someone else has said or shown to you.",

        -- The required jobs for using the following crafting book.
        -- Set to false if you don't want any jobs to be required for opening the following crafting location.
        Jobs = false,

        -- What categories should the following item display?
        -- If a category does not exist on Config.Categories, the category won't be functional.
        Categories = {
            'food',
            'crafts',
        },
    
    },

    ['crafting_fisherman_book'] = {

        Header       = "Fishing Guide",
        Description  = "",

        Jobs = { 'fisherman' },

        Categories = {
            'baits',
            'lures',
            'lines',
            'reels',
            'hooks',
        },
    
    }
}


-----------------------------------------------------------
--[[ Categories ]]--
-----------------------------------------------------------

-- The following will be the categories you will be using and their displays.
Config.Categories = {

    -- Default
    ['food']        = { Label = "Cooking Recipes" },
    ['crafts']      = { Label = "Crafts" },

    -- Saloon
    ['food_saloon'] = { Label = "Speciality Saloon Food Recipes" },

    ['blacksmith']  = { Label = "Blacksmith Crafts" },

    ['beekeepers']  = { Label = "Beekeepers Handcrafts & Honey Products" },

    ['collectors_watches']    = { Label = "Watches" },
    ['collectors_fireworks']  = { Label = "Fireworks & Firecrackers" },

    ['vets']        = { Label = "Doggie Products" },

    -- Fisherman
    ['baits']       = { Label = "Bait Recipes" },
    ['lures']       = { Label = "Lure Recipes" },
    ['lines']       = { Label = "Line Recipes" },
    ['reels']       = { Label = "Reel Recipes" },
    ['hooks']       = { Label = "Hook Recipes" },
}

-----------------------------------------------------------
--[[ Crafting Recipes ]]--
-----------------------------------------------------------

Config.CraftingRecipes = {

    -- Default Food Recipes
    ['consumable_meat_cooked'] = {
        Category          = 'food', -- The category of the following recipe, where should it be added and displayed.

        -- If the following recipe requires a blueprint, it will be unlocked only when reading a blueprint.
        -- (!) DO NOT use blueprints for PUBLIC Crafting Locations (Locations without jobs requirement).
        RequiredBlueprint = false, 

        IsWeapon          = false,  -- Specify if the recipe reward is a weapon or an item.

        -- The following is an optional feature only for weapons which allows you when creating a weapon, to generate your own serial number.
        -- this can be used for gunsmith's crafting, to start with their location.
        -- Ex: SerialNumber = "valentine", the weapon will be displayed as Serial Number: valentine-xxxxx
        SerialNumberStart = '', -- Leave it blank if you don't want the serial numbers to have a start letters (such as: val_gunsmith) -- Set to false if you don't want to modify the serial number.
        
        -- Set to false if you don't want to modify the metadata of the given item or weapon.
        -- If you want an item to have custom metadata, make sure this item is not stackable
        -- from `items` database table, otherwise the metadata, most likely will be useless.
        -- To modify or add custom metadata: Metadata = {description = ?, durability = ?, custom = ?},
        -- You can add as many custom metadata you want, existing metadata is description and durability.
        Metadata          = false, 

        -- Set to false if the following crafting recipe is not buildable and NOT in a crafting location.
        -- If its a buildable crafting recipe, you have to insert the model of that object.
        -- The following option is for buildable types which will be built directly from crafting script, such as (Campfire, Tents) 
        IsBuildable       = false,
        
        IsCookable        = true,   -- The following item will be crafted only if the player is close to a campfire or an oven.

        Quantity          = 1,      -- The quantity that will be given to the player after the recipe will be successfully crafted.
       
        Duration          = 10,     -- The time is seconds (Crafting Duration).

        Ingredients       = { ['meat'] = 1 }, -- The required ingredients for crafting the following recipe.
    
        -- The information about the crafting recipe.
        -- Use \n for new lines.
        RecipeInformation = "Cooked meat is a versatile and delicious ingredient that can be used in a variety of dishes, from savory sandwiches to hearty stews. However, proper storage and preservation are crucial to maintaining its quality, taste, and safety.",

        -- The action button image for start crafting (What should display).
        ActionDisplay     = "Press here to start cooking.",
        ProgressDisplay   = "Cooking Meat..",

        -- Set to false if you don't want to add any background image.
        -- Make sure the background image has the same size as the default one (english_breakfast.jpg).
        BackgroundImage   = false,
    },

    ['consumable_biggame_cooked'] = {
        Category          = 'food', 

        RequiredBlueprint = false,

        IsWeapon          = false,
        SerialNumberStart = '', -- Leave it blank if you don't want the serial numbers to have a start letters (such as: val_gunsmith)
        Metadata          = false,

        IsBuildable       = false,
        IsCookable        = true, 

        Quantity          = 1,

        Duration          = 12, 

        Ingredients       = { ['biggame'] = 1 },
    
        RecipeInformation = "Cooked biggame's meat is a versatile and delicious ingredient that can be used in a variety of dishes, from savory sandwiches to hearty stews. However, proper storage and preservation are crucial to maintaining its quality, taste, and safety.",

        ActionDisplay     = "Press here to start cooking.",
        ProgressDisplay   = "Cooking BigGame Meat..",

        BackgroundImage   = false,
    },

    ['consumable_bison_cooked'] = {
        Category          = 'food', 

        RequiredBlueprint = false, 

        IsWeapon          = false,
        SerialNumberStart = '', -- Leave it blank if you don't want the serial numbers to have a start letters (such as: val_gunsmith)
        Metadata          = false,

        IsBuildable       = false,
        IsCookable        = true, 

        Quantity          = 1,

        Duration          = 12, 

        Ingredients       = { ['bison_meat'] = 1 },
    
        RecipeInformation = "Cooked bison's meat is a versatile and delicious ingredient that can be used in a variety of dishes, from savory sandwiches to hearty stews. However, proper storage and preservation are crucial to maintaining its quality, taste, and safety.",

        ActionDisplay     = "Press here to start cooking.",
        ProgressDisplay   = "Cooking Bison Meat..",

        BackgroundImage   = false,
    },
    
    -------------------------------------
    -- Crafts                          --
    -------------------------------------

    ['campfire'] = {
        Category          = 'crafts', 

        RequiredBlueprint = false, 

        IsWeapon          = false, -- Always false if the recipe is buildable.
        SerialNumberStart = '', -- Leave it blank if you don't want the serial numbers to have a start letters (such as: val_gunsmith) -- Always false if the recipe is buildable.
        Metadata          = false, -- Always false if the recipe is buildable.

        IsBuildable       = "p_campfire05x",
        IsCookable        = false,   -- Always false if the recipe is buildable.

        Quantity          = 1,  -- Always (1) if the recipe is buildable.

        Duration          = 15, 

        Ingredients       = { ['rock'] = 6, ['wooden_sticks'] = 6},
    
        RecipeInformation = "A campfire is a fire at a campsite that provides light and warmth, and heat for cooking. It can also serve as a beacon, and an insect and predator deterrent. Established campgrounds often provide a stone or steel fire ring for safety.",

        ActionDisplay     = "Press here to start crafting.",
        ProgressDisplay   = "Crafting Campfire..",

        BackgroundImage   = false,
    },

    ['tent'] = {
        Category          = 'crafts', 

        RequiredBlueprint = 'blueprint_tent',

        IsWeapon          = false, -- Always false if the recipe is buildable.
        SerialNumberStart = '', -- Leave it blank if you don't want the serial numbers to have a start letters (such as: val_gunsmith) -- Always false if the recipe is buildable.
        Metadata          = false, -- Always false if the recipe is buildable.

        IsBuildable       = "mp005_s_posse_tent_bountyhunter07x",
        IsCookable        = false,   -- Always false if the recipe is buildable.

        Quantity          = 1,  -- Always (1) if the recipe is buildable.

        Duration          = 30, 

        Ingredients       = { ['wooden_sticks'] = 10, ['wooden_planks'] = 20, ['fabric'] = 10, ['leather'] = 10, ['fibers'] = 6 },
    
        RecipeInformation = "A Tent is temporary accommodation which can be easily dismantled and which is portable. A tent is a movable, lightweight shelter which uses fabric to protect people from wind, rain and from the cold.\nIt also provides a private and comfortable place to sleep and store your gear. Without a tent, you would be exposed to the elements, insects, and wildlife.",

        ActionDisplay     = "Press here to start crafting.",
        ProgressDisplay   = "Crafting Tent..",

        BackgroundImage   = false,
    },
    
    -------------------------------------
    -- Vet                             --
    -------------------------------------

    ['mydog_snacks'] = {
        Category          = 'vets',

        RequiredBlueprint = false,

        IsWeapon          = false,
        SerialNumberStart = '', -- Leave it blank if you don't want the serial numbers to have a start letters (such as: val_gunsmith)
        Metadata          = false,

        IsCookable        = false,

        Quantity          = 4,

        Duration          = 15,

        Ingredients       = { ['minced_meat'] = 1, ['wild_carrot'] = 1, ['corn'] = 1 },

        RecipeInformation = "A doggie snacks meal is used for training purposes, only a doggie snack, so delicious for them can make them to focus and be trained well under any circumstances.",
        ActionDisplay     = "Press here to start crafting.",
        ProgressDisplay   = "Preparing doggie snacks..",

        BackgroundImage   = false,
    },

    
    ['vetsyringe'] = {
        Category          = 'vets',

        RequiredBlueprint = false,

        IsWeapon          = false,
        SerialNumberStart = '', -- Leave it blank if you don't want the serial numbers to have a start letters (such as: val_gunsmith)
        Metadata          = false,

        IsCookable        = false,

        Quantity          = 4,

        Duration          = 10,

        Ingredients       = { },

        RecipeInformation = "A vet dog syringe is used when a dog is unconscious, its increasing the dogs heart pulse.",
        ActionDisplay     = "Press here to start crafting.",
        ProgressDisplay   = "Preparing a dog syringe..",

        BackgroundImage   = false,
    },

    -------------------------------------
    -- Blacksmith                      --
    -------------------------------------

    ['shellcasing'] = {
        Category          = 'blacksmith',

        RequiredBlueprint = false,

        IsWeapon          = false,
        SerialNumberStart = '', -- Leave it blank if you don't want the serial numbers to have a start letters (such as: val_gunsmith)
        Metadata          = false,

        IsCookable        = false,

        Quantity          = 10,

        Duration          = 10,

        Ingredients       = { ['copper'] = 10 },

        RecipeInformation = "A breakfast lover's dream! These honey pancakes are light and fluffy with a subtly sweet flavor from the honey. They're easy to make and freezer-friendly!",
        ActionDisplay     = "Press here to start crafting.",
        ProgressDisplay   = "Preparing empty shell casing..",

        BackgroundImage   = false,
    },
 
    ['nails'] = {
        Category          = 'blacksmith',

        RequiredBlueprint = false,

        IsWeapon          = false,
        SerialNumberStart = '', -- Leave it blank if you don't want the serial numbers to have a start letters (such as: val_gunsmith)
        Metadata          = false,

        IsCookable        = false,

        Quantity          = 10,

        Duration          = 10,

        Ingredients       = { ['iron'] = 10  },

        RecipeInformation = "A breakfast lover's dream! These honey pancakes are light and fluffy with a subtly sweet flavor from the honey. They're easy to make and freezer-friendly!",
        ActionDisplay     = "Press here to start crafting.",
        ProgressDisplay   = "Preparing nails..",

        BackgroundImage   = false,
    },
            
    ['wrench'] = {
        Category          = 'blacksmith',

        RequiredBlueprint = false,

        IsWeapon          = false,
        SerialNumberStart = '', -- Leave it blank if you don't want the serial numbers to have a start letters (such as: val_gunsmith)
        Metadata          = false,

        IsCookable        = false,

        Quantity          = 1,

        Duration          = 5,

        Ingredients       = { ['metal'] = 1 },

        RecipeInformation = "A breakfast lover's dream! These honey pancakes are light and fluffy with a subtly sweet flavor from the honey. They're easy to make and freezer-friendly!",
        ActionDisplay     = "Press here to start crafting.",
        ProgressDisplay   = "Preparing wrench..",

        BackgroundImage   = false,
    },

    ['ironhorseshoe'] = {
        Category          = 'blacksmith',

        RequiredBlueprint = false,

        IsWeapon          = false,
        SerialNumberStart = '', -- Leave it blank if you don't want the serial numbers to have a start letters (such as: val_gunsmith)
        Metadata          = false,

        IsCookable        = false,

        Quantity          = 1,

        Duration          = 5,

        Ingredients       = { ['silver'] = 1, ['copper'] = 1 },

        RecipeInformation = "A breakfast lover's dream! These honey pancakes are light and fluffy with a subtly sweet flavor from the honey. They're easy to make and freezer-friendly!",
        ActionDisplay     = "Press here to start crafting.",
        ProgressDisplay   = "Preparing iron horse shoes..",

        BackgroundImage   = false,
    },

    ['silverhorseshoe'] = {
        Category          = 'blacksmith',

        RequiredBlueprint = false,

        IsWeapon          = false,
        SerialNumberStart = '', -- Leave it blank if you don't want the serial numbers to have a start letters (such as: val_gunsmith)
        Metadata          = false,

        IsCookable        = false,

        Quantity          = 1,

        Duration          = 10,

        Ingredients       = { ['silver'] = 1, ['copper'] = 2 },

        RecipeInformation = "A breakfast lover's dream! These honey pancakes are light and fluffy with a subtly sweet flavor from the honey. They're easy to make and freezer-friendly!",
        ActionDisplay     = "Press here to start crafting.",
        ProgressDisplay   = "Preparing silver horse shoes..",

        BackgroundImage   = false,
    },

    ['goldhorseshoe'] = {
        Category          = 'blacksmith',

        RequiredBlueprint = false,

        IsWeapon          = false,
        SerialNumberStart = '', -- Leave it blank if you don't want the serial numbers to have a start letters (such as: val_gunsmith)
        Metadata          = false,

        IsCookable        = false,

        Quantity          = 1,

        Duration          = 15,

        Ingredients       = { ['goldfragment'] = 1, ['silver'] = 1, ['copper'] = 2 },

        RecipeInformation = "A breakfast lover's dream! These honey pancakes are light and fluffy with a subtly sweet flavor from the honey. They're easy to make and freezer-friendly!",
        ActionDisplay     = "Press here to start crafting.",
        ProgressDisplay   = "Preparing golden horse shoes..",

        BackgroundImage   = false,
    },

    
    ['steel'] = {
        Category          = 'blacksmith',

        RequiredBlueprint = false,

        IsWeapon          = false,
        SerialNumberStart = '', -- Leave it blank if you don't want the serial numbers to have a start letters (such as: val_gunsmith)
        Metadata          = false,

        IsCookable        = false,

        Quantity          = 1,

        Duration          = 10,

        Ingredients       = { ['iron'] = 2 },

        RecipeInformation = "A breakfast lover's dream! These honey pancakes are light and fluffy with a subtly sweet flavor from the honey. They're easy to make and freezer-friendly!",
        ActionDisplay     = "Press here to start crafting.",
        ProgressDisplay   = "Preparing steel..",

        BackgroundImage   = false,
    },

    
    ['metal'] = {
        Category          = 'blacksmith',

        RequiredBlueprint = false,

        IsWeapon          = false,
        SerialNumberStart = '', -- Leave it blank if you don't want the serial numbers to have a start letters (such as: val_gunsmith)
        Metadata          = false,

        IsCookable        = false,

        Quantity          = 1,

        Duration          = 10,

        Ingredients       = { ['iron'] = 2 },

        RecipeInformation = "A breakfast lover's dream! These honey pancakes are light and fluffy with a subtly sweet flavor from the honey. They're easy to make and freezer-friendly!",
        ActionDisplay     = "Press here to start crafting.",
        ProgressDisplay   = "Preparing metal..",

        BackgroundImage   = false,
    },

    ['ironbar'] = {
        Category          = 'blacksmith',

        RequiredBlueprint = false,

        IsWeapon          = false,
        SerialNumberStart = '', -- Leave it blank if you don't want the serial numbers to have a start letters (such as: val_gunsmith)
        Metadata          = false,

        IsCookable        = false,

        Quantity          = 1,

        Duration          = 15,

        Ingredients       = { ['iron'] = 10 },

        RecipeInformation = "A breakfast lover's dream! These honey pancakes are light and fluffy with a subtly sweet flavor from the honey. They're easy to make and freezer-friendly!",
        ActionDisplay     = "Press here to start crafting.",
        ProgressDisplay   = "Preparing iron bar..",

        BackgroundImage   = false,
    },

    
    ['goldbar'] = {
        Category          = 'blacksmith',

        RequiredBlueprint = false,

        IsWeapon          = false,
        SerialNumberStart = '', -- Leave it blank if you don't want the serial numbers to have a start letters (such as: val_gunsmith)
        Metadata          = false,

        IsCookable        = false,

        Quantity          = 1,

        Duration          = 25,

        Ingredients       = { ['goldnugget'] = 20 },

        RecipeInformation = "A breakfast lover's dream! These honey pancakes are light and fluffy with a subtly sweet flavor from the honey. They're easy to make and freezer-friendly!",
        ActionDisplay     = "Press here to start crafting.",
        ProgressDisplay   = "Preparing gold bar..",

        BackgroundImage   = false,
    },

    ['goldnugget'] = {
        Category          = 'blacksmith',

        RequiredBlueprint = false,

        IsWeapon          = false,
        SerialNumberStart = '', -- Leave it blank if you don't want the serial numbers to have a start letters (such as: val_gunsmith)
        Metadata          = false,

        IsCookable        = false,

        Quantity          = 20,

        Duration          = 25,

        Ingredients       = { ['goldbar'] = 1 },

        RecipeInformation = "A breakfast lover's dream! These honey pancakes are light and fluffy with a subtly sweet flavor from the honey. They're easy to make and freezer-friendly!",
        ActionDisplay     = "Press here to start crafting.",
        ProgressDisplay   = "Preparing gold nuggets..",

        BackgroundImage   = false,
    },

    -------------------------------------
    -- Beekeepers                      --
    -------------------------------------

    ['empty_jar'] = {
        Category          = 'beekeepers',

        RequiredBlueprint = false,

        IsWeapon          = false,
        SerialNumberStart = '', -- Leave it blank if you don't want the serial numbers to have a start letters (such as: val_gunsmith)
        Metadata          = false,

        IsCookable        = false,

        Quantity          = 1,

        Duration          = 5,

        Ingredients       = { ['emptybottle'] = 1, ['fibers'] = 1, ['fabric'] = 1 },

        RecipeInformation = "An empty bee jar is used for collecting any kind of bees or hornets and storing them properly for the beehives.",
        ActionDisplay     = "Press here to start crafting.",
        ProgressDisplay   = "Preparing an empty bee jar..",

        BackgroundImage   = false,
    },

    
    ['insect_medicine'] = {
        Category          = 'beekeepers',

        RequiredBlueprint = false,

        IsWeapon          = false,
        SerialNumberStart = '', -- Leave it blank if you don't want the serial numbers to have a start letters (such as: val_gunsmith)
        Metadata          = false,

        IsCookable        = false,

        Quantity          = 1,

        Duration          = 10,

        Ingredients       = { ['canteenempty'] = 1, ['sugar'] = 1, ['Alaskan_Ginseng'] = 1 },

        RecipeInformation = "Insects Medicine, a required medicine to be used on beehives for protecting your bees or hornets from any kind of insects, by not using it, your beehives will be completely destroyed after an amount of time.",
        ActionDisplay     = "Press here to start crafting.",
        ProgressDisplay   = "Preparing a medicine for insects..",

        BackgroundImage   = false,
    },

    ['small_honey_jar'] = {
        Category          = 'beekeepers',

        RequiredBlueprint = false,

        IsWeapon          = false,
        SerialNumberStart = '', -- Leave it blank if you don't want the serial numbers to have a start letters (such as: val_gunsmith)
        Metadata          = false,

        IsCookable        = false,

        Quantity          = 5,

        Duration          = 30,

        Ingredients       = { ['emptybottle'] = 5, ['honey'] = 1 },

        RecipeInformation = "A small honey jar is a jar (with low weight) that has been filled with collected honey from the bees or beehives.",
        ActionDisplay     = "Press here to start crafting.",
        ProgressDisplay   = "Preparing a small honey jar..",

        BackgroundImage   = false,
    },

    ['consumable_tootsie_roll'] = {
        Category          = 'beekeepers',

        RequiredBlueprint = false,

        IsWeapon          = false,
        SerialNumberStart = '', -- Leave it blank if you don't want the serial numbers to have a start letters (such as: val_gunsmith)
        Metadata          = false,

        IsCookable        = false,

        Quantity          = 5,

        Duration          = 30,

        Ingredients       = { ['butter'] = 1, ['small_honey_jar'] = 1, ['cocoa'] = 1 },

        RecipeInformation = "Tootsie Roll (/ˈtʊtsi/) is a chocolate-flavored candy (we are using honey as replacement) that has been manufactured in the United States since 1907. The candy has qualities similar to both caramels and taffy without being exactly either confection. The manufacturer, Tootsie Roll Industries, is based in Chicago, Illinois.",
        ActionDisplay     = "Press here to start crafting.",
        ProgressDisplay   = "Preparing honey totsie rolls..",

        BackgroundImage   = false,
    },

    -------------------------------------
    -- Gunsmith                        --
    -------------------------------------

    ['weapon_screws'] = {
        Category          = 'gunsmith_parts',

        RequiredBlueprint = false,

        IsWeapon          = false,
        SerialNumberStart = '', -- Leave it blank if you don't want the serial numbers to have a start letters (such as: val_gunsmith)
        Metadata          = false,

        IsCookable        = false,

        Quantity          = 10,

        Duration          = 10,

        Ingredients       = { ['copper'] = 10 },

        RecipeInformation = "A breakfast lover's dream! These honey pancakes are light and fluffy with a subtly sweet flavor from the honey. They're easy to make and freezer-friendly!",
        ActionDisplay     = "Press here to start crafting.",
        ProgressDisplay   = "Preparing weapon screws..",

        BackgroundImage   = false,
    },

    ['weapon_spring'] = {
        Category          = 'gunsmith_parts',

        RequiredBlueprint = false,

        IsWeapon          = false,
        SerialNumberStart = '', -- Leave it blank if you don't want the serial numbers to have a start letters (such as: val_gunsmith)
        Metadata          = false,

        IsCookable        = false,

        Quantity          = 1,

        Duration          = 5,

        Ingredients       = { ['copper'] = 1, ['steel'] = 1 },

        RecipeInformation = "A breakfast lover's dream! These honey pancakes are light and fluffy with a subtly sweet flavor from the honey. They're easy to make and freezer-friendly!",
        ActionDisplay     = "Press here to start crafting.",
        ProgressDisplay   = "Preparing weapon spring..",

        BackgroundImage   = false,
    },

    ['weapon_trigger'] = {
        Category          = 'gunsmith_parts',

        RequiredBlueprint = false,

        IsWeapon          = false,
        SerialNumberStart = '', -- Leave it blank if you don't want the serial numbers to have a start letters (such as: val_gunsmith)
        Metadata          = false,

        IsCookable        = false,

        Quantity          = 1,

        Duration          = 5,

        Ingredients       = { ['copper'] = 1, ['steel'] = 1 },

        RecipeInformation = "A breakfast lover's dream! These honey pancakes are light and fluffy with a subtly sweet flavor from the honey. They're easy to make and freezer-friendly!",
        ActionDisplay     = "Press here to start crafting.",
        ProgressDisplay   = "Preparing weapon screws..",

        BackgroundImage   = false,
    },

    ['weapon_trigger'] = {
        Category          = 'gunsmith_parts',

        RequiredBlueprint = false,

        IsWeapon          = false,
        SerialNumberStart = '', -- Leave it blank if you don't want the serial numbers to have a start letters (such as: val_gunsmith)
        Metadata          = false,

        IsCookable        = false,

        Quantity          = 1,

        Duration          = 5,

        Ingredients       = { ['copper'] = 1, ['steel'] = 1 },

        RecipeInformation = "A breakfast lover's dream! These honey pancakes are light and fluffy with a subtly sweet flavor from the honey. They're easy to make and freezer-friendly!",
        ActionDisplay     = "Press here to start crafting.",
        ProgressDisplay   = "Preparing weapon screws..",

        BackgroundImage   = false,
    },


    -------------------------------------
    -- Saloon Food Recipes             --
    -------------------------------------

    ['consumable_vegstew'] = {
        Category          = 'food_saloon',

        RequiredBlueprint = false,

        IsWeapon          = false,
        SerialNumberStart = '', -- Leave it blank if you don't want the serial numbers to have a start letters (such as: val_gunsmith)
        Metadata          = false,

        IsCookable        = true,

        Quantity          = 1,

        Duration          = 25,

        Ingredients       = { ['bowl'] = 1, ['potato'] = 1, ['wild_carrot'] = 1, ['crows_garlic'] = 1, ['parasol_mushroom'] = 1, ['salt'] = 1},

        RecipeInformation = "Vegetable stew is a hearty and comforting recipe made with a variety of vegetables cooked in a flavorful broth! It is a healthy and versatile meal. Great for the colder weather, family dinners, meal prep, and leftovers!",
        ActionDisplay     = "Press here to start cooking.",
        ProgressDisplay   = "Preparing veggie stew..",

        BackgroundImage   = false, -- "english_breakfast.jpg"
    },


}

-----------------------------------------------------------
--[[ Crafting Locations ]]--
-----------------------------------------------------------

-- (!) DO NOT use blueprints as requirement on crafting locations.
Config.Locations = {

        [1] = { -- Smith Fields Saloon (Valentine)

        -- Supports exp_target_menu (Made by Milyon James)
        -- Set to true only if you are using this script and most important
        -- ONLY if the crafting / cooking location has an object / prop to support it.
        -- (CraftingProp always supports exp_target_menu if enabled and spawned custom prop)
        TargetMenu = {
            Enabled = false,

            -- What prop should the system search close to the ActionDistance?
            -- If the prop won't have any target menu action, increase the ActionDistance.
            -- The following system will be checking for the existing object ONLY if 
            -- CraftingProp.Enabled == false.
            Object = 'p_furnace01x',
        },

        Jobs = {'valsaloon'}, -- (!) SET to false if you don't want any jobs to be required for opening the following crafting location.

        Coords = { x = -308.6759338378906, y = 804.716552734375, z = 118.98242950439453, h = 197.177 },

        ActionDistance = 1.1, -- The distance to open the crafting book or target an object (if exp_target_menu is enabled).
        PromptActionDisplay = 'Checkout Cooking Recipes',
        PromptFooterDisplay = 'Smith Fields Saloon',

        DrawText = 'Cooking Furnace', -- Set to false if you don't want to draw any text.
        DrawTextRenderDistance = 4, -- The distance of the drawtext to be displayed.

        Header       = "Smith Fields Saloon Cooking Guide", -- The following header is displayed when opening the crafting menu.
        
        -- The following description will be displayed when opening the crafting menu.
        -- Use \n for new lines.
        Description  = "Welcome to our Saloon Cooking Guide, below, our saloon simply recipes will be displayed to assist you so you can receive some experience and provide the best food for our customers based on their needs.",
        
        CraftingProp = {
            Enabled = false,

            Coords = {x = 0.0, y = 0.0, z = 0.0, yaw = 0.0 },
            
            Prop    = 'p_furnace01x',
            RenderDistance = 15,
        },

        -- SET to false if you want only the basic animation (HANDCRAFT), otherwise
        -- you can select an existing one directly from Config.AnimationTypes
        AnimationType = "FURNACE", -- false

        -- The categories of the following crafting location that should be displayed in the crafting menu.
        -- If a category does not exist on Config.Categories, it won't be displayed,
        Categories = { 'food_saloon' },
    },

    [2] = {

        TargetMenu = {
            Enabled = false,
            Object = 'p_furnace01x',
        },

        Jobs = {'keanessaloon'}, 

        Coords = { x = -238.69558715820312, y = 766.9777221679688, z = 118.06407928466797, h = 207.45 },

        ActionDistance = 1.1,
        PromptActionDisplay = 'Checkout Cooking Recipes',
        PromptFooterDisplay = 'Keanes Saloon',

        DrawText = 'Cooking Furnace',
        DrawTextRenderDistance = 4,

        Header       = "Keanes Saloon Cooking Guide", 
        Description  = "Welcome to our Saloon Cooking Guide, below, our saloon simply recipes will be displayed to assist you so you can receive some experience and provide the best food for our customers based on their needs.",
        
        CraftingProp = {
            Enabled = false,

            Coords = {x = 0.0, y = 0.0, z = 0.0, yaw = 0.0 },
            
            Prop    = 'p_furnace01x',
            RenderDistance = 15,
        },

        AnimationType = "FURNACE", -- false
        Categories = { 'food_saloon' },
    },

    [3] = {

        TargetMenu = {
            Enabled = false,
            Object = 'p_furnace01x',
        },

        Jobs = {'rhsaloon'}, 

        Coords = { x = 1339.85888671875, y = -1375.54052734375, z = 80.49285888671875, h = 174.71983337402 },

        ActionDistance = 1.1,
        PromptActionDisplay = 'Checkout Cooking Recipes',
        PromptFooterDisplay = 'Rhodes Saloon',

        DrawText = 'Cooking Furnace',
        DrawTextRenderDistance = 4,

        Header       = "Rhodes Saloon Cooking Guide", 
        Description  = "Welcome to our Saloon Cooking Guide, below, our saloon simply recipes will be displayed to assist you so you can receive some experience and provide the best food for our customers based on their needs.",
        
        CraftingProp = {
            Enabled = true,

            Coords = {x = 1339.85888671875, y = -1375.54052734375, z = 79.49285888671875, yaw = 170.99151611328125 },
            
            Prop    = 'p_furnace01x',
            RenderDistance = 15,
        },

        AnimationType = "FURNACE", -- false
        Categories = { 'food_saloon' },
    },

    [4] = {

        TargetMenu = {
            Enabled = false,
            Object = 'p_furnace01x',
        },

        Jobs = {'stsaloon'}, 

        Coords = { x = 2637.86865234375, y = -1220.630126953125, z = 53.39260482788086, h = 9.0273380279541 },

        ActionDistance = 1.1,
        PromptActionDisplay = 'Checkout Cooking Recipes',
        PromptFooterDisplay = 'Saint Denis Saloon',

        DrawText = 'Cooking Furnace',
        DrawTextRenderDistance = 4,

        Header       = "Saint Denis Saloon Cooking Guide", 
        Description  = "Welcome to our Saloon Cooking Guide, below, our saloon simply recipes will be displayed to assist you so you can receive some experience and provide the best food for our customers based on their needs.",
        
        CraftingProp = {
            Enabled = true,

            Coords = {x = 2637.86865234375, y = -1220.630126953125, z = 52.39260482788086, yaw = 0.04559731483459 },
            
            Prop    = 'p_furnace01x',
            RenderDistance = 15,
        },

        AnimationType = "FURNACE", -- false
        Categories = { 'food_saloon' },
    },

    [5] = {

        TargetMenu = {
            Enabled = false,
            Object = 'p_furnace01x',
        },

        Jobs = {'vanhornsaloon'}, 

        Coords = { x = 2951.06396484375, y = 525.6841430664062, z = 45.35223770141601, h = 281.60171508789 },

        ActionDistance = 1.1,
        PromptActionDisplay = 'Checkout Cooking Recipes',
        PromptFooterDisplay = 'Van Horn Saloon',

        DrawText = 'Cooking Furnace',
        DrawTextRenderDistance = 4,

        Header       = "Van Horn Saloon Cooking Guide", 
        Description  = "Welcome to our Saloon Cooking Guide, below, our saloon simply recipes will be displayed to assist you so you can receive some experience and provide the best food for our customers based on their needs.",
        
        CraftingProp = {
            Enabled = true,

            Coords = { x = 2951.06396484375, y = 525.6841430664062, z = 44.35223770141601, yaw = -90.03150177001953 },
            
            Prop    = 'p_furnace01x',
            RenderDistance = 15,
        },

        AnimationType = "FURNACE", -- false
        Categories = { 'food_saloon' },
    },

    [6] = {

        TargetMenu = {
            Enabled = false,
            Object = 'p_furnace01x',
        },

        Jobs = {'bwsaloon'}, 

        Coords = { x = -822.6748046875, y = -1321.460693359375, z = 43.69108581542969, h = 5.048969745636 },

        ActionDistance = 1.1,
        PromptActionDisplay = 'Checkout Cooking Recipes',
        PromptFooterDisplay = 'Black Water Saloon',

        DrawText = 'Cooking Furnace',
        DrawTextRenderDistance = 4,

        Header       = "Black Water Saloon Cooking Guide", 
        Description  = "Welcome to our Saloon Cooking Guide, below, our saloon simply recipes will be displayed to assist you so you can receive some experience and provide the best food for our customers based on their needs.",
        
        CraftingProp = {
            Enabled = true,

            Coords = { x = -822.6748046875, y = -1321.460693359375, z = 42.69108581542969, yaw = 0.57236450910568 },
            
            Prop    = 'p_furnace01x',
            RenderDistance = 15,
        },

        AnimationType = "FURNACE", -- false
        Categories = { 'food_saloon' },
    },

    -- BLACKSMITHS

    [7] = {

        TargetMenu = {
            Enabled = false,
            Object = 'p_workbench01x',
        },

        Jobs = {'sdblacksmith'}, 

        Coords = { x = 2692.067, y = -822.679, z = 42.293, h = 114.07 },

        ActionDistance = 1.1,
        PromptActionDisplay = 'Checkout Handcrafts',
        PromptFooterDisplay = 'Saint Denis Blacksmith',

        DrawText = 'Blacksmith Handcrafts',
        DrawTextRenderDistance = 4,

        Header       = "Blacksmith Crafting Guide", 
        Description  = "Welcome to our Blacksmith Crafting Guide, below, all our crafting recipes will be displayed to assist you so you can receive some experience and provide the best quality of crafts for our customers based on their preferences and their needs.",
        
        CraftingProp = {
            Enabled = false,

            Coords = {  },
            
            Prop    = 'p_workbench01x',
            RenderDistance = 15,
        },

        AnimationType = false, -- false
        Categories = { 'blacksmith' },
    },

    [8] = {

        TargetMenu = {
            Enabled = false,
            Object = 'p_workbench01x',
        },

        Jobs = {'blacksmith'}, 

        Coords = { x = -369.381, y = 796.3142, z = 116.19, h = 99.56 },

        ActionDistance = 1.1,
        PromptActionDisplay = 'Checkout Handcrafts',
        PromptFooterDisplay = 'Valentine Blacksmith',

        DrawText = 'Blacksmith Handcrafts',
        DrawTextRenderDistance = 4,

        Header       = "Blacksmith Crafting Guide", 
        Description  = "Welcome to our Blacksmith Crafting Guide, below, all our crafting recipes will be displayed to assist you so you can receive some experience and provide the best quality of crafts for our customers based on their preferences and their needs.",
        
        CraftingProp = {
            Enabled = false,

            Coords = {  },
            
            Prop    = 'p_workbench01x',
            RenderDistance = 15,
        },

        AnimationType = false, -- false
        Categories = { 'blacksmith' },
    },

    
    [9] = {

        TargetMenu = {
            Enabled = false,
            Object = 'p_workbench01x',
        },

        Jobs = {'strblacksmith'}, 

        Coords = { x = -1820.27, y = -568.013, z = 156.00, h = 41.40 },

        ActionDistance = 1.1,
        PromptActionDisplay = 'Checkout Handcrafts',
        PromptFooterDisplay = 'Strawberry Blacksmith',

        DrawText = 'Blacksmith Handcrafts',
        DrawTextRenderDistance = 4,

        Header       = "Blacksmith Crafting Guide", 
        Description  = "Welcome to our Blacksmith Crafting Guide, below, all our crafting recipes will be displayed to assist you so you can receive some experience and provide the best quality of crafts for our customers based on their preferences and their needs.",
        
        CraftingProp = {
            Enabled = false,

            Coords = {  },
            
            Prop    = 'p_workbench01x',
            RenderDistance = 15,
        },

        AnimationType = false, -- false
        Categories = { 'blacksmith' },
    },

    [10] = {

        TargetMenu = {
            Enabled = false,
            Object = 'p_workbench01x',
        },

        Jobs = {'bwblacksmith'}, 

        Coords = { x = -870.213, y = -1389.13, z = 43.525, h = 355.85168457031 },

        ActionDistance = 1.1,
        PromptActionDisplay = 'Checkout Handcrafts',
        PromptFooterDisplay = 'Blackwater Blacksmith',

        DrawText = 'Blacksmith Handcrafts',
        DrawTextRenderDistance = 4,

        Header       = "Blacksmith Crafting Guide", 
        Description  = "Welcome to our Blacksmith Crafting Guide, below, all our crafting recipes will be displayed to assist you so you can receive some experience and provide the best quality of crafts for our customers based on their preferences and their needs.",
        
        CraftingProp = {
            Enabled = false,

            Coords = {  },
            
            Prop    = 'p_workbench01x',
            RenderDistance = 15,
        },

        AnimationType = false, -- false
        Categories = { 'blacksmith' },
    },

    -- Beekeepers

    [11] = {

        TargetMenu = {
            Enabled = false,
            Object = 'p_workbench01x',
        },

        Jobs = {'beekeeper'}, 

        Coords = { x = -1553.22, y = 249.5491, z = 114.81, h = 206.38107299805 },

        ActionDistance = 1.1,
        PromptActionDisplay = 'Checkout Products & Handcrafts',
        PromptFooterDisplay = 'Strawberry Beekeeper',

        DrawText = 'Strawberry Beekeeper',
        DrawTextRenderDistance = 4,

        Header       = "Beekeepers Crafting & Products Guide", 
        Description  = "Welcome to the Beekeepers Handcrafts & Products Guide, below, all our crafting recipes will be displayed to assist you so you can receive some experience and provide the best quality of crafts for our customers based on their preferences and their needs.",
        
        CraftingProp = {
            Enabled = false,

            Coords = {  },
            
            Prop    = 'p_workbench01x',
            RenderDistance = 15,
        },

        AnimationType = false, -- false
        Categories = { 'beekeepers' },
    },

    -- vets

    [12] = {

        TargetMenu = {
            Enabled = false,
            Object = 'p_workbench01x',
        },

        Jobs = {'vet'}, 

        Coords = { x = -1676.05, y = -340.846, z = 170.78, h = 232.70013427734 },

        ActionDistance = 1.1,
        PromptActionDisplay = 'Checkout Doggie Products',
        PromptFooterDisplay = 'Vet',

        DrawText = 'Vet',
        DrawTextRenderDistance = 4,

        Header       = "Vet Doggie Products Guide", 
        Description  = "Welcome to the Vet Doggie Products Guide, below, all our crafting recipes will be displayed to assist you so you can receive some experience and provide the best quality of crafts for our customers based on their preferences and their needs.",
        
        CraftingProp = {
            Enabled = false,

            Coords = {  },
            
            Prop    = 'p_workbench01x',
            RenderDistance = 15,
        },

        AnimationType = false, -- false
        Categories = {'vets'},
    },
    
    [13] = { -- Annesburg Saloon


        TargetMenu = {
            Enabled = false,
            Object = 'p_furnace01x',
        },

        Jobs = {'annessaloon'}, 

        Coords = { x = 2961.692138671875, y = 1346.189453125, z = 44.66775131225586, h = 344.8 },

        ActionDistance = 1.2,
        PromptActionDisplay = 'Checkout Cooking Recipes',
        PromptFooterDisplay = 'Annesburg Saloon',

        DrawText = 'Cooking Oven',
        DrawTextRenderDistance = 4,

        Header       = "Annesburg Saloon Cooking Guide", 
        Description  = "Welcome to our Saloon Cooking Guide, below, our saloon simply recipes will be displayed to assist you so you can receive some experience and provide the best food for our customers based on their needs.",
        
        CraftingProp = {
            Enabled = false,

            Coords = {x = 0.0, y = 0.0, z = 0.0, yaw = 0.0 },
            
            Prop    = 'p_furnace01x',
            RenderDistance = 15,
        },

        AnimationType = false, -- false
        Categories = { 'food_saloon' },
    },

    [14] = { -- Emerald Saloon


        TargetMenu = {
            Enabled = false,
            Object = 'p_furnace01x',
        },

        Jobs = {'emeraldsaloon'}, 

        Coords = { x = 1448.466, y = 379.8521, z = 89.849, h = 9.961505 },

        ActionDistance = 1.2,
        PromptActionDisplay = 'Checkout Cooking Recipes',
        PromptFooterDisplay = 'Emerald Saloon',

        DrawText = 'Cooking Fireplace',
        DrawTextRenderDistance = 4,

        Header       = "Emerald Saloon Cooking Guide", 
        Description  = "Welcome to our Saloon Cooking Guide, below, our saloon simply recipes will be displayed to assist you so you can receive some experience and provide the best food for our customers based on their needs.",
        
        CraftingProp = {
            Enabled = false,

            Coords = {x = 0.0, y = 0.0, z = 0.0, yaw = 0.0 },
            
            Prop    = 'p_furnace01x',
            RenderDistance = 15,
        },

        AnimationType = 'WORLD_HUMAN_FIRE_TEND_KNEEL', -- false
        Categories = { 'food_saloon' },
    },

}

-----------------------------------------------------------
--[[ Webhooking (Only DevTools - Injection Cheat Logs) ]]--
-----------------------------------------------------------

Config.Webhooks = {
    
    ['DEVTOOLS_INJECTION_CHEAT'] = { -- Warnings and Logs about players who used or atleast tried to use devtools injection.
        Enabled = false, 
        Url = "", 
        Color = 10038562,
    },

}

-----------------------------------------------------------
--[[ Notification Functions  ]]--
-----------------------------------------------------------

-- @param source is always null when called from client.
-- @param messageType returns "success" or "error" depends when and where the message is sent.
function SendNotification(source, message, messageType)

    if not source then
        TriggerEvent('tpz_core:sendBottomTipNotification', message, 3000)
    else
        TriggerClientEvent('tpz_core:sendBottomTipNotification', source, message, 3000)
    end
  
end
