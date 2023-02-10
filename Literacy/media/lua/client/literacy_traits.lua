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
ProfessionFramework.addTrait('FastReader', {
    xp = {
        [Perks.Reading] = 1
    }
})

ProfessionFramework.addTrait('SlowReader', {
    xp = {
        [Perks.Reading] = -1
    }
})

ProfessionFramework.addTrait('Illiterate', {
    xp = {
        [Perks.Reading] = -5
    }
})

ProfessionFramework.addTrait('PoorReader', {
    name = 'UI_trait_PoorReader',
    description = 'UI_trait_PoorReaderDesc',
    cost = -2,
    exclude = { 'Illiterate', 'FastReader' }
})

ProfessionFramework.addTrait('VerySlowReader', {
    name = 'UI_trait_VerySlowReader',
    description = 'UI_trait_VerySlowReaderDesc',
    cost = -4,
    profession = true,
    exclude = { 'Illiterate', 'FastReader', 'SlowReader' }
})