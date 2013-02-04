local oldURL0301 = URL0301

URL0301 = Class(oldURL0301) {

    CreateEnhancement = function(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end

        if enh == 'SelfRepairSystem' then
            CWalkingLandUnit.CreateEnhancement(self, enh) # moved from top to here else this happens twice for some enhancements
            local bpRegenRate = self:GetBlueprint().Enhancements.SelfRepairSystem.NewRegenRate or 0
            # added by brute51 - fix for bug SCU regen upgrade doesnt stack with veteran bonus [140]
            if not Buffs['CybranSCURegenerateBonus'] then
               BuffBlueprint {
                    Name = 'CybranSCURegenerateBonus',
                    DisplayName = 'CybranSCURegenerateBonus',
                    BuffType = 'SCUREGENERATEBONUS',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        Regen = {
                            Add = bpRegenRate,
                            Mult = 1.0,
                        },
                    },
                } 
            end
            if Buff.HasBuff( self, 'CybranSCURegenerateBonus' ) then
                Buff.RemoveBuff( self, 'CybranSCURegenerateBonus' )
            end  
            Buff.ApplyBuff(self, 'CybranSCURegenerateBonus')
        elseif enh == 'SelfRepairSystemRemove' then
            CWalkingLandUnit.CreateEnhancement(self, enh) # moved from top to here else this happens twice for some enhancements
            # added by brute51 - fix for bug SCU regen upgrade doesnt stack with veteran bonus [140]
            if Buff.HasBuff( self, 'CybranSCURegenerateBonus' ) then
                Buff.RemoveBuff( self, 'CybranSCURegenerateBonus' )
            end
        else
            oldURL0301.CreateEnhancement(self, enh)
        end
    end,
 
}

TypeClass = URL0301
