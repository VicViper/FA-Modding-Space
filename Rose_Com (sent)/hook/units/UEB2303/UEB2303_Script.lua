local oldUEB2303 = UEB2303

UEB2303 = Class(oldUEB2303) {
	
	
	OnScriptBitSet = function(self, bit)

        if bit == 1 then 
			self:GetWeaponByLabel('MainGun').BallisticArc = 'RULEUBA_HighArc'
        end
    end,
	
	OnScriptBitClear = function(self, bit)
        if bit == 1 then 
			self:GetWeaponByLabel('MainGun').BallisticArc = 'RULEUBA_LowArc'
        end
    end,
}

TypeClass = UEB2303