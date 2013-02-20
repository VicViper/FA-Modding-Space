local oldXSB2303 = XSB2303

XSB2303 = Class(oldXSB2303) {
	
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
        MainGun = Class(SIFZthuthaamArtilleryCannon) {
        },
		SecondaryGun = Class(SIFZthuthaamArtilleryCannon) {
        },
    },
}

TypeClass = XSB2303