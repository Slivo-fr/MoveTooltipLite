MoveTooltipLite = LibStub("AceAddon-3.0"):NewAddon("MoveTooltipLite", "AceConsole-3.0")

MoveTooltipLite.dragFrame = CreateFrame("Frame", 'dragFrame', UIParent)

-- Events
MoveTooltipLite.dragFrame:RegisterEvent("PLAYER_LOGIN")
MoveTooltipLite.dragFrame:SetScript(
    "OnEvent",
    function(self, event, ...)
        if (event == "PLAYER_LOGIN") then
            MoveTooltipLite:init()
            self:UnregisterEvent("PLAYER_LOGIN")
        end
    end
)

-- Right click event to lock
MoveTooltipLite.dragFrame:SetScript(
    "OnMouseDown",
    function(self, button)
        if (button == 'RightButton') then
            MoveTooltipLite:lock()
        end
    end
)

-- Show dragFrame and unlock position
function MoveTooltipLite:unlock()
    MoveTooltipLite.dragFrame:Show()
    MoveTooltipLite.db.char.lock = false
end

-- Show dragFrame and unlock position
function MoveTooltipLite:reset()
    MoveTooltipLite.db.char = {}
    MoveTooltipLite.dragFrame:ClearAllPoints()
    MoveTooltipLite.dragFrame:SetPoint("CENTER", UIParent, "CENTER")
    MoveTooltipLite:unlock()
end

-- Hide dragFrame save tooltip position
function MoveTooltipLite:lock()
    MoveTooltipLite.dragFrame:Hide()
    MoveTooltipLite.db.char.lock = true
    MoveTooltipLite:Print("Tooltip position saved, use /mtl unlock to set a new position")
end

-- Hook the tooltip position function
hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip)
    MoveTooltipLite:handleTooltip(tooltip)
end)

-- Set Tooltip position
function MoveTooltipLite:handleTooltip(tooltip)
    if (MoveTooltipLite.db.char.lock) then
        tooltip:ClearAllPoints()
        tooltip:SetPoint("BOTTOMRIGHT", UIParent, 'BOTTOMLEFT', MoveTooltipLite.db.char.x, MoveTooltipLite.db.char.y)
    end
end

-- addon initialization
function MoveTooltipLite:init()

    MoveTooltipLite.db = LibStub:GetLibrary("AceDB-3.0"):New("MoveTooltipLiteDB", {
        char = {
            lock = false
        },
    })

    MoveTooltipLite:createDragFrame()
    MoveTooltipLite:configureDragAndDrop()
end

-- Create the drag frame
function MoveTooltipLite:createDragFrame()
    MoveTooltipLite.dragFrame:SetWidth(175)
    MoveTooltipLite.dragFrame:SetHeight(100)

    if (MoveTooltipLite.db.char.x ~= nil and MoveTooltipLite.db.char.y ~= nil ) then
        MoveTooltipLite.dragFrame:SetPoint("BOTTOMRIGHT", UIParent, 'BOTTOMLEFT', MoveTooltipLite.db.char.x, MoveTooltipLite.db.char.y)
    else
        MoveTooltipLite.dragFrame:SetPoint("CENTER", UIParent, "CENTER")
    end

    MoveTooltipLite.dragFrame.texture = MoveTooltipLite.dragFrame:CreateTexture(nil, "BACKGROUND")
    MoveTooltipLite.dragFrame.texture:SetColorTexture(0,0,0,0.5)
    MoveTooltipLite.dragFrame.texture:SetAllPoints()

    MoveTooltipLite.dragFrame.text = MoveTooltipLite.dragFrame:CreateFontString(nil, "ARTWORK")
    MoveTooltipLite.dragFrame.text:SetFont("Fonts\\ARIALN.ttf", 12)
    MoveTooltipLite.dragFrame.text:SetShadowColor(0,0,0,0.5)
    MoveTooltipLite.dragFrame.text:SetShadowOffset(1,-1)
    MoveTooltipLite.dragFrame.text:SetPoint("CENTER")
    MoveTooltipLite.dragFrame.text:SetText(
        'Move this frame to move tooltip\n' ..
        'Right click to lock\n\n' ..
        'Anchor is bottom right corner'
    )
    MoveTooltipLite.dragFrame.text:SetTextColor(1,1,1,1)

    if (MoveTooltipLite.db.char.lock) then
        MoveTooltipLite.dragFrame:Hide()
    end
end

-- Configure drag and drop
function MoveTooltipLite:configureDragAndDrop()
    MoveTooltipLite.dragFrame:RegisterForDrag("LeftButton")
    MoveTooltipLite.dragFrame:SetClampedToScreen(true)
    MoveTooltipLite.dragFrame:EnableMouse(true)
    MoveTooltipLite.dragFrame:SetMovable(true)

    MoveTooltipLite.dragFrame:SetScript("OnDragStart", function() MoveTooltipLite.dragFrame:StartMoving() end)

    MoveTooltipLite.dragFrame:SetScript(
        "OnDragStop",
        function()
            MoveTooltipLite.dragFrame:StopMovingOrSizing()

            MoveTooltipLite.db.char.point = 'TOPLEFT'
            MoveTooltipLite.db.char.y = MoveTooltipLite.dragFrame:GetBottom()
            MoveTooltipLite.db.char.x = MoveTooltipLite.dragFrame:GetRight()
        end
    )
end

-- Chat commands
local options = {
    name = 'MoveTooltipLite',
    type = 'group',
    args = {
        unlock = {
            type = 'execute',
            name = "Unlock",
            desc = "Unlocks tooltip position",
            func = function() MoveTooltipLite:unlock() end
        },
        reset = {
            type = 'execute',
            name = "Reset",
            desc = "Resets tooltip position",
            func = function() MoveTooltipLite:reset() end
        },
    }
}
LibStub("AceConfig-3.0"):RegisterOptionsTable("MoveTooltipLite", options, {"movetooltiplite", "mtl"})
