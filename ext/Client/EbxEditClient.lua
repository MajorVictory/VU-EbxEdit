class 'EbxEditClient'

function EbxEditClient:__init()
    print("EbxEditClient Loading...")
    self:RegisterConsoleCommands()
    self:RegisterEvents()
end

function EbxEditClient:RegisterConsoleCommands()
    Console:Register('GetValue', '<*ResourcePathOrGUID*|**String**> <*PropertyNamePath*|**string**> Returns the value at the given resource and path', self, self.onRequestGetValue)
    Console:Register('SetNumber', '<*ResourcePathOrGUID*|**String**> <*PropertyNamePath*|**string**> <*NewValue*|**number**> Set a numerical value on the given resource', self, self.onRequestSetNumber)
    --Console:Register('SetString', '<*ResourcePathOrGUID*|**String**> <*PropertyNamePath*|**string**> <*NewValue*|**string**> Set a string value on the given resource', self, self.onRequestSetString)
    --Console:Register('SetNil', '<*ResourcePathOrGUID*|**String**> <*PropertyNamePath*|**string**> Set a value on the given resource to `nil`', self, self.onRequestSetNil)
end

function EbxEditClient:RegisterEvents()
	NetEvents:Subscribe('EbxEdit:ClientSetNumber', self, self.onClientSetNumber)
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

function EbxEditClient:onRequestSetNil(args)
	NetEvents:SendLocal('EbxEdit:SetNil', args)
end

function EbxEditClient:onServerMessage(args)
	SharedUtils:Print(args.Message)
end

function EbxEditClient:onClientSetNumber(args)

	SharedUtils:Print('args: '..ebxEditUtils:dump(args))

	local resource, status = ebxEditUtils:GetWritableInstance(args.Instance)

	-- server said it's ok, here's the info to do it now
	-- all validated, everything should be usable now
	workingInstance, propertyName, valid = ebxEditUtils:GetWritableProperty(resource, args.Path)

	if (property == nil or status ~= true) then
		NetEvents:SendToLocal('EbxEdit:ServerMessage', player, {
			["Message"] = "**Argument 2 `PropertyNamePath` Invalid at segment**: "..status
		})
		return
	end

	workingInstance[propertyName] = tonumber(args.Value)

end

return EbxEditClient()