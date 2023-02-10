if isServer() then return end

local OriginalSetVisible = CharacterCreationProfession.setVisible;

function CharacterCreationProfession:setVisible(visible, joypadData)
    OriginalSetVisible(self, visible, joypadData)

    if not visible
    or ReviveMP.isProfessionCreated then
        return
    end

    local prof = ProfessionFactory.addProfession(ReviveMP.occupationId, ReviveMP.occupationName, "profession_revive", 0)
    prof:addXPBoost(Perks.Strength, -5)
    prof:addXPBoost(Perks.Fitness, -5)

    TraitFactory.addTrait(ReviveMP.occupationId, ReviveMP.occupationName, 0, "Return back to life.", true, false)
    local traits = TraitFactory.getTraits()

    for i=0, traits:size() - 1 do
        TraitFactory.setMutualExclusive(ReviveMP.occupationId, traits:get(i):getType())
    end

    prof:addFreeTrait(ReviveMP.occupationId)

    self.listboxProf:insertItem(0, 0, prof)
    self:onSelectProf(prof)

    ReviveMP.isProfessionCreated = true
end

function CharacterCreationProfession:resetBuild()
    local index = 1;

    while self.listboxProf.items[index].item:getType() ~= "unemployed" do
        index = index + 1;
    end

    self.listboxProf.selected = index;
    self:onSelectProf(self.listboxProf.items[self.listboxProf.selected].item);

    while #self.listboxTraitSelected.items > 0 do
        self.listboxTraitSelected.selected = 1;
        self:onOptionMouseDown(self.removeTraitBtn);
    end
end
