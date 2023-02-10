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

require 'TimedActions/ISReadABook'

ReadLiteracyMag = ISReadABook:derive('ReadLiteracyMag')

function ReadLiteracyMag:update()
    local pagesRead = math.floor(self.item:getNumberOfPages() * self:getJobDelta())
    if pagesRead >= self.item:getNumberOfPages() then
        self.character:getTraits():remove('Illiterate')
        if SandboxVars.Literacy.IlliteratePenalty == 2 then
            self.character:getTraits():add('SlowReader')
            self.character:getTraits():add('PoorReader')
        elseif SandboxVars.Literacy.IlliteratePenalty == 3 then
            self.character:getTraits():add('VerySlowReader')
        end
        if ISCharacterInfoWindow.instance then
            ISCharacterInfoWindow.instance.charScreen:loadTraits()
        end
    end
    ISReadABook.update(self)
end