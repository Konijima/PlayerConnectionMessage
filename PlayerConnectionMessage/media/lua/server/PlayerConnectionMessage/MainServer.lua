if not isServer() then return end
local PlayerConnectionMessage = require('PlayerConnectionMessage/utils')

local cachedPlayers = {}
local cachedUsernames = ArrayList.new()
local cachedRoles = ArrayList.new()

local ticks = 0
local function OnTick(tick)
    if ticks < 20 then ticks = ticks + tick return end
    ticks = 0

    local players = getOnlinePlayers()
    
    --- Look for player connected
    for i = 0, players:size() - 1 do
        ---@type IsoPlayer
        local player = players:get(i)
        local username = player:getUsername()
        local accessLevel = player:getAccessLevel()
        
        if not cachedPlayers[username] and player and not player:isDead() then
            cachedPlayers[username] = player
            cachedUsernames:add(username)
            cachedRoles:add(accessLevel)

            sendServerCommand("PlayerConnectionMessage", "playerConnected", { username = username, accessLevel = accessLevel })
            PlayerConnectionMessage.appendToLog(username, accessLevel, "connected")
        end
    end

    --- Look for player death
    ---@param player IsoPlayer
    for username, player in pairs(cachedPlayers) do
        local accessLevel = player:getAccessLevel()
        if player and player:isDead() then
            local index = cachedUsernames:indexOf(username)
            cachedUsernames:remove(username)
            cachedRoles:remove(index)
            cachedPlayers[username] = nil

            local killer = player and player:getAttackedBy() and player:getAttackedBy():getUsername()
            sendServerCommand("PlayerConnectionMessage", "playerDied", { username = username, accessLevel = accessLevel, killer = killer })
            PlayerConnectionMessage.appendToLog(username, player:getAccessLevel(), "died", killer)
        end
    end

    --- Look for player disconnected
    for i = 0, cachedUsernames:size() - 1 do
        local username = cachedUsernames:get(i)
        if cachedPlayers[username] and not players:contains(cachedPlayers[username]) then
            local accessLevel = cachedRoles:get(i) or "None"
            cachedUsernames:remove(username)
            cachedRoles:remove(i)
            cachedPlayers[username] = nil

            sendServerCommand("PlayerConnectionMessage", "playerDisconnected", { username = username, accessLevel = accessLevel })
            PlayerConnectionMessage.appendToLog(username, accessLevel, "disconnected")
        end
    end
end
Events.OnTick.Add(OnTick)
