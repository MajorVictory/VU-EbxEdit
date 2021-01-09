# VU-EbxEdit
A mod for Battlefield 3: Venice Unleashed which adds console commands to allow live editing. Now you can crash your game in real-time!

## Commands
- vu-ebxedit.GetValue <*ResourcePathOrGUID*|**String**> <*PropertyNamePath*|**string**>
- vu-ebxedit.SetNumber <*ResourcePathOrGUID*|**String**> <*PropertyNamePath*|**string**> <*NewValue*|**number**>
- vu-ebxedit.SetString <*ResourcePathOrGUID*|**String**> <*PropertyNamePath*|**string**> <*NewValue*|**string**>

## Setup
Read value permissions are by default enabled for everyone. To enable write values permissions for specific users, change the `userCanWrite` array in `EbxEdit\ext\Server\EbxEditServer.lua`. 

## Usage
While running the game you can type these command into the console to edit any ebx value directly.

### vu-ebxedit.GetValue
Both of these examples read the same actual value but in different ways

Method 1 uses the resource's Container Name and an absolute path from there
> vu-ebxedit.GetValue Weapons/MP443/MP443_GM object.WeaponFiring.PrimaryFire.ammo.MagazineCapacity

Method 2 uses the resource's GUID and the relative path to the value
> vu-ebxedit.GetValue C2E77536-5D91-43AF-B78D-03CDC06C3A6D ammo.MagazineCapacity

### vu-ebxedit.SetNumber
Both of these examples find and set the same actual value but in different ways

Method 1 uses the resource's Container Name and an absolute path from there
> vu-ebxedit.SetNumber Weapons/MP443/MP443_GM object.WeaponFiring.PrimaryFire.ammo.MagazineCapacity 25

Method 2 uses the resource's GUID and the relative path to the value
> vu-ebxedit.SetNumber C2E77536-5D91-43AF-B78D-03CDC06C3A6D ammo.MagazineCapacity 25

You can even do complex paths through arrays as long as you know which index to use
This example changes the mp443's gun master weapon magazine modifier
> vu-ebxedit.SetNumber Weapons/MP443/MP443_GM object.WeaponModifierData.2.Modifiers.2.MagazineCapacity 25

## Useful Library
You can import the `EbxEditUtils` class into your mod to make retreiving resources easier

Add the `EbxEditUtils.lua` file to your `ext/shared` folder and don't forget to then `require` the file in your scripts.
```lua
ebxEditUtils = require('__shared/EbxEditUtils')
```
You now have access to the `ebxEditUtils` class in the global namespace of your mod.


Usage:
```lua
-- let's grab the mp443 SoldierWeaponBlueprint
local weaponMP443 = ebxEditUtils:GetWritableInstance('Weapons/MP443/MP443')

-- let's drill down into the firing function and change the MagazineCapacity

-- first lets verify our path format and split it up into an array of parts
local propPath = ebxEditUtils:GetValidPath('Object.WeaponFiring.PrimaryFire.FireLogic.Ammo.MagazineCapacity')

-- now lets search for our data property
local ammoConfigData, property, isValid = ebxEditUtils:GetWritableProperty(weaponMP443, propPath)

if (not isValid) then -- something went wrong, either the instance isn't loaded, or the path name is incorrect
	return
end

-- now we can set our value
ammoConfigData[property] = 300

-- `ammoConfigData` now represents `Object.WeaponFiring.PrimaryFire.FireLogic.Ammo` so you can edit more properties
ammoConfigData.NumberOfMagazines = 5
ammoConfigData.AutoReplenishMagazine = true
ammoConfigData.AutoReplenishDelay = 4
```

### Useful Methods

#### `EbxEditUtils:GetWritableInstance(resourcePathOrGUID)`
This method returns a writable instance and precasts it to the correct type. `resourcePathOrGUID` can either be a path such as `Weapons/MP443/MP443` or a single instance Guid such as `B41C9F21-D723-4607-B2BA-4B2C30677C51`

Usage:
```lua
local fireData = ebxEditUtils:GetWritableInstance('53489D8D-BE0B-4180-9F96-F1B728EFD898')
fireData.shot.initialSpeed.z = 450
fireData.fireLogic.rateOfFire = 900
fireData.ammo.magazineCapacity = 420
fireData.ammo.numberOfMagazines = -1
```

#### `EbxEditUtils:GetWritableProperty(instance, propertyPath|table)`
This method lets you take a higher level object and drill down to a specific value within that object. Normally this requires a lot of local variables and casting instances or a Guid closer to where you want to edit. Note that `propertyPath` is a table containing each of the path names in order.


#### `EbxEditUtils:GetValidPath(propertyPath|string)` and `EbxEditUtils:FormatMemberName(memberName|string)`
The `GetValidPath` method takes a string path to a property and converts it into an array of property names. It will also automatically enforce proper casing using the `FormatMemberName` method if you are using the names from the EBX files directly.
> 'MagazineCapacity' becomes 'magazineCapacity'
> 'AmmoPickupMaxAmount' becomes 'ammoPickupMaxAmount'

It does *NOT*, however, perfectly enforce the naming scheme, **it will not fix casing errors after the first character**
> 'MagazineCaPacity' becomes 'magazineCaPacity'
> 'AmmoPickupmaxAmount' becomes 'ammoPickupmaxAmount'