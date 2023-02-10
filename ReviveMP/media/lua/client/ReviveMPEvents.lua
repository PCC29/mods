if isServer() then return end

local json  = require("json")
local debug = true

local function debugPrint(str)
    if debug then print(str) end
end

function ReviveMP.OnCreatePlayer(_, player)
    if ReviveMP.isReviving(player) then
        debugPrint("ReviveMPEvents - OnCreatePlayer - Player is respawning. Going to request revive data.")

        ReviveMP.isDataReceived = false
        Events.OnTick.Add(ReviveMP.reviveDataRequester)
    end
end

function ReviveMP.OnPlayerDeath(player)
    ReviveMP.isProfessionCreated = false

    if ReviveMP.isReviving(player) then
        debugPrint("ReviveMPEvents - OnPlayerDeath - Player died with revive profession. Skipping.")
        return
    end

    local playerData = ReviveMP.GetPlayerData(player)
    playerData.addonData = {}

    for addonName,callback in pairs(ReviveMP.onDeathEventTable) do
        debugPrint("ReviveMPClient - ReviveData - Calling OnDeath event callback of addon "..addonName..".")
        playerData.addonData[addonName] = callback(player)
    end

    debugPrint("ReviveMPEvents - OnPlayerDeath - Sending player data to server.")
    sendClientCommand("ReviveMPClient", "OnPlayerDeath", { reviveData = json.stringify(playerData, false) })
end

-- Events
Events.OnCreatePlayer.Add(ReviveMP.OnCreatePlayer)
Events.OnPlayerDeath.Add(ReviveMP.OnPlayerDeath)
