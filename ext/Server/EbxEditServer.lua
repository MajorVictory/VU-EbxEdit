class 'EbxEditServer'

function EbxEditServer:__init()
    print("EbxEditServer Loading...")

    -- change this to whitelist certain users who can WRITE values
	self.userCanWrite = {
		'MajorVictory87',
		--'MinorVictory',
		--'MinorFailure'
	}

	-- change this to whitelist certain users who can READ values
	self.userCanRead = {
		'*', -- allow everyone
	}

	self:RegisterEvents()
end

function EbxEditServer:RegisterEvents()
	NetEvents:Subscribe('EbxEdit:GetValue', self, self.onGetValue)
	NetEvents:Subscribe('EbxEdit:SetNumber', self, self.onSetNumber)
	NetEvents:Subscribe('EbxEdit:SetString', self, self.onSetString)
	NetEvents:Subscribe('EbxEdit:SetBool', self, self.onSetBool)
	--NetEvents:Subscribe('EbxEdit:SetNil', self, self.onSetNil) -- not ready
end

function EbxEditServer:CheckUser(player, action)

	local checkNames = self['userCan'..action]

	for name=0, #checkNames do
		if (player ~= nil and (player.name == checkNames[name] or checkNames[name] == '*')) then
			return true
		end
	end
    SharedUtils:Print("User tried to "..action.." something: "..tostring(player.name))
	NetEvents:SendToLocal('EbxEdit:ServerMessage', player, {["Message"] = "**You are not authorized to "..action.." values!**"})
	return false
end

function EbxEditServer:onGetValue(player, args)

	if (not self:CheckUser(player, 'Read')) then
		return
	end

	if (#args < 2) then
		NetEvents:SendToLocal('EbxEdit:ServerMessage', player, {
			["Message"] = "Usage: `vu-ebxedit.GetValue` <*ResourcePathOrGUID*|**String**> <*PropertyNamePath*|**string**>"
		})
		return
	end
	local resource, propertyPath, newValue, status

	resource, status = ebxEditUtils:GetWritableInstance(args[1])
	if (status ~= true) then
		NetEvents:SendToLocal('EbxEdit:ServerMessage', player, {
			["Message"] = "**Argument 1 `ResourcePathOrGUID` Not Found**: "..status
		})
		return
	end

	propertyPath = ebxEditUtils:GetValidPath(args[2])
	if (#propertyPath < 1) then
		NetEvents:SendToLocal('EbxEdit:ServerMessage', player, {
			["Message"] = "**Argument 2 `PropertyNamePath` Invalid**"
		})
		return
	end

	-- all validated, everything should be usable now
	local workingInstance, propertyName, valid = ebxEditUtils:GetWritableProperty(resource, propertyPath)

	if (not valid) then
		NetEvents:SendToLocal('EbxEdit:ServerMessage', player, {
			["Message"] = "**Argument 2 `PropertyNamePath` Invalid at segment**: "..propertyName
		})
		return
	end

	NetEvents:SendToLocal('EbxEdit:ServerMessage', player, {
		["Message"] = ebxEditUtils:dump(workingInstance[propertyName])
	})
end

function EbxEditServer:onSetNumber(player, args)
	self:serverSetValue(player, args, 'number')
end

function EbxEditServer:onSetString(player, args)
	self:serverSetValue(player, args, 'string')
end

function EbxEditServer:onSetBool(player, args)
	self:serverSetValue(player, args, 'boolean')
end

function EbxEditServer:onSetNil(player, args)
	self:serverSetValue(player, args, 'nil')
end

function EbxEditServer:serverSetValue(player, args, valueType)

	local command = ''
	if (valueType == 'number') then
		command = 'vu-ebxedit.SetNumber'

	elseif (valueType == 'string') then
		command = 'vu-ebxedit.SetString'

	elseif (valueType == 'boolean') then
		command = 'vu-ebxedit.SetBool'

	elseif (valueType == 'nil') then
		command = 'vu-ebxedit.SetNil'
	end

	NetEvents:SendToLocal('EbxEdit:ServerMessage', player, {["Message"] = "*"..command.."* ["..ebxEditUtils:getModuleState().."]"})
	SharedUtils:Print("*"..command.."* ["..ebxEditUtils:getModuleState().."]")

	if (not self:CheckUser(player, 'Write')) then
		return
	end

	if ((valueType == 'nil' and #args < 2) or (valueType ~= 'nil' and #args < 3)) then
		if (valueType == 'nil') then
			NetEvents:SendToLocal('EbxEdit:ServerMessage', player, {
				["Message"] = "Usage: `"..command.."` <*ResourcePathOrGUID*|**String**> <*PropertyNamePath*|**string**>"
			})
		else
			NetEvents:SendToLocal('EbxEdit:ServerMessage', player, {
				["Message"] = "Usage: `"..command.."` <*ResourcePathOrGUID*|**String**> <*PropertyNamePath*|**string**> <*NewValue*|**"..valueType.."**>"
			})
		end
		return
	end
	local resource, propertyPath, newValue, status

	resource, status = ebxEditUtils:GetWritableInstance(args[1])
	if (status ~= true) then
		NetEvents:SendToLocal('EbxEdit:ServerMessage', player, {
			["Message"] = "**Argument 1 `ResourcePathOrGUID` Not Found**: "..status
		})
		return
	end

	propertyPath = ebxEditUtils:GetValidPath(args[2])
	if (#propertyPath < 1) then
		NetEvents:SendToLocal('EbxEdit:ServerMessage', player, {
			["Message"] = "**Argument 2 `PropertyNamePath` Invalid**"
		})
		return
	end

	if (valueType ~= 'nil') then

		local argValue = args[3]

		-- if string, grab any extra arguments and reconstitute
		if (valueType == 'string') then
			argValue = ''
			for i=3, #args do
				if (argValue:len() > 0) then
					argValue = argValue..' '
				end
				argValue = argValue..args[i]
			end
		end

		newValue, status = ebxEditUtils:ValidateValue(argValue, {["Type"] = valueType})
		if (status ~= true) then
			NetEvents:SendToLocal('EbxEdit:ServerMessage', player, {
				["Message"] = "**Argument 3 `NewValue` Invalid**: "..status
			})
			return
		end
	end

	-- all validated, everything should be usable now
	local workingInstance, propertyName, valid = ebxEditUtils:GetWritableProperty(resource, propertyPath)

	if (not valid) then
		NetEvents:SendToLocal('EbxEdit:ServerMessage', player, {
			["Message"] = "**Argument 2 `PropertyNamePath` Invalid at segment**: "..propertyName
		})
		return
	end

	-- all that work so we can do this and actually WRITE the value
	if (valueType == 'number') then
		workingInstance[propertyName] = tonumber(newValue)

	elseif (valueType == 'string') then
		workingInstance[propertyName] = newValue

	elseif (valueType == 'boolean') then
		workingInstance[propertyName] = (newValue == 'true')

	elseif (valueType == 'nil') then
		workingInstance[propertyName] = nil
	end

	NetEvents:SendToLocal('EbxEdit:ServerMessage', player, {
		["Message"] = "*Success*: "..tostring(propertyName)..' | '..tostring(workingInstance[propertyName])
	})
	-- tell everyone to set this on their client
	NetEvents:BroadcastLocal('EbxEdit:ClientSetValue', {
		["Instance"] = args[1],
		["Path"] = propertyPath,
		["Type"] = valueType,
		["Value"] = newValue
	})

end

return EbxEditServer()