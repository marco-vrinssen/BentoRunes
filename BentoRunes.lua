local function ButtonOnClick(mouseButton, abilityID, equipmentSlot)
    C_Engraving.CastRune(abilityID)

    if mouseButton == "RightButton" then
        UseInventoryItem(equipmentSlot)

        for i = 1, STATICPOPUP_NUMDIALOGS do
            local popupFrame = _G["StaticPopup" .. i]

            if popupFrame.which == "REPLACE_ENCHANT" and popupFrame:IsVisible() then
                popupFrame.button1:Click()
                break
            end
        end
    end
end

local function UpdateEquippedRunes()
    local equippedRunes = {}
    local equippedFilterInitialllyEnabled = C_Engraving.IsEquippedFilterEnabled()
    C_Engraving.EnableEquippedFilter(true)

    local categories = C_Engraving.GetRuneCategories(true, true)
    for _, category in ipairs(categories) do
        local runes = C_Engraving.GetRunesForCategory(category, true)
        for _, rune in ipairs(runes) do
            equippedRunes[rune.skillLineAbilityID] = true
        end
    end
    C_Engraving.EnableEquippedFilter(equippedFilterInitialllyEnabled)
    return equippedRunes
end









-- Function to update rune buttons in the EngravingFrame
local function UpdateRuneButtons()
    -- Reference to the scroll frame and its buttons
    local scrollFrame = EngravingFrame.scrollFrame
    local buttons = scrollFrame.buttons
    -- Get the current scroll offset
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    -- Hide all header elements initially
    EngravingFrame_HideAllHeaders()
    -- Update and get currently equipped runes
    local equippedRunes = UpdateEquippedRunes()
    -- Initialize counters and variables
    local numRunes = 0
    local currOffset = 0
    local currentHeader = 1
    local currButton = 1
    local prevRowStart = 1
    -- Get rune categories, including empty and hidden ones
    local categories = C_Engraving.GetRuneCategories(true, true)
    local numHeaders = #categories

    -- Iterate over each category
    for _, category in ipairs(categories) do
        -- Handle offset for smooth scrolling
        if currOffset < offset then
            currOffset = currOffset + 1
        else
            local button = buttons[currButton]
            if button then
                button:Hide()
                local header = _G["EngravingFrameHeader"..currentHeader]
                if header then
                    -- Position the header and button accordingly
                    if currButton == 1 then
                        button:ClearAllPoints()
                        button:SetPoint("TOPLEFT", scrollFrame.scrollChild, "TOPLEFT", -2, -1)
                        prevRowStart = currButton
                    else
                        button:ClearAllPoints()
                        button:SetPoint("TOPLEFT", buttons[prevRowStart], "BOTTOMLEFT", 0, -2)
                        prevRowStart = currButton
                    end
                    -- Setup header properties and show it

                    local newTexture = header:CreateTexture(nil, "BACKGROUND")
                    newTexture:SetAllPoints()
                    newTexture:SetColorTexture(0, 0, 0, 0.5) 


                    header:SetPoint("BOTTOMLEFT", button, 0 , 0)
                    header:SetWidth(38)
                    header:Show()
                    header:SetParent(button:GetParent())
                    header.leftEdge:SetWidth(14)
                    header.leftEdge:SetHeight(32)
                    header.leftEdge:SetPoint("LEFT", header.middle, "RIGHT", -18, 5)
                    header.name:ClearAllPoints()
                    header.name:SetPoint("LEFT", header.leftEdge, "RIGHT", -10, 1)
                    header.middle:Hide()
                    header.middle:SetHeight(32)
                    header.rightEdge:ClearAllPoints()
                    header.rightEdge:SetPoint("LEFT", header.leftEdge, "RIGHT", -5, 0)
                    header.rightEdge:SetWidth(15)
                    header.rightEdge:SetHeight(32)
                    
                    currentHeader = currentHeader + 1
                    header.filter = category
                    header.name:Hide()
                    header.expandedIcon:Hide()
                    header.collapsedIcon:Hide()
                    button:SetHeight(32)
                    button:SetWidth(26)
                    currButton = currButton + 1
                end
            end
        end

        -- Get runes for the current category
        local runes = C_Engraving.GetRunesForCategory(category, true)
        numRunes = numRunes + #runes
        for runeIndex, rune in ipairs(runes) do
            if currOffset < offset then
                currOffset = currOffset + 1
            else
                local button = buttons[currButton]
                if button then
                    -- Setup button properties and actions
                    button:SetScript("OnClick", function(_, mouseButton)
                        ButtonOnClick(mouseButton, rune.skillLineAbilityID, rune.equipmentSlot)
                    end)
                    button:SetHeight(32)
                    button:SetWidth(32)
                    button.name:Hide()
                    button.typeName:Hide()
                    button.icon:SetTexture(rune.iconTexture)
                    button.icon:SetSize(30, 30)
                    button.tooltipName = rune.name
                    button.name:SetText(rune.name)
                    button.skillLineAbilityID = rune.skillLineAbilityID
                    button.disabledBG:Hide()
                    button.selectedTex:Hide()
                    if equippedRunes[rune.skillLineAbilityID] then
                        button.checkedTexture:Show()
                    else
                        button.checkedTexture:Hide()
                    end

                    button:ClearAllPoints()
                    button:SetPoint("LEFT", buttons[currButton - 1], "RIGHT")
                    button:Show()
                    currButton = currButton + 1
                end
            end
        end
    end
    
    -- Hide any remaining buttons that are not needed
    while currButton < #buttons do
        buttons[currButton]:Hide()
        currButton = currButton + 1
    end

    -- Show or hide the empty text based on whether there are any runes or headers
    if numHeaders == 0 and numRunes == 0 then
        scrollFrame.emptyText:Show()
    else
        scrollFrame.emptyText:Hide()
    end

    -- Update the filter dropdown text
    local exclusiveFilter = C_Engraving.GetExclusiveCategoryFilter()
    if exclusiveFilter then
        UIDropDownMenu_SetText(EngravingFrameFilterDropDown, C_Item.GetItemInventorySlotInfo(exclusiveFilter))
    else
        if C_Engraving.IsEquippedFilterEnabled() then
            UIDropDownMenu_SetText(EngravingFrameFilterDropDown, EQUIPPED_RUNES)
        else
            UIDropDownMenu_SetText(EngravingFrameFilterDropDown, ALL_RUNES)
        end
    end

    -- Update the collected label
    EngravingFrame_UpdateCollectedLabel(EngravingFrame)
end






-- Function to add more rune buttons if needed
local function AddRuneButtons()
    local scrollFrame = EngravingFrame.scrollFrame
    local buttons = scrollFrame.buttons
    local parentName = scrollFrame:GetName()
    local buttonName = parentName and (parentName .. "Button") or nil
    for i = #buttons, 80 do
        local button = CreateFrame("BUTTON", buttonName and (buttonName .. 1) or nil, scrollFrame.scrollChild, "RuneSpellButtonTemplate")
        button.disabledBG:Hide()
        button.selectedTex:Hide()
        button:Hide()
        tinsert(buttons, button)
    end
end







-- Function to update the texture of rune buttons
local function UpdateRuneButtonTexture()
    local buttons = EngravingFrame.scrollFrame.buttons
    for _, button in ipairs(buttons) do
        button.checkedTexture = button:CreateTexture(nil, "OVERLAY")
        button.checkedTexture:SetAllPoints(button)
        button.checkedTexture:SetTexture("Interface\\Buttons\\CheckButtonHilight")
        button.checkedTexture:SetBlendMode("ADD")
        button.checkedTexture:Hide()
    end
end








-- Function to update the rune scroll frame layout
local function UpdateEngravingFrame()
    EngravingFrameSideInset:Hide()
    EngravingFrameScrollFrameScrollBar.doNotHide = false
    EngravingFrameScrollFrameScrollBar.Show = function() end
    EngravingFrameScrollFrameScrollBar:Hide()
    -- EngravingFrameSideInsetBackground:SetWidth(190)
    -- EngravingFrameScrollFrameScrollChild:SetWidth(190)
    -- EngravingFrameScrollFrame:ClearAllPoints()
    -- EngravingFrameScrollFrame:SetPoint("TOPLEFT", EngravingFrameSideInset, "TOPLEFT", 5, -3)
    -- EngravingFrameScrollFrame:SetWidth(190)
    -- EngravingFrameCollectedFrame:ClearAllPoints()
    -- EngravingFrameCollectedFrame:SetPoint("TOPLEFT", EngravingFrameScrollFrame, "BOTTOMLEFT", 0, 10)
end







local function RuneEventHandler(self, event, addonName)
	if event == "ADDON_LOADED" and addonName == "Blizzard_EngravingUI" then
		UpdateEngravingFrame()
		AddRuneButtons()
		UpdateRuneButtonTexture()    
		hooksecurefunc("EngravingFrame_UpdateRuneList", UpdateRuneButtons)
	elseif event == "RUNE_UPDATED" and EngravingFrame then
			UpdateRuneButtons()
	end
end

local RuneEventFrame = CreateFrame("Frame")
RuneEventFrame:RegisterEvent("ADDON_LOADED")
RuneEventFrame:RegisterEvent("RUNE_UPDATED")
RuneEventFrame:SetScript("OnEvent", RuneEventHandler)