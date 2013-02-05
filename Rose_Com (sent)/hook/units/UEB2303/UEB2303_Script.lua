local oldUEB2303 = UEB2303

UEB2303 = Class(oldUEB2303) {
	
	EnableSpecialToggle = function() {
		if (toggled=='low') {
			self.weapon.BallisticArc = 'RULEUBA_HighArc'
			self.toggled='high'
		} elseif(toggled=='high') {
			self.weapon.BallisticArc = 'RULEUBA_LowArc'
			self.toggled='low'
		}
	},

}

TypeClass = UEB2303