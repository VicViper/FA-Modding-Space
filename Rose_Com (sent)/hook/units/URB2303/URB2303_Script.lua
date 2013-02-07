local oldUEB2303 = URB2303
local CStructureUnit = import('/lua/cybranunits.lua').CStructureUnit
local CIFArtilleryWeapon = import('/lua/cybranweapons.lua').CIFArtilleryWeapon

URB2303 = Class(oldUEB2303) {
	
	onCreate = function(self)
		oldUEB2303:onCreate()
		self:SetWeaponEnabledByLabel('SecondaryGun', false)
	end,
	
	OnScriptBitClear = function(self, bit)
        if bit == 1 then 
			self:SetWeaponEnabledByLabel('SecondaryGun', false)
            self:SetWeaponEnabledByLabel('MainGun', true)
            self:GetWeaponManipulatorByLabel('MainGun'):SetHeadingPitch( self:GetWeaponManipulatorByLabel('SecondaryGun'):GetHeadingPitch() )
        end
    end,
	
	OnScriptBitSet = function(self, bit)
        if bit == 1 then 
			self:SetWeaponEnabledByLabel('SecondaryGun', true)
            self:SetWeaponEnabledByLabel('MainGun', false)
            self:GetWeaponManipulatorByLabel('SecondaryGun'):SetHeadingPitch( self:GetWeaponManipulatorByLabel('MainGun'):GetHeadingPitch() )
        end
    end,
	
	Weapons = {
        MainGun = Class(CIFArtilleryWeapon) {
        },
		SecondaryGun = Class(CIFArtilleryWeapon) {
        },
    },
}

TypeClass = URB2303