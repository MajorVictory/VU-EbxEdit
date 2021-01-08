# VU-EbxEdit
A mod for Battlefield 3: Venice Unleashed which adds consoles commands to allow live editing.

## Commands
- vu-ebxedit.GetValue <*ResourcePathOrGUID*|**String**> <*PropertyNamePath*|**string**>
- vu-ebxedit.SetNumber <*ResourcePathOrGUID*|**String**> <*PropertyNamePath*|**string**> <*NewValue*|**number**>
- vu-ebxedit.SetString <*ResourcePathOrGUID*|**String**> <*PropertyNamePath*|**string**> <*NewValue*|**string**>

## Usage
While running the game you can type these command into the console to edit any ebx value directly.

### vu-ebxedit.GetValue
Both of these examples  and read the same actual value but in different ways

Method 1 uses the resources Container Name and an absolute path from there
> vu-ebxedit.GetValue Weapons/MP443/MP443_GM object.WeaponFiring.PrimaryFire.ammo.MagazineCapacity

Method 2 uses the resources GUID and the relative path to the value
> vu-ebxedit.GetValue C2E77536-5D91-43AF-B78D-03CDC06C3A6D ammo.MagazineCapacity

### vu-ebxedit.SetNumber
Both of these examples find and set the same actual value but in different ways

Method 1 uses the resources Container Name and an absolute path from there
> vu-ebxedit.SetNumber Weapons/MP443/MP443_GM object.WeaponFiring.PrimaryFire.ammo.MagazineCapacity 25

Method 2 uses the resources GUID and the relative path to the value
> vu-ebxedit.SetNumber C2E77536-5D91-43AF-B78D-03CDC06C3A6D ammo.MagazineCapacity 25

You can even do complex paths through arrays as long as you know which index to use
This example changes the mp443's gun master weapon magazine modifier
> vu-ebxedit.SetNumber Weapons/MP443/MP443_GM object.WeaponModifierData.2.Modifiers.2.MagazineCapacity 25
