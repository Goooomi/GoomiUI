-- Core.lua - Main addon framework

-- Create the main addon namespace
GoomiUI = {}
GoomiUI.modules = {} -- Store all registered modules
GoomiUI.moduleList = {} -- Ordered list of module names

-- Initialize the database (will be loaded from SavedVariables after ADDON_LOADED)
local function InitializeDB()
    if not GoomiUIDB then
        GoomiUIDB = {}
    end
    if not GoomiUIDB.moduleStates then
        GoomiUIDB.moduleStates = {}
    end
end

-- Call initialization immediately to ensure the table exists
InitializeDB()

-- Register a new module with Goomi UI
-- Modules call this function to add themselves to the framework
function GoomiUI:RegisterModule(name, moduleTable)
    if self.modules[name] then
        print("GoomiUI: Module '" .. name .. "' is already registered!")
        return
    end
    
    -- Store the module
    self.modules[name] = moduleTable
    table.insert(self.moduleList, name)
    
    -- Default to enabled if not set
    if GoomiUIDB.moduleStates[name] == nil then
        GoomiUIDB.moduleStates[name] = true
    end
    
    -- If module is enabled and has an OnLoad function, call it
    if GoomiUIDB.moduleStates[name] and moduleTable.OnLoad then
        moduleTable:OnLoad()
    end
    
    print("GoomiUI: Registered module '" .. name .. "'")
end

-- Check if a module is enabled
function GoomiUI:IsModuleEnabled(name)
    return GoomiUIDB.moduleStates[name] == true
end

-- Enable or disable a module
function GoomiUI:SetModuleEnabled(name, enabled)
    GoomiUIDB.moduleStates[name] = enabled
    
    local module = self.modules[name]
    if not module then return end
    
    if enabled then
        if module.OnEnable then
            module:OnEnable()
        end
        print("GoomiUI: Enabled '" .. name .. "' (will load on next reload)")
    else
        if module.OnDisable then
            module:OnDisable()
        end
        print("GoomiUI: Disabled '" .. name .. "' (will take effect on next reload)")
    end
end

-- Slash command handler
SLASH_GOOMI1 = "/goomi"
SLASH_GOOMI2 = "/goom"
SLASH_GOOMI3 = "/gui"
SlashCmdList["GOOMI"] = function(msg)
    GoomiUI:OpenSettings()
end

-- Event frame for addon initialization
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "GoomiUI" then
        -- Re-initialize DB to make sure SavedVariables loaded properly
        InitializeDB()
        print("GoomiUI loaded! Type /goomi to open settings.")
    end
end)