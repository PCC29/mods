--[[LITERACY MOD
    Copyright (C) 2022 albion

    This program is free software: you can redistribute it and/or modify
    it under the terms of Version 3 of the GNU Affero General Public License as published
    by the Free Software Foundation.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

    For any questions, contact me through steam or on Discord - albion#0123
]]

local function startReadingLiteracyMag(item, player)
    local character = getSpecificPlayer(player)
    if luautils.haveToBeTransfered(character, item) then
        ISTimedActionQueue.add(ISInventoryTransferAction:new(character, item, item:getContainer(), character:getInventory()))
    end
	ISTimedActionQueue.add(ReadLiteracyMag:new(character, item, 69))
end

local function LiteracyMagMenu(player, context, items)
    for _,v in ipairs(items) do
        local item = v;
        if not instanceof(v, 'InventoryItem') then
            item = v.items[1];
        end

        local itemType = item:getType() or nil
        if itemType == 'LiteracyMag' and getSpecificPlayer(player):HasTrait('Illiterate') then
            context:insertOptionAfter(getText('ContextMenu_Read'), getText('ContextMenu_Read'),
			item, startReadingLiteracyMag, player)
			context:removeOptionByName(getText('ContextMenu_Read'))
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(LiteracyMagMenu)

local old_checkXPBoost = CharacterCreationProfession.checkXPBoost

function CharacterCreationProfession:checkXPBoost()
    old_checkXPBoost(self)

    self.listboxXpBoost:removeItem(PerkFactory.getPerkName(Perks.Reading))
    local readingLevel
    if self.listboxTraitSelected and self.listboxTraitSelected.items then
        for i,v in pairs(self.listboxTraitSelected.items) do
            if v.item:getXPBoostMap() then
                local table = transformIntoKahluaTable(v.item:getXPBoostMap())
                if table[Perks.Reading] then
                    readingLevel = table[Perks.Reading]:intValue()
                else
                    readingLevel = 0
                end
            end
        end
    end
    readingLevel = (readingLevel or 0) + 5
    self.listboxXpBoost:addItem(PerkFactory.getPerkName(Perks.Reading), { perk = Perks.Reading, level = readingLevel })
    self.listboxXpBoost:sort()
end

local old_drawXpBoostMap = CharacterCreationProfession.drawXpBoostMap

function CharacterCreationProfession:drawXpBoostMap(y, item, alt)
    if item.item.perk == Perks.Reading then
        local dy = (self.itemheight - self.fontHgt) / 2
        self:drawText(item.text, 16, y + dy, 0, 1, 0, 1, UIFont.Small);

        local textWid = getTextManager():MeasureStringX(UIFont.Small, item.text)
        local greenBlitsX = self.width - (68 + 10 * 4)
        local yy = y
        if 16 + textWid > greenBlitsX - 4 then
            yy = y + self.fontHgt
        end

        for i = 1,item.item.level do
            self:drawTexture(CharacterCreationProfession.instance.greenBlits, self.width - (68 + 10 * 4) + (i * 4), (yy) + dy + 4, 1, 1, 1, 1);
        end

        yy = yy + self.itemheight;

        self:drawRectBorder(0, (y), self:getWidth(), yy - y - 1, 0.5, self.borderColor.r, self.borderColor.g, self.borderColor.b);

        return yy;
    else
        return old_drawXpBoostMap(self, y, item, alt)
    end
end

local TraitModifiers = {0, 0.5, 1}
local old_updateTooltip = ISSkillProgressBar.updateTooltip

function ISSkillProgressBar:updateTooltip(lvlSelected)
    old_updateTooltip(self, lvlSelected)
    if self.perk == Perks.Reading then
        local readingSpeed = Literacy.calculateReadingSpeed(getPlayer())
        readingSpeed = readingSpeed * 100
        if readingSpeed % 10 ~= 0 then
            readingSpeed = math.floor(readingSpeed) + 1
        end
        self.message = self.message .. ' <LINE> ' .. getText('IGUI_XP_readingspeed', readingSpeed) .. '%'
    end
end