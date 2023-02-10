if isServer() then return end

local debug = true
ReviveMP    = {
    isDataReceived      = false,
    isRevived           = false,
    isProfessionCreated = false,
    onDeathEventTable   = {},
    onReviveEventTable  = {},
    occupationId        = "revivemp",
    occupationName      = "Revive"
}

local function debugPrint(str)
    if debug then print(str) end
end

function ReviveMP.reviveDataRequester(_)
    if not ReviveMP.isDataReceived then
        debugPrint("ReviveMP - reviveDataRequester - Requesting revive data.")
        sendClientCommand("ReviveMPClient", "OnCreatePlayer", nil)
    end
end

function ReviveMP.isReviving(player)
    return player:getDescriptor():getProfession() == ReviveMP.occupationId
end

function ReviveMP.bootPlayer(player)
    player:Say("No recoverable data has been found!")
    player:getBodyDamage():setInfectionLevel(0)
    player:setHealth(0)
end

function ReviveMP.GetPlayerData(player)
    player = player or getPlayer()

    local playerData = {}
    local perks      = PerkFactory.PerkList
    local traits     = player:getTraits()

    -- Occupation
    playerData.occupation = player:getDescriptor():getProfession()

    -- Weight
    playerData.weight = player:getNutrition():getWeight()

    -- Perk XP
    -- Boosts
    playerData.perkXP = {}
    playerData.boosts = {}

    local xp = player:getXp()

    for i=0, perks:size() - 1 do
        local perk      = perks:get(i)
        local perkName  = perk:getName()

        local perkXP = xp:getXP(perk:getType())

        if perkXP > 0 then
            playerData.perkXP[perkName] = perkXP
        end

        local perkBoost = xp:getPerkBoost(perk)

        if perkBoost > 0 then
            playerData.boosts[perkName] = perkBoost
        end
    end

    -- Recipes
    playerData.recipes = {}

    local recipes = player:getKnownRecipes()

    for i=0, recipes:size() - 1 do
        table.insert(playerData.recipes, recipes:get(i))
    end

    -- Traits
    playerData.traits = {}

    for i=0, traits:size() - 1 do
        table.insert(playerData.traits, traits:get(i))
    end

    return playerData
end

function ReviveMP.LoadPlayerData(player, reviveData)
    player = player or getPlayer()

    debugPrint("ReviveMP - LoadPlayerData - Loading occupation.")
    local professionName = reviveData.occupation
    player:getDescriptor():setProfession(professionName)

    if SandboxVars.ReviveMP.CharacterWeight then
        debugPrint("ReviveMP - LoadPlayerData - Loading weight.")
        player:getNutrition():setWeight(reviveData.weight)
    end

    if SandboxVars.ReviveMP.CharacterXP then
        debugPrint("ReviveMP - LoadPlayerData - Loading perk XPs.")
        local playerXP = player:getXp()
        for perkName, xp in pairs(reviveData.perkXP) do
            local perk = PerkFactory.getPerkFromName(perkName)
            playerXP:AddXP(perk, xp - playerXP:getXP(perk), false, false, true)
        end
    end

    if SandboxVars.ReviveMP.CharacterRecipes then
        debugPrint("ReviveMP - LoadPlayerData - Loading recipes.")
        local recipes = player:getKnownRecipes()

        for i, recipe in ipairs(reviveData.recipes) do
            recipes:add(recipe)
        end
    end

    if SandboxVars.ReviveMP.CharacterTraits then
        debugPrint("ReviveMP - LoadPlayerData - Loading traits.")
        player:getTraits():clear()

        for i, trait in ipairs(reviveData.traits) do
            player:getTraits():add(trait)
        end
    end

    ReviveMP.isRevived = true

    if SandboxVars.ReviveMP.CharacterBoosts then
        local prof = ProfessionFactory.getProfession(professionName)

        if prof == nil then
            debugPrint("ReviveMP - LoadPlayerData - Failed at setting boost levels.")
            return false
        end

        debugPrint("ReviveMP - LoadPlayerData - Loading boost levels.")
        for perkName,boostLevel in pairs(reviveData.boosts) do
            local perk = PerkFactory.getPerkFromName(perkName)
            prof:addXPBoost(perk, boostLevel)
        end

        player:getDescriptor():setProfessionSkills(prof)
    end

    return true
end
