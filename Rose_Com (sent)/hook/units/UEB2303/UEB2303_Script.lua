local oldUEB2303 = UEB2303

UEB2303 = Class(oldUEB2303) {
	
	
	OnScriptBitSet = function(self, bit)
        if bit == 1 then 
			self:GetWeaponByLabel('MainGun').BallisticArc = 'RULEUBA_HighArc'
			self:GetWeaponByLabel('MainGun'):SetupTurret()
			LOG(self:GetWeaponByLabel('MainGun').BallisticArc)
        end
    end,
	
	OnScriptBitClear = function(self, bit)
        if bit == 1 then 
			self:GetWeaponByLabel('MainGun').BallisticArc = 'RULEUBA_LowArc'
			self:GetWeaponByLabel('MainGun'):SetupTurret()
			LOG(self:GetWeaponByLabel('MainGun').BallisticArc)
        end
    end,
}

TypeClass = UEB2303