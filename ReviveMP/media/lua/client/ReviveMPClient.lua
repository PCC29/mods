if isServer() then return end

local commandModule = { ReviveMPServer = {} }
local json  = require("json")
local debug = true

local function debugPrint(str)
    if debug then print(str) end
end

function commandModule.ReviveMPServer.ReviveData(args)
    if ReviveMP.isDataReceived then
        Events.OnTick.Remove(ReviveMP.reviveDataRequester)
        return
    end

    ReviveMP.isDataReceived = true
    debugPrint("ReviveMPClient - ReviveData - Received data.")

    local player = getPlayer()

    if args ~= nil then
        if args.reviveData ~= nil then
            debugPrint("ReviveMPClient - ReviveData - reviveData JSON: "..args.reviveData)
            local success, reviveData = pcall(json.parse, args.reviveData)

            if not success then
                debugPrint("ReviveMPClient - ReviveData - Couldn't parse revive data JSON.")
                return
            end

            ReviveMP.LoadPlayerData(player, reviveData)
            player:Say("You have been revived.")

            -- Call registered OnRevive event callbacks
            for addonName,callback in pairs(ReviveMP.onReviveEventTable) do
                debugPrint("ReviveMPClient - ReviveData - Calling OnRevive event callback of addon "..addonName..".")
                callback(player, reviveData.addonData[addonName])
            end
        else
            debugPrint("ReviveMPClient - ReviveData - args.reviveData is null.")
            ReviveMP.bootPlayer(player)
        end
    else
        debugPrint("ReviveMPClient - ReviveData - args is null.")
        ReviveMP.bootPlayer(player)
    end
end

Events.OnServerCommand.Add(function(module, command, args)
    debugPrint("ReviveMPClient - received command from server. (Module: "..module.." | Command: "..command..")")

    if  commandModule[module]
    and commandModule[module][command] then
        commandModule[module][command](args)
    end
end)
