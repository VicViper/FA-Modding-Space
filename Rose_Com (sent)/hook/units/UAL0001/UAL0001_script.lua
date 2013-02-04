local oldUAL0001 = UAL0001

UAL0001 = Class(oldUAL0001) {

    CreateEnhancement = function(self, enh)
        AWalkingLandUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]

        # Resource Allocation
        if enh == 'ResourceAllocation' then
            # AWalkingLandUnit.CreateEnhancement(self, enh)
            local bp = self:GetBlueprint().Enhancements[enh]
            local bpEcon = self:GetBlueprint().Economy
            if not bp then return end
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + bpEcon.ProductionPerSecondMass or 0)
            if not Buffs['AeonACUResourceAllocation'] then
               BuffBlueprint {
                    Name = 'AeonACUResourceAllocation',
                    DisplayName = 'AeonACUResourceAllocation',
                    BuffType = 'ACUREGENERATEBONUS',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                } 
            end
            if Buff.HasBuff( self, 'AeonACUResourceAllocation' ) then
                Buff.RemoveBuff( self, 'AeonACUResourceAllocation' )
            end  
            Buff.ApplyBuff(self, 'AeonACUResourceAllocation')
        elseif enh == 'ResourceAllocationRemove' then
            # AWalkingLandUnit.CreateEnhancement(self, enh)
            local bpEcon = self:GetBlueprint().Economy
            self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)
            if Buff.HasBuff( self, 'AeonACUResourceAllocation' ) then
                Buff.RemoveBuff( self, 'AeonACUResourceAllocation' )
            end  

        elseif enh == 'ResourceAllocationAdvanced' then
            # AWalkingLandUnit.CreateEnhancement(self, enh)
            local bp = self:GetBlueprint().Enhancements[enh]
            local bpEcon = self:GetBlueprint().Economy
            if not bp then return end
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + bpEcon.ProductionPerSecondMass or 0)
            if not Buffs['AeonACUResourceAllocationAdv'] then
               BuffBlueprint {
                    Name = 'AeonACUResourceAllocationAdv',
                    DisplayName = 'AeonACUResourceAllocationAdv',
                    BuffType = 'ACUREGENERATEBONUS',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                } 
            end
            if Buff.HasBuff( self, 'AeonACUResourceAllocationAdv' ) then
                Buff.RemoveBuff( self, 'AeonACUResourceAllocationAdv' )
            end  
            Buff.ApplyBuff(self, 'AeonACUResourceAllocationAdv')

        elseif enh == 'ResourceAllocationAdvancedRemove' then
            # AWalkingLandUnit.CreateEnhancement(self, enh)
            local bpEcon = self:GetBlueprint().Economy
            self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)
            if Buff.HasBuff( self, 'AeonACUResourceAllocationAdv' ) then
                Buff.RemoveBuff( self, 'AeonACUResourceAllocationAdv' )
            end  
            if Buff.HasBuff( self, 'AeonACUResourceAllocation' ) then # Remove both buffs
                Buff.RemoveBuff( self, 'AeonACUResourceAllocation' )
            end  

        #Teleporter
        elseif enh == 'Teleporter' then
            # AWalkingLandUnit.CreateEnhancement(self, enh)
            self:AddCommandCap('RULEUCC_Teleport')
            if not Buffs['AeonACUTeleporter'] then
               BuffBlueprint {
                    Name = 'AeonACUTeleporter',
                    DisplayName = 'AeonACUTeleporter',
                    BuffType = 'ACUREGENERATEBONUS',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                } 
            end
            if Buff.HasBuff( self, 'AeonACUTeleporter' ) then
                Buff.RemoveBuff( self, 'AeonACUTeleporter' )
            end  
            Buff.ApplyBuff(self, 'AeonACUTeleporter')
        elseif enh == 'TeleporterRemove' then
            # AWalkingLandUnit.CreateEnhancement(self, enh)
            self:RemoveCommandCap('RULEUCC_Teleport')
            if Buff.HasBuff( self, 'AeonACUTeleporter' ) then
                Buff.RemoveBuff( self, 'AeonACUTeleporter' )
            end  

        # Chrono Dampener
        elseif enh == 'ChronoDampener' then
            # AWalkingLandUnit.CreateEnhancement(self, enh)
            self:SetWeaponEnabledByLabel('ChronoDampener', true)
            if not Buffs['AeonACUChronoDampener'] then
               BuffBlueprint {
                    Name = 'AeonACUChronoDampener',
                    DisplayName = 'AeonACUChronoDampener',
                    BuffType = 'ACUREGENERATEBONUS',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                } 
            end
            if Buff.HasBuff( self, 'AeonACUChronoDampener' ) then
                Buff.RemoveBuff( self, 'AeonACUChronoDampener' )
            end  
            Buff.ApplyBuff(self, 'AeonACUChronoDampener')
        elseif enh == 'ChronoDampenerRemove' then
            # AWalkingLandUnit.CreateEnhancement(self, enh)
            self:SetWeaponEnabledByLabel('ChronoDampener', false)
            if Buff.HasBuff( self, 'AeonACUChronoDampener' ) then
                Buff.RemoveBuff( self, 'AeonACUChronoDampener' )
            end  

        # Crysalis Beam
        elseif enh == 'CrysalisBeam' then
            # AWalkingLandUnit.CreateEnhancement(self, enh)
            local wep = self:GetWeaponByLabel('RightDisruptor')
            wep:ChangeMaxRadius(bp.NewMaxRadius or 44)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bp.NewMaxRadius or 44)
            if not Buffs['AeonACUCrysalisBeam'] then
               BuffBlueprint {
                    Name = 'AeonACUCrysalisBeam',
                    DisplayName = 'AeonACUCrysalisBeam',
                    BuffType = 'ACUREGENERATEBONUS',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                } 
            end
            if Buff.HasBuff( self, 'AeonACUCrysalisBeam' ) then
                Buff.RemoveBuff( self, 'AeonACUCrysalisBeam' )
            end  
            Buff.ApplyBuff(self, 'AeonACUCrysalisBeam')
        elseif enh == 'CrysalisBeamRemove' then
            # AWalkingLandUnit.CreateEnhancement(self, enh)
            local wep = self:GetWeaponByLabel('RightDisruptor')
            local bpDisrupt = self:GetBlueprint().Weapon[1].MaxRadius
            wep:ChangeMaxRadius(bpDisrupt or 22)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bpDisrupt or 22)
            if Buff.HasBuff( self, 'AeonACUCrysalisBeam' ) then
                Buff.RemoveBuff( self, 'AeonACUCrysalisBeam' )
            end  

        # Heat Sink Augmentation
        elseif enh == 'HeatSink' then
            # AWalkingLandUnit.CreateEnhancement(self, enh)
            local wep = self:GetWeaponByLabel('RightDisruptor')
            wep:ChangeRateOfFire(bp.NewRateOfFire or 2)
            if not Buffs['AeonACUHeatSink'] then
               BuffBlueprint {
                    Name = 'AeonACUHeatSink',
                    DisplayName = 'AeonACUHeatSink',
                    BuffType = 'ACUREGENERATEBONUS',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                } 
            end
            if Buff.HasBuff( self, 'AeonACUHeatSink' ) then
                Buff.RemoveBuff( self, 'AeonACUHeatSink' )
            end  
            Buff.ApplyBuff(self, 'AeonACUHeatSink')

        elseif enh == 'HeatSinkRemove' then
            # AWalkingLandUnit.CreateEnhancement(self, enh)
            local wep = self:GetWeaponByLabel('RightDisruptor')
            local bpDisrupt = self:GetBlueprint().Weapon[1].RateOfFire
            wep:ChangeRateOfFire(bpDisrupt or 1)
            if Buff.HasBuff( self, 'AeonACUHeatSink' ) then
                Buff.RemoveBuff( self, 'AeonACUHeatSink' )
            end  

        # Enhanced Sensors
        elseif enh == 'EnhancedSensors' then
            # AWalkingLandUnit.CreateEnhancement(self, enh)
            self:SetIntelRadius('Vision', bp.NewVisionRadius or 104)
            self:SetIntelRadius('Omni', bp.NewOmniRadius or 104)
            if not Buffs['AeonACUEnhancedSensors'] then
               BuffBlueprint {
                    Name = 'AeonACUEnhancedSensors',
                    DisplayName = 'AeonACUEnhancedSensors',
                    BuffType = 'ACUREGENERATEBONUS',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                } 
            end
            if Buff.HasBuff( self, 'AeonACUEnhancedSensors' ) then
                Buff.RemoveBuff( self, 'AeonACUEnhancedSensors' )
            end  
            Buff.ApplyBuff(self, 'AeonACUEnhancedSensors')
        elseif enh == 'EnhancedSensorsRemove' then
            # AWalkingLandUnit.CreateEnhancement(self, enh)
            local bpIntel = self:GetBlueprint().Intel
            self:SetIntelRadius('Vision', bpIntel.VisionRadius or 26)
            self:SetIntelRadius('Omni', bpIntel.OmniRadius or 26)
            if Buff.HasBuff( self, 'AeonACUEnhancedSensors' ) then
                Buff.RemoveBuff( self, 'AeonACUEnhancedSensors' )
            end  

        else
            oldUAL0001.CreateEnhancement(self, enh)
        end
    end,

}

TypeClass = UAL0001