local PlayerConnectionMessage = require('PlayerConnectionMessage/utils')

local function onServerCommand(module, command, args)
    if module ~= "PlayerConnectionMessage" then return end

    if command == "playerConnected" then
        PlayerConnectionMessage.doConnect(args.username, args.accessLevel)
    end

    if command == "playerDied" then
        PlayerConnectionMessage.doDeath(args.username, args.accessLevel, args.killer)
    end

    if command == "playerDisconnected" then
        PlayerConnectionMessage.doDisconnect(args.username, args.accessLevel)
    end
end
Events.OnServerCommand.Add(onServerCommand)

-- /reloadlua client/PlayerConnectionMessage/MainClient.lua