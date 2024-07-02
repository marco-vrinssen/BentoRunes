local function RuneButtonClick(mouseButton, abilityID, equipmentSlot)
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




local function EquippedRunesUpdate()
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




local function RuneButtonUpdate()
    local scrollFrame = EngravingFrame.scrollFrame
    local buttons = scrollFrame.buttons
    EngravingFrame_HideAllHeaders()
    local equippedRunes = EquippedRunesUpdate()
    local currentButton = 1
    local lastButton = nil
    local firstButtonOfCategory = nil
    local lastCategory = nil
    local categories = C_Engraving.GetRuneCategories(true, true)

    local buttonSize = 32
    local scrollChildPadding = 4
    local buttonPadding = 4

    for _, category in ipairs(categories) do
        local runes = C_Engraving.GetRunesForCategory(category, true)
        for _, rune in ipairs(runes) do
            local button = buttons[currentButton]
            if button then
                button:SetScript("OnClick", function(_, mouseButton)
                    RuneButtonClick(mouseButton, rune.skillLineAbilityID, rune.equipmentSlot)
                end)
                button:SetHeight(buttonSize)
                button:SetWidth(buttonSize)

                for _, button in ipairs(buttons) do
                    button.name:Hide()
                    button.typeName:Hide()
                end

                button.icon:SetTexture(rune.iconTexture)
                button.icon:SetSize(button:GetWidth()+2, button:GetHeight()+2)
                button.icon:ClearAllPoints()
                button.icon:SetPoint("CENTER", button, "CENTER", 0, 0)
                button.tooltipName = rune.name
                button.skillLineAbilityID = rune.skillLineAbilityID
                button.disabledBG:Hide()
                button.selectedTex:Hide()
                if equippedRunes[rune.skillLineAbilityID] then
                    button.checkedTexture:Show()
                else
                    button.checkedTexture:Hide()
                end
                button:ClearAllPoints()
                if lastButton then
                    if lastCategory ~= category then
                        button:SetPoint("TOPLEFT", firstButtonOfCategory, "BOTTOMLEFT", 0, -buttonPadding)
                        firstButtonOfCategory = button
                    else
                        button:SetPoint("LEFT", lastButton, "RIGHT", buttonPadding, 0)
                    end
                else
                    button:SetPoint("TOPLEFT", scrollFrame.scrollChild, "TOPLEFT", scrollChildPadding, -scrollChildPadding)
                    firstButtonOfCategory = button
                end
                button:Show()
                lastButton = button
                lastCategory = category
                currentButton = currentButton + 1
            end
        end
    end
end




local function RuneButtonAdd()
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




local function RuneTextureUpdate()
    local buttons = EngravingFrame.scrollFrame.buttons
    for _, button in ipairs(buttons) do
        button.checkedTexture = button:CreateTexture(nil, "OVERLAY")
        button.checkedTexture:SetAllPoints(button)
        button.checkedTexture:SetTexture("Interface\\Buttons\\CheckButtonHilight")
        button.checkedTexture:SetBlendMode("ADD")
        button.checkedTexture:Hide()
    end
end




local function EngravingFrameUpdate()
    EngravingFrame:ClearAllPoints()
    EngravingFrame:SetWidth(240)
    EngravingFrame:SetPoint("TOPLEFT", CharacterHandsSlot, "TOPRIGHT", 24, 0)
    EngravingFrame:SetPoint("BOTTOMLEFT", CharacterFrameTab5, "BOTTOMRIGHT", 24, 0)
    EngravingFrameScrollFrame:SetAllPoints("EngravingFrame")
    EngravingFrameScrollFrameScrollChild:SetAllPoints("EngravingFrame")

    EngravingFrame.Border:Hide()
    EngravingFrameSearchBox:Hide()
    EngravingFrameFilterDropDown:Hide()
    EngravingFrameCollectedFrame:Hide()
    EngravingFrameSideInset:Hide()

    EngravingFrameScrollFrameScrollBar.doNotHide = false
    EngravingFrameScrollFrameScrollBar.Show = function() end
    EngravingFrameScrollFrameScrollBar:Hide()
end




local function RuneEventHandler(self, event, addonName)
	if event == "ADDON_LOADED" and addonName == "Blizzard_EngravingUI" then
		EngravingFrameUpdate()
		RuneButtonAdd()
		RuneTextureUpdate()    
		hooksecurefunc("EngravingFrame_UpdateRuneList", RuneButtonUpdate)
	elseif event == "RUNE_UPDATED" and EngravingFrame then
        RuneButtonUpdate()
	end
end

local RuneEvents = CreateFrame("Frame")
RuneEvents:RegisterEvent("ADDON_LOADED")
RuneEvents:RegisterEvent("RUNE_UPDATED")
RuneEvents:SetScript("OnEvent", RuneEventHandler)