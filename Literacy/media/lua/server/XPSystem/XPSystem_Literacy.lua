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

local skills = {'Reloading', 'Aiming', 'Strength', 'Fitness', 'Nimble', 'Sprinting', 'Sneak', 'Lightfoot', 'Maintenance', 'Axe', 'SmallBlunt', 'Blunt', 'SmallBlade', 'LongBlade', 'Spear'}

for _,skill in ipairs(skills) do
    SkillBook[skill] = {}
    SkillBook[skill].perk = Perks[skill]
    SkillBook[skill].maxMultiplier1 = 3
    SkillBook[skill].maxMultiplier2 = 5
    SkillBook[skill].maxMultiplier3 = 8
    SkillBook[skill].maxMultiplier4 = 12
    SkillBook[skill].maxMultiplier5 = 16
end

skills = nil