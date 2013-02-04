local oldUAL0301 = UAL0301

UAL0301 = Class(oldUAL0301) {    

    CreateEnhancement = function(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end

        #SystemIntegrityCompensator
        if enh == 'SystemIntegrityCompensator' then
            AWalkingLandUnit.CreateEnhancement(self, enh) # moved from first line to here else is run twice for other enhancements
            # added by brute51 - fix for bug SCU regen upgrade doesnt stack with veteran bonus [140]
            local bpRegenRate = bp.NewRegenRate or 0
            if not Buffs['AeonSCURegenerateBonus'] then
               BuffBlueprint {
                    Name = 'AeonSCURegenerateBonus',
                    DisplayName = 'AeonSCURegenerateBonus',
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
            if Buff.HasBuff( self, 'AeonSCURegenerateBonus' ) then
                Buff.RemoveBuff( self, 'AeonSCURegenerateBonus' )
            end  
            Buff.ApplyBuff(self, 'AeonSCURegenerateBonus')
        elseif enh == 'SystemIntegrityCompensatorRemove' then
            AWalkingLandUnit.CreateEnhancement(self, enh) # moved from first line to here else is run twice for other enhancements
            # added by brute51 - fix for bug SCU regen upgrade doesnt stack with veteran bonus [140]
            if Buff.HasBuff( self, 'AeonSCURegenerateBonus' ) then
                Buff.RemoveBuff( self, 'AeonSCURegenerateBonus' )
            end  
        else
            oldUAL0301.CreateEnhancement(self, enh)
        end
    end,     
}

TypeClass = UAL0301
