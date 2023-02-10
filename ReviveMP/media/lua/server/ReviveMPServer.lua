if isClient() then return end

local commandModule = { ReviveMPClient = {} }
local debug = true

local function debugPrint(str)
    if debug then print(str) end
end

local function GetSaveName(player)
    return "./"..player:getUsername().."_"..string.lower(string.gsub(player:getFullName(), " ", ""))..".json"
end

function commandModule.ReviveMPClient.OnPlayerDeath(player, args)
    if player ~= nil then
        if args ~= nil then
            debugPrint("ReviveMPServer - OnPlayerDeath - Username: "..player:getUsername())

            if args.reviveData ~= nil then
                debugPrint("ReviveMPServer - OnPlayerDeath - Writing player data to JSON.")

                local saveName = GetSaveName(player)
                local file     = getFileWriter(saveName, true, false)

                file:write(args.reviveData)
                file:close()
            else
                debugPrint("ReviveMPServer - OnPlayerDeath - args.reviveData is null.")
            end
        else
            debugPrint("ReviveMPServer - OnPlayerDeath - args is null.")
        end
    else
        debugPrint("ReviveMPServer - OnPlayerDeath - Player object is null.")
    end
end

function commandModule.ReviveMPClient.OnCreatePlayer(player, args)
    debugPrint("ReviveMPServer - OnCreatePlayer - Looking for player data. Username: "..player:getUsername()..".")

    if player ~= nil then
        local saveName = GetSaveName(player)
        local file     = getFileReader(saveName, false)

        if file == nil then
            debugPrint("ReviveMPServer - OnCreatePlayer - Couldn't find revive data.")
            sendServerCommand(player, "ReviveMPServer", "ReviveData", nil)
            return
        end

        local line = file:readLine()
        file:close()

        if line == nil
        or line == "" then
            debugPrint("ReviveMPServer - OnCreatePlayer - Revive data is empty.")
            sendServerCommand(player, "ReviveMPServer", "ReviveData", nil)
            return
        end

        debugPrint("ReviveMPServer - OnCreatePlayer - Successfully loaded revive data. Sending server command to client.")
        sendServerCommand(player, "ReviveMPServer", "ReviveData", { reviveData = line })
    else
        debugPrint("ReviveMPServer - OnCreatePlayer - Player object is null.")
        sendServerCommand(player, "ReviveMPServer", "ReviveData", nil)
    end
end

Events.OnClientCommand.Add(function(module, command, player, args)
    debugPrint("ReviveMPServer - received command from client. (Module: "..module.." | Command: "..command..")")

    if  commandModule[module]
    and commandModule[module][command] then
        commandModule[module][command](player, args)
    end
end)

debugPrint("ReviveMPServer - Loaded.")
