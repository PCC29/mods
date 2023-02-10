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
Literacy = {}

local TraitModifiers = {0, 0.5, 1}

local function setInitialLiteracy()
    local player = getPlayer()
    if player:getModData().LiteracySetUp == nil then

        player:level0(Perks.Reading)
        player:getXp():setPerkBoost(Perks.Reading, 0)

        if not player:HasTrait('Illiterate') then
            local desiredLevel = 5
            if player:HasTrait('FastReader') then
                desiredLevel = 6
            elseif player:HasTrait('SlowReader') then
                desiredLevel = 4
            end

            for i=1, desiredLevel do
                player:LevelPerk(Perks.Reading)
            end
            player:getXp():setXPToLevel(Perks.Reading, desiredLevel)
        end
        player:getModData().LiteracySetUp = 1
    end
end
Events.OnCreatePlayer.Add(setInitialLiteracy)

function Literacy.calculateReadingSpeed(character)
    local readingLevel = character:getPerkLevel(Perks.Reading)
    if character:HasTrait('FastReader') then
        readingLevel = readingLevel + TraitModifiers[SandboxVars.Literacy.TraitMultiplier]
    elseif character:HasTrait('SlowReader') then
        readingLevel = readingLevel - TraitModifiers[SandboxVars.Literacy.TraitMultiplier]
    elseif character:HasTrait('VerySlowReader') then
        readingLevel = readingLevel - (2 * TraitModifiers[SandboxVars.Literacy.TraitMultiplier])
    end
    readingLevel = math.max(1, readingLevel)
    readingLevel = readingLevel - 5
    readingLevel = readingLevel * 0.2
    if readingLevel > 0 then
        readingLevel = readingLevel * SandboxVars.Literacy.SpeedMultiplier
    end
    readingLevel = readingLevel + 1
    return readingLevel
end

-- ISReadABook overrides

local old_new = ISReadABook.new

function ISReadABook:new(character, item, time)
    local o = old_new(self, character, item, time)

    if o.maxMultiplier and character:HasTrait('PoorReader') then
        o.maxMultiplier = o.maxMultiplier * 0.75
    end

    if item:getNumberOfPages() > 0 then
        o.isStatBook = false
    else
        o.isStatBook = true
    end

    if character:isTimedActionInstant() then
        return o
    end

    time = o.maxTime
    -- undo vanilla trait multipliers
    if character:HasTrait("FastReader") then
        time = time / 0.7
    elseif character:HasTrait("SlowReader") then
        time = time / 1.3
    end

    local readingLevel = Literacy.calculateReadingSpeed(character)
    time = time / readingLevel
    time = time / SandboxVars.Literacy.OverallSpeedMultiplier
    
    o.maxTime = time
    return o
end

local old_update = ISReadABook.update

function ISReadABook:update()
    local pagesRead = math.floor(self.item:getNumberOfPages() * self:getJobDelta())
    if pagesRead > self.item:getAlreadyReadPages() then
        local difference = pagesRead - self.item:getAlreadyReadPages()
        self.character:getXp():AddXP(Perks.Reading, (difference * 12) * SandboxVars.Literacy.XPMultiplier)
    end
    old_update(self)
end

local old_perform = ISReadABook.perform

function ISReadABook:perform()
    if self.isStatBook then
        local modData = self.item:getModData()
        local XPReward = modData['XPReward'] or 32
        self.character:getXp():AddXP(Perks.Reading, (XPReward * 12) * SandboxVars.Literacy.XPMultiplier)
    end
    old_perform(self)
end

local old_isValid = ISReadABook.isValid

function ISReadABook:isValid()
    if ISReadABook.checkMultiplier then ISReadABook.checkMultiplier(self) end -- CDDA reading overwrites ISReadABook and removes this function u_u
    return old_isValid(self)
end

--[[local old_checkMultiplier = ISReadABook.checkMultiplier

function ISReadABook:checkMultiplier()
    if self.character:HasTrait('PoorReader') then
        local trainedStuff = SkillBook[self.item:getSkillTrained()]
        if trainedStuff then
            -- every 10% we add 10% of the max multiplier
            local readPercent = (self.item:getAlreadyReadPages() / self.item:getNumberOfPages()) * 100
            if readPercent > 100 then
                readPercent = 100
            end
            -- apply the multiplier to the skill
            local multiplier = (math.floor(readPercent/10) * (self.maxMultiplier/10))
            multiplier = multiplier * 0.75
            if multiplier > self.character:getXp():getMultiplier(trainedStuff.perk) then
                self.character:getXp():addXpMultiplier(trainedStuff.perk, multiplier, self.item:getLvlSkillTrained(), self.item:getMaxLevelTrained())
            end
        end
    else
        old_checkMultiplier(self)
    end
end]]