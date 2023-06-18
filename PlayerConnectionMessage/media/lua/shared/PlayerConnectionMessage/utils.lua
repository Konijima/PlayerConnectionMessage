local PlayerConnectionMessage = {}

---@param username string
function PlayerConnectionMessage.doConnect(username, accessLevel)
	local isHidden = SandboxVars.PlayerConnectionMessage.hideAdmin and accessLevel == "Admin" or
					 SandboxVars.PlayerConnectionMessage.hideModerator and accessLevel == "Moderator" or
					 SandboxVars.PlayerConnectionMessage.hideStaff and accessLevel ~= "None" and accessLevel ~= "Admin" and accessLevel ~= "Moderator"

	if getPlayer():getAccessLevel() ~= "None" or not isHidden then
		local color = SandboxVars.PlayerConnectionMessage.connectedMessageColorRed .. "," .. SandboxVars.PlayerConnectionMessage.connectedMessageColorGreen .. "," .. SandboxVars.PlayerConnectionMessage.connectedMessageColorBlue
		PlayerConnectionMessage.addLineToChat(getText("IGUI_PlayerConnectionMessage_Connected", username), "<RGB:" .. color .. ">")
	end
end

---@param username string
---@param killer string
function PlayerConnectionMessage.doDeath(username, accessLevel, killer)
	local isHidden = SandboxVars.PlayerConnectionMessage.hideAdmin and accessLevel == "Admin" or
					 SandboxVars.PlayerConnectionMessage.hideModerator and accessLevel == "Moderator" or
					 SandboxVars.PlayerConnectionMessage.hideStaff and accessLevel ~= "None" and accessLevel ~= "Admin" and accessLevel ~= "Moderator"

	if not SandboxVars.PlayerConnectionMessage.disableDeathMessage and (not isHidden or getPlayer():getAccessLevel() ~= "None") then
		local color = SandboxVars.PlayerConnectionMessage.disconnectedMessageColorRed .. "," .. SandboxVars.PlayerConnectionMessage.disconnectedMessageColorGreen .. "," .. SandboxVars.PlayerConnectionMessage.disconnectedMessageColorBlue
		if not SandboxVars.PlayerConnectionMessage.disableKillMessage and type(killer) == "string" then
			PlayerConnectionMessage.addLineToChat(getText("IGUI_PlayerConnectionMessage_Killed", username, killer), "<RGB:" .. color .. ">")
		else
			PlayerConnectionMessage.addLineToChat(getText("IGUI_PlayerConnectionMessage_Died", username), "<RGB:" .. color .. ">")
		end
	end
end

---@param username string
function PlayerConnectionMessage.doDisconnect(username, accessLevel)
	local isHidden = SandboxVars.PlayerConnectionMessage.hideAdmin and accessLevel == "Admin" or
					 SandboxVars.PlayerConnectionMessage.hideModerator and accessLevel == "Moderator" or
					 SandboxVars.PlayerConnectionMessage.hideStaff and accessLevel ~= "None" and accessLevel ~= "Admin" and accessLevel ~= "Moderator"

	if getPlayer():getAccessLevel() ~= "None" or not isHidden then
		local color = SandboxVars.PlayerConnectionMessage.disconnectedMessageColorRed .. "," .. SandboxVars.PlayerConnectionMessage.disconnectedMessageColorGreen .. "," .. SandboxVars.PlayerConnectionMessage.disconnectedMessageColorBlue
		PlayerConnectionMessage.addLineToChat(getText("IGUI_PlayerConnectionMessage_Disconnected", username), "<RGB:" .. color .. ">")
	end
end

---@param message string
---@param color any
---@param username any
---@param options any
function PlayerConnectionMessage.addLineToChat(message, color, username, options)
    if not isClient() then return end

    if type(options) ~= "table" then
        options = {
            showTime = false,
            serverAlert = false,
            showAuthor = false,
        };
    end

    if type(color) ~= "string" then
        color = "<RGB:1,1,1>";
    end

    if options.showTime then
		local dateStamp = Calendar.getInstance():getTime();
		local dateFormat = SimpleDateFormat.new("H:mm");
		if dateStamp and dateFormat then
			message = color .. "[" .. tostring(dateFormat:format(dateStamp) or "N/A") .. "]  " .. message;
		end
	else
		message = color .. message;
	end

    local msg = {
		getText = function(_)
			return message;
		end,
		getTextWithPrefix = function(_)
			return message;
		end,
		isServerAlert = function(_)
			return options.serverAlert;
		end,
		isShowAuthor = function(_)
			return options.showAuthor;
		end,
		getAuthor = function(_)
			return tostring(username);
		end,
		setShouldAttractZombies = function(_)
			return false
		end,
		setOverHeadSpeech = function(_)
			return false
		end,
	};

	if not ISChat.instance then return; end;
	if not ISChat.instance.chatText then return; end;
	ISChat.addLineInChat(msg, 0);
end

---@param username string
---@param role "Admin"|"Moderator"|"Overseer"|"GM"|"Observer"|"None"
---@param event "connected"|"disconnected"|"died"
function PlayerConnectionMessage.appendToLog(username, role, event, killer)
	local writer = getFileWriter('PlayerConnectionMessage.jsonl', true, true)
	if writer then
		if killer then
			writer:writeln('{"username": "' .. tostring(username) .. '", "role": "' .. tostring(role) .. '", "event": "' .. tostring(event) .. '", "killer": "' .. tostring(killer) .. '"}')
		else
			writer:writeln('{"username": "' .. tostring(username) .. '", "role": "' .. tostring(role) .. '", "event": "' .. tostring(event) .. '"}')
		end
		writer:close()
	end
end

return PlayerConnectionMessage
