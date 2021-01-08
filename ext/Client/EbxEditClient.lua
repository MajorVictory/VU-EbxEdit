class 'EbxEditClient'

function EbxEditClient:__init()
    print("EbxEditClient Loading...")
    self:RegisterConsoleCommands()
    self:RegisterEvents()
end

function EbxEditClient:RegisterConsoleCommands()
    Console:Register('GetValue', '<*ResourcePathOrGUID*|**String**> <*PropertyNamePath*|**string**> Returns the value at the given resource and path', self, self.onRequestGetValue)
    Console:Register('SetNumber', '<*ResourcePathOrGUID*|**String**> <*PropertyNamePath*|**string**> <*NewValue*|**number**> Set a numerical value on the given resource', self, self.onRequestSetNumber)
    Console:Register('SetString', '<*ResourcePathOrGUID*|**String**> <*PropertyNamePath*|**string**> <*NewValue*|**string**> Set a string value on the given resource', self, self.onRequestSetString)
    Console:Register('SetBool', '<*ResourcePathOrGUID*|**String**> <*PropertyNamePath*|**string**> <*NewValue*|**boolean**> Set a boolean value on the given resource', self, self.onRequestSetBool)
    Console:Register('SetNil', '<*ResourcePathOrGUID*|**String**> <*PropertyNamePath*|**string**> Set a value on the given resource to `nil`', self, self.onRequestSetNil)
end

function EbxEditClient:RegisterEvents()
	NetEvents:Subscribe('EbxEdit:ClientSetValue', self, self.onClientSetValue)
	NetEvents:Subscribe('EbxEdit:ServerMessage', self, self.onServerMessage)
end

function EbxEditClient:onRequestGetValue(args)
	NetEvents:SendLocal('EbxEdit:GetValue', args)
end

function EbxEditClient:onRequestSetNumber(args)
	NetEvents:SendLocal('EbxEdit:SetNumber', args)
end

function EbxEditClient:onRequestSetString(args)
	NetEvents:SendLocal('EbxEdit:SetString', args)
end

function EbxEditClient:onRequestSetBool(args)
	NetEvents:SendLocal('EbxEdit:SetBool', args)
end

function EbxEditClient:onRequestSetNil(args)
	NetEvents:SendLocal('EbxEdit:SetNil', args)
end

function EbxEditClient:onServerMessage(args)
	SharedUtils:Print(args.Message)
end

function EbxEditClient:onClientSetValue(args)

	-- server said it's ok, here's the info to do it now
	-- validated by server, should be usable as-is
	local resource, status = ebxEditUtils:GetWritableInstance(args.Instance)
	workingInstance, propertyName, valid = ebxEditUtils:GetWritableProperty(resource, args.Path)

	if (not valid) then -- but you broke it anyways
		SharedUtils:Print('**Argument 2 `PropertyNamePath` Invalid at segment**: '..tostring(status))
		return
	end

	if (args.Type == 'number') then
		workingInstance[propertyName] = tonumber(args.Value)

	elseif (args.Type == 'string') then
		workingInstance[propertyName] = args.Value

	elseif (valueType == 'boolean') then
		workingInstance[propertyName] = (args.Value == 'true')

	elseif (args.Type == 'nil') then
		workingInstance[propertyName] = nil
	end
end

return EbxEditClient()