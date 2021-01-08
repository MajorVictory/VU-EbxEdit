class 'EbxEditServer'

function EbxEditServer:__init()
    print("EbxEditServer Loading...")

	self.allowedUsernames = {
		'MajorVictory87',
		--'MinorVictory',
		--'MinorFailure'
	}

	self:RegisterEvents()
end

function EbxEditServer:RegisterEvents()
	NetEvents:Subscribe('EbxEdit:GetValue', self, self.onGetValue)
	NetEvents:Subscribe('EbxEdit:SetNumber', self, self.onSetNumber)
	NetEvents:Subscribe('EbxEdit:SetString', self, self.onSetString)
	NetEvents:Subscribe('EbxEdit:SetNil', self, self.onSetNil)
end

function EbxEditServer:CheckUser(player)
	for name=0, #self.allowedUsernames do
		if (player ~= nil and player.name == self.allowedUsernames[name]) then
			return true
		end
	end
    SharedUtils:Print("User tried to edit something: "..tostring(player.name))
	NetEvents:SendToLocal('EbxEdit:ServerMessage', player, {["Message"] = "**You are not authorized to make edits**"})
	return false
end

function EbxEditServer:onGetValue(player, args)

	NetEvents:SendToLocal('EbxEdit:ServerMessage', player, {["Message"] = "*onGetValue* ["..ebxEditUtils:getModuleState().."]"})
	SharedUtils:Print("*onGetValue* ["..ebxEditUtils:getModuleState().."]")

	if (#args < 2) then
		NetEvents:SendToLocal('EbxEdit:ServerMessage', player, {
			["Message"] = "Usage: `vu-ebxedit.GetValue` <*ResourcePathOrGUID*|**String**> <*PropertyNamePath*|**string**>"
		})
		return
	end
	local resource, propertyPath, property, newValue, status

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

	SharedUtils:Print(ebxEditUtils:dump(workingInstance))
	SharedUtils:Print(ebxEditUtils:dump(propertyName))
	SharedUtils:Print(ebxEditUtils:dump(workingInstance[propertyName]))
	NetEvents:SendToLocal('EbxEdit:ServerMessage', player, {
		["Message"] = ebxEditUtils:dump(workingInstance[propertyName])
	})
end

function EbxEditServer:onSetNumber(player, args)

	NetEvents:SendToLocal('EbxEdit:ServerMessage', player, {["Message"] = "*onSetNumber* ["..ebxEditUtils:getModuleState().."]"})
	SharedUtils:Print("*onSetNumber* ["..ebxEditUtils:getModuleState().."]")
	if (not self:CheckUser(player)) then
		return
	end

	if (#args < 3) then
		NetEvents:SendToLocal('EbxEdit:ServerMessage', player, {
			["Message"] = "Usage: `vu-ebxedit.SetNumber` <*ResourcePathOrGUID*|**String**> <*PropertyNamePath*|**string**> <*NewValue*|**number**>"
		})
		return
	end
	local resource, propertyPath, property, newValue, status

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

	newValue, status = ebxEditUtils:ValidateValue(args[3], {["Type"] = 'number'})
	if (status ~= true) then
		NetEvents:SendToLocal('EbxEdit:ServerMessage', player, {
			["Message"] = "**Argument 3 `NewValue` Invalid**: "..status
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

	workingInstance[propertyName] = tonumber(newValue)

	NetEvents:SendToLocal('EbxEdit:ServerMessage', player, {
		["Message"] = "*Success*: "..tostring(propertyName)..' | '..tostring(workingInstance[propertyName])
	})
	-- tell everyone to set this on their client
	NetEvents:BroadcastLocal('EbxEdit:ClientSetNumber', {
		["Instance"] = args[1],
		["Path"] = propertyPath,
		["Value"] = newValue
	})

end

function EbxEditServer:onSetString(player, args)

	NetEvents:SendToLocal('EbxEdit:ServerMessage', player, {["Message"] = "*onSetString*"})
	if (not self:CheckUser(player)) then
		return
	end

	if (#args < 3) then
		NetEvents:SendToLocal('EbxEdit:ServerMessage', player, {
			["Message"] = "Usage: `vu-ebxedit.SetNumber` <*ResourcePathOrGUID*|**String**> <*PropertyNamePath*|**string**> <*NewValue*|**string**>"
		})
		return false
	end

	local resourcePath = args[1]
	local propertyPath = args[2]

	local concatvalue = ''
	for i=3, #args do
		if (string.len(concatvalue) > 0) then
			concatvalue = concatvalue..' '
		end
		concatvalue = concatvalue..args[i]
	end

	local newValue, status = EbxEditUtils:ValidateValue(args[3], {})

end


function EbxEditServer:onSetNil(player, args)

	NetEvents:SendToLocal('EbxEdit:ServerMessage', player, {["Message"] = "*onSetNil*"})
	if (not self:CheckUser(player)) then
		return
	end

	if (#args < 2) then
		NetEvents:SendToLocal('EbxEdit:ServerMessage', player, {
			["Message"] = "Usage: `vu-ebxedit.SetNumber` <*ResourcePathOrGUID*|**String**> <*PropertyNamePath*|**string**>"
		})
		return false
	end

end


return EbxEditServer()