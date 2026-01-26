-- ui.lua - Settings window interface

local settingsFrame = nil
local currentModule = nil

-- Helper function to create a clean border
local function CreateBorder(parent, thickness, r, g, b, a)
    thickness = thickness or 1
    r, g, b, a = r or 0, g or 0, b or 0, a or 1
    
    local borders = {}
    
    -- Top
    borders.top = parent:CreateTexture(nil, "OVERLAY")
    borders.top:SetColorTexture(r, g, b, a)
    borders.top:SetHeight(thickness)
    borders.top:SetPoint("TOPLEFT")
    borders.top:SetPoint("TOPRIGHT")
    
    -- Bottom
    borders.bottom = parent:CreateTexture(nil, "OVERLAY")
    borders.bottom:SetColorTexture(r, g, b, a)
    borders.bottom:SetHeight(thickness)
    borders.bottom:SetPoint("BOTTOMLEFT")
    borders.bottom:SetPoint("BOTTOMRIGHT")
    
    -- Left
    borders.left = parent:CreateTexture(nil, "OVERLAY")
    borders.left:SetColorTexture(r, g, b, a)
    borders.left:SetWidth(thickness)
    borders.left:SetPoint("TOPLEFT")
    borders.left:SetPoint("BOTTOMLEFT")
    
    -- Right
    borders.right = parent:CreateTexture(nil, "OVERLAY")
    borders.right:SetColorTexture(r, g, b, a)
    borders.right:SetWidth(thickness)
    borders.right:SetPoint("TOPRIGHT")
    borders.right:SetPoint("BOTTOMRIGHT")
    
    return borders
end

-- Create the main settings window
function GoomiUI:CreateSettingsFrame()
    if settingsFrame then return settingsFrame end
    
    -- Main frame (900x650, centered on screen)
    local frame = CreateFrame("Frame", "GoomiUISettingsFrame", UIParent)
    frame:SetSize(900, 650)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("HIGH")
    frame:Hide()
    
    -- Background
    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetAllPoints()
    frame.bg:SetColorTexture(0.05, 0.05, 0.05, 0.95)
    
    -- Border
    CreateBorder(frame, 2, 0.2, 0.2, 0.2, 1)
    
    -- Title bar
    frame.titleBar = CreateFrame("Frame", nil, frame)
    frame.titleBar:SetHeight(40)
    frame.titleBar:SetPoint("TOPLEFT", 0, 0)
    frame.titleBar:SetPoint("TOPRIGHT", 0, 0)
    
    frame.titleBar.bg = frame.titleBar:CreateTexture(nil, "BACKGROUND")
    frame.titleBar.bg:SetAllPoints()
    frame.titleBar.bg:SetColorTexture(0.1, 0.1, 0.1, 1)
    
    -- Title bar bottom border
    frame.titleBar.border = frame.titleBar:CreateTexture(nil, "OVERLAY")
    frame.titleBar.border:SetColorTexture(0.3, 0.3, 0.3, 1)
    frame.titleBar.border:SetHeight(1)
    frame.titleBar.border:SetPoint("BOTTOMLEFT")
    frame.titleBar.border:SetPoint("BOTTOMRIGHT")
    
    -- Title text
    frame.title = frame.titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("LEFT", 15, 0)
    frame.title:SetText("GOOMI UI")
    frame.title:SetTextColor(1, 1, 1, 1)
    
    -- Close button
    frame.closeBtn = CreateFrame("Button", nil, frame.titleBar)
    frame.closeBtn:SetSize(30, 30)
    frame.closeBtn:SetPoint("RIGHT", -5, 0)
    
    frame.closeBtn.bg = frame.closeBtn:CreateTexture(nil, "BACKGROUND")
    frame.closeBtn.bg:SetAllPoints()
    frame.closeBtn.bg:SetColorTexture(0.15, 0.15, 0.15, 1)
    
    frame.closeBtn.text = frame.closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.closeBtn.text:SetPoint("CENTER")
    frame.closeBtn.text:SetText("×")
    frame.closeBtn.text:SetTextColor(0.8, 0.8, 0.8, 1)
    
    frame.closeBtn:SetScript("OnEnter", function(self)
        self.bg:SetColorTexture(0.7, 0.2, 0.2, 1)
        self.text:SetTextColor(1, 1, 1, 1)
    end)
    
    frame.closeBtn:SetScript("OnLeave", function(self)
        self.bg:SetColorTexture(0.15, 0.15, 0.15, 1)
        self.text:SetTextColor(0.8, 0.8, 0.8, 1)
    end)
    
    frame.closeBtn:SetScript("OnClick", function()
        frame:Hide()
    end)
    
    -- Left column: Module list (250px wide)
    local moduleList = CreateFrame("Frame", nil, frame)
    moduleList:SetWidth(250)
    moduleList:SetPoint("TOPLEFT", 0, -40)
    moduleList:SetPoint("BOTTOMLEFT", 0, 0)
    
    moduleList.bg = moduleList:CreateTexture(nil, "BACKGROUND")
    moduleList.bg:SetAllPoints()
    moduleList.bg:SetColorTexture(0.08, 0.08, 0.08, 1)
    
    -- Right border for module list
    moduleList.border = moduleList:CreateTexture(nil, "OVERLAY")
    moduleList.border:SetColorTexture(0.2, 0.2, 0.2, 1)
    moduleList.border:SetWidth(1)
    moduleList.border:SetPoint("TOPRIGHT")
    moduleList.border:SetPoint("BOTTOMRIGHT")
    
    -- Scroll frame for modules
    local moduleScrollFrame = CreateFrame("ScrollFrame", "GoomiUIModuleScroll", moduleList, "UIPanelScrollFrameTemplate")
    moduleScrollFrame:SetPoint("TOPLEFT", 5, -5)
    moduleScrollFrame:SetPoint("BOTTOMRIGHT", -25, 5)
    
    -- Hide the default scroll bar textures
    local scrollBar = _G["GoomiUIModuleScrollScrollBar"]
    scrollBar:GetThumbTexture():SetColorTexture(0.3, 0.3, 0.3, 0.8)
    scrollBar:GetThumbTexture():SetSize(8, 40)
    scrollBar:SetWidth(8)
    
    local moduleScrollChild = CreateFrame("Frame", nil, moduleScrollFrame)
    moduleScrollChild:SetSize(220, 1)
    moduleScrollFrame:SetScrollChild(moduleScrollChild)
    
    frame.moduleScrollChild = moduleScrollChild
    
    -- Right side: Settings panel
    local settingsPanel = CreateFrame("Frame", nil, frame)
    settingsPanel:SetPoint("TOPLEFT", moduleList, "TOPRIGHT", 0, 0)
    settingsPanel:SetPoint("BOTTOMRIGHT", 0, 0)
    
    settingsPanel.bg = settingsPanel:CreateTexture(nil, "BACKGROUND")
    settingsPanel.bg:SetAllPoints()
    settingsPanel.bg:SetColorTexture(0.06, 0.06, 0.06, 1)
    
    frame.settingsPanel = CreateFrame("Frame", nil, settingsPanel)
    frame.settingsPanel:SetPoint("TOPLEFT", 20, -20)
    frame.settingsPanel:SetPoint("BOTTOMRIGHT", -20, 20)
    
    settingsFrame = frame
    return frame
end

-- Populate the module list
function GoomiUI:UpdateModuleList()
    local frame = settingsFrame
    if not frame then return end
    
    local scrollChild = frame.moduleScrollChild
    
    -- Clear existing buttons
    for _, child in pairs({scrollChild:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end
    
    local yOffset = 0
    local buttonHeight = 36
    
    -- Always show "Goomi UI" first
    self:CreateModuleButton(scrollChild, "Goomi UI", true, yOffset)
    yOffset = yOffset + buttonHeight + 2
    
    -- Show enabled modules
    for _, name in ipairs(self.moduleList) do
        if self:IsModuleEnabled(name) then
            self:CreateModuleButton(scrollChild, name, true, yOffset)
            yOffset = yOffset + buttonHeight + 2
        end
    end
    
    -- Show disabled modules (greyed out)
    for _, name in ipairs(self.moduleList) do
        if not self:IsModuleEnabled(name) then
            self:CreateModuleButton(scrollChild, name, false, yOffset)
            yOffset = yOffset + buttonHeight + 2
        end
    end
    
    scrollChild:SetHeight(math.max(yOffset, 1))
end

-- Create a single module button
function GoomiUI:CreateModuleButton(parent, name, enabled, yOffset)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(220, 34)
    button:SetPoint("TOPLEFT", 0, -yOffset)
    
    -- Background
    button.bg = button:CreateTexture(nil, "BACKGROUND")
    button.bg:SetAllPoints()
    
    if currentModule == name then
        button.bg:SetColorTexture(0.2, 0.4, 0.6, 0.4)
    else
        button.bg:SetColorTexture(0.12, 0.12, 0.12, 0.5)
    end
    
    -- Hover highlight
    button.highlight = button:CreateTexture(nil, "HIGHLIGHT")
    button.highlight:SetAllPoints()
    button.highlight:SetColorTexture(0.15, 0.3, 0.45, 0.3)
    
    -- Left accent bar
    button.accent = button:CreateTexture(nil, "OVERLAY")
    button.accent:SetColorTexture(0.3, 0.5, 0.7, enabled and 1 or 0.3)
    button.accent:SetWidth(3)
    button.accent:SetPoint("TOPLEFT")
    button.accent:SetPoint("BOTTOMLEFT")
    
    -- Text
    button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.text:SetPoint("LEFT", 12, 0)
    button.text:SetText(name)
    button.text:SetJustifyH("LEFT")
    
    if enabled then
        button.text:SetTextColor(1, 1, 1, 1)
    else
        button.text:SetTextColor(0.5, 0.5, 0.5, 0.7)
    end
    
    button:SetScript("OnClick", function()
        GoomiUI:ShowModuleSettings(name)
        GoomiUI:UpdateModuleList()
    end)
end

-- Show settings for a specific module
function GoomiUI:ShowModuleSettings(moduleName)
    if not settingsFrame then return end
    
    currentModule = moduleName
    local panel = settingsFrame.settingsPanel
    
    -- Clear existing content - more aggressive clearing
    local children = {panel:GetChildren()}
    for i = 1, #children do
        children[i]:Hide()
        children[i]:ClearAllPoints()
        children[i]:SetParent(nil)
    end
    
    -- Also clear any lingering font strings
    local regions = {panel:GetRegions()}
    for i = 1, #regions do
        if regions[i]:GetObjectType() == "FontString" then
            regions[i]:Hide()
            regions[i]:SetText("")
        end
    end
    
    -- Show appropriate settings
    if moduleName == "Goomi UI" then
        self:ShowCoreSettings(panel)
    else
        local module = self.modules[moduleName]
        if module and module.CreateSettings then
            module:CreateSettings(panel)
        else
            local text = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            text:SetPoint("CENTER")
            text:SetText("No settings available for " .. moduleName)
            text:SetTextColor(0.6, 0.6, 0.6, 1)
        end
    end
end

-- Show core Goomi UI settings (module enable/disable)
function GoomiUI:ShowCoreSettings(panel)
    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    title:SetPoint("TOPLEFT", 0, 0)
    title:SetText("MODULE MANAGEMENT")
    title:SetTextColor(1, 1, 1, 1)
    
    -- Subtitle
    local subtitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    subtitle:SetPoint("TOPLEFT", 0, -30)
    subtitle:SetText("Enable or disable modules. Changes require /reload to take effect.")
    subtitle:SetTextColor(0.7, 0.7, 0.7, 1)
    
    local yOffset = 70
    
    for _, name in ipairs(self.moduleList) do
        -- Container for each module
        local container = CreateFrame("Frame", nil, panel)
        container:SetSize(600, 40)
        container:SetPoint("TOPLEFT", 0, -yOffset)
        
        container.bg = container:CreateTexture(nil, "BACKGROUND")
        container.bg:SetAllPoints()
        container.bg:SetColorTexture(0.1, 0.1, 0.1, 0.5)
        
        CreateBorder(container, 1, 0.2, 0.2, 0.2, 0.5)
        
        -- Checkbox
        local checkbox = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
        checkbox:SetPoint("LEFT", 10, 0)
        checkbox:SetSize(24, 24)
        checkbox:SetChecked(self:IsModuleEnabled(name))
        
        -- Module name
        checkbox.text:SetText(name)
        checkbox.text:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
        checkbox.text:SetTextColor(1, 1, 1, 1)
        checkbox.text:SetFontObject("GameFontNormal")
        
        checkbox:SetScript("OnClick", function(self)
            GoomiUI:SetModuleEnabled(name, self:GetChecked())
        end)
        
        yOffset = yOffset + 45
    end
    
    -- Reload notice at bottom
    local reloadNotice = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    reloadNotice:SetPoint("BOTTOMLEFT", 0, 0)
    reloadNotice:SetText("Type /reload or use the reload button to apply changes")
    reloadNotice:SetTextColor(1, 0.8, 0.2, 1)
end

-- Open the settings window
function GoomiUI:OpenSettings()
    if not settingsFrame then
        self:CreateSettingsFrame()
    end
    
    self:UpdateModuleList()
    self:ShowModuleSettings(currentModule or "Goomi UI")
    settingsFrame:Show()
end