local SeraphimBuffField = SWeapons.SeraphimBuffField


local oldXSL0001 = XSL0001

XSL0001 = Class(oldXSL0001) {

    BuffFields = {
        RegenField = Class(SeraphimBuffField) {
            Create = function(self, Owner, BuffFieldName)
                # adding the buff we'll use in this buff field
                if not Buffs['SeraphimACURegenAura'] then
                    local bp = Owner:GetBlueprint().Enhancements['RegenAura']
                    BuffBlueprint {
                        Name = 'SeraphimACURegenAura',
                        DisplayName = 'SeraphimACURegenAura',
                        BuffType = 'COMMANDERAURA',
                        Stacks = 'REPLACE',
                        Duration = -1,
                        Affects = {
                            RegenPercent = {
                                Add = 0,
                                Mult = bp.RegenPerSecond or 0.1,
                                Ceil = bp.RegenCeiling,
                                Floor = bp.RegenFloor,
                            },
                        },
                    }
                end
                SeraphimBuffField.Create(self, Owner, BuffFieldName)
            end,
        },

        AdvancedRegenField = Class(SeraphimBuffField) {
            Create = function(self, Owner, BuffFieldName)
                # adding the buff we'll use in this buff field
                if not Buffs['SeraphimAdvancedACURegenAura'] then
                    local bp = Owner:GetBlueprint().Enhancements['AdvancedRegenAura']
                    BuffBlueprint {
                        Name = 'SeraphimAdvancedACURegenAura',
                        DisplayName = 'SeraphimAdvancedACURegenAura',
                        BuffType = 'COMMANDERAURA',
                        Stacks = 'REPLACE',
                        Duration = -1,
                        Affects = {
                            RegenPercent = {
                                Add = 0,
                                Mult = bp.RegenPerSecond or 0.1,
                                Ceil = bp.RegenCeiling,
                                Floor = bp.RegenFloor,
                            },
                            MaxHealth = {
                                Add = 0,
                                Mult = bp.MaxHealthFactor or 1.0,
                                DoNoFill = true,
                            },                        
                        },
                    }
                end
                SeraphimBuffField.Create(self, Owner, BuffFieldName)
            end,

            OnPreUnitEntersField = function(self, unit)
                SeraphimBuffField.OnPreUnitEntersField(self, unit)
                return (unit:GetHealth() / unit:GetMaxHealth())
            end,

            OnUnitEntersField = function(self, unit, OnPreUnitEntersFieldData)
                SeraphimBuffField.OnUnitEntersField(self, unit, OnPreUnitEntersFieldData)
                unit:SetHealth(unit, (OnPreUnitEntersFieldData * unit:GetMaxHealth()))
            end,

            OnPreUnitLeavesField = function(self, unit, OnPreUnitEntersFieldData, OnUnitEntersFieldData)
                SeraphimBuffField.OnPreUnitLeavesField(self, unit, OnPreUnitEntersFieldData, OnUnitEntersFieldData)
                return (unit:GetHealth() / unit:GetMaxHealth())
            end,

            OnUnitLeavesField = function(self, unit, OnPreUnitEntersFieldData, OnUnitEntersFieldData, OnPreUnitLeavesField)
                SeraphimBuffField.OnUnitLeavesField(self, unit, OnPreUnitEntersFieldData, OnUnitEntersFieldData, OnPreUnitLeavesField)
                unit:SetHealth(unit, (OnPreUnitLeavesField * unit:GetMaxHealth()))
            end,
        },
    },

    CreateEnhancement = function(self, enh)
        # SWalkingLandUnit.CreateEnhancement(self, enh) # Moved to each individual enhancement so it wont run twice
        local bp = self:GetBlueprint().Enhancements[enh]
        
        # Regenerative Aura
        # added by brute51 - enhanced this whole section
        if enh == 'RegenAura' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
            self:GetBuffFieldByName('SeraphimACURegenBuffField'):Enable()                        
        elseif enh == 'RegenAuraRemove' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
            self:GetBuffFieldByName('SeraphimACURegenBuffField'):Disable()

        elseif enh == 'AdvancedRegenAura' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
            self:GetBuffFieldByName('SeraphimACURegenBuffField'):Disable()
            self:GetBuffFieldByName('SeraphimAdvancedACURegenBuffField'):Enable()            
        elseif enh == 'AdvancedRegenAuraRemove' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
            self:GetBuffFieldByName('SeraphimAdvancedACURegenBuffField'):Disable()

        #Resource Allocation
        elseif enh == 'ResourceAllocation' then  #elseif
            SWalkingLandUnit.CreateEnhancement(self, enh)
            local bp = self:GetBlueprint().Enhancements[enh]
            local bpEcon = self:GetBlueprint().Economy
            if not bp then return end
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + bpEcon.ProductionPerSecondMass or 0)
            if not Buffs['SeraphimACUResourceAllocation'] then  #If the buff does not exist define the buff
              BuffBlueprint {
                Name = 'SeraphimACUResourceAllocation',
                DisplayName = 'SeraphimACUResourceAllocation',
                BuffType = 'ACUUPGRADEDMG',
                Stacks = 'ALWAYS',
                Duration = -1,  #This means indefinite
                Affects = {
                    MaxHealth = {
                        Add = bp.NewHealth,
                        Mult = 1.0,
                    },
                    Regen = {
                        Add = bp.NewRegenRate,
                        Mult = 1.0,
                    },
                },
              }
            end
            if Buff.HasBuff( self, 'SeraphimACUResourceAllocation' ) then  #if it has the buff, remove it
              Buff.RemoveBuff( self, 'SeraphimACUResourceAllocation' )
            end
            Buff.ApplyBuff(self, 'SeraphimACUResourceAllocation')  #then give it the buff here

        elseif enh == 'ResourceAllocationRemove' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
            local bpEcon = self:GetBlueprint().Economy
            self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)
            if Buff.HasBuff( self, 'SeraphimACUResourceAllocation' ) then #remove the buff when you remove the upgrade
              Buff.RemoveBuff( self, 'SeraphimACUResourceAllocation' )
            end

        elseif enh == 'ResourceAllocationAdvanced' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
            local bp = self:GetBlueprint().Enhancements[enh]
            local bpEcon = self:GetBlueprint().Economy
            if not bp then return end
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + bpEcon.ProductionPerSecondMass or 0)
            if not Buffs['SeraphimACUResourceAllocationAdv'] then  # If it doesnt have the buff define the buff
               BuffBlueprint {
                    Name = 'SeraphimACUResourceAllocationAdv',
                    DisplayName = 'SeraphimACUResourceAllocationAdv',
                    BuffType = 'ACUUPGRADEDMG',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                        Regen = {
                            Add = bp.NewRegenRate,
                            Mult = 1.0,
                        },
                    },
                } 
            end
            if Buff.HasBuff( self, 'SeraphimACUResourceAllocationAdv' ) then  # if it has the buff, remove it
                Buff.RemoveBuff( self, 'SeraphimACUResourceAllocationAdv' )
            end  
            Buff.ApplyBuff(self, 'SeraphimACUResourceAllocationAdv')  # then give it the buff here

        elseif enh == 'ResourceAllocationAdvancedRemove' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
            local bpEcon = self:GetBlueprint().Economy
            self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)
            if Buff.HasBuff( self, 'SeraphimACUResourceAllocationAdv' ) then # remove the buff when you remove the upgrade
              Buff.RemoveBuff( self, 'SeraphimACUResourceAllocationAdv' )
            end
            if Buff.HasBuff( self, 'SeraphimACUResourceAllocation' ) then #remove the other buff when you remove the upgrade
              Buff.RemoveBuff( self, 'SeraphimACUResourceAllocation' )
            end

        #Teleporter
        elseif enh == 'Teleporter' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
            self:AddCommandCap('RULEUCC_Teleport')
            if not Buffs['SeraphimACUTeleporter'] then
               BuffBlueprint {
                    Name = 'SeraphimACUTeleporter',
                    DisplayName = 'SeraphimACUTeleporter',
                    BuffType = 'ACUUPGRADEDMG',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                        Regen = {
                            Add = bp.NewRegenRate,
                            Mult = 1.0,
                        },
                    },
                } 
            end
            if Buff.HasBuff( self, 'SeraphimACUTeleporter' ) then
                Buff.RemoveBuff( self, 'SeraphimACUTeleporter' )
            end
            Buff.ApplyBuff(self, 'SeraphimACUTeleporter')  
        elseif enh == 'TeleporterRemove' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
            self:RemoveCommandCap('RULEUCC_Teleport')
            if Buff.HasBuff( self, 'SeraphimACUTeleporter' ) then
              Buff.RemoveBuff( self, 'SeraphimACUTeleporter' )
            end

        # Tactical Missile
        elseif enh == 'Missile' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
            self:AddCommandCap('RULEUCC_Tactical')
            self:AddCommandCap('RULEUCC_SiloBuildTactical')        
            self:SetWeaponEnabledByLabel('Missile', true)
            if not Buffs['SeraphimACUMissile'] then
               BuffBlueprint {
                    Name = 'SeraphimACUMissile',
                    DisplayName = 'SeraphimACUMissile',
                    BuffType = 'ACUUPGRADEDMG',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                        Regen = {
                            Add = bp.NewRegenRate,
                            Mult = 1.0,
                        },
                    },
                } 
            end
            if Buff.HasBuff( self, 'SeraphimACUMissile' ) then
                Buff.RemoveBuff( self, 'SeraphimACUMissile' )
            end
            Buff.ApplyBuff(self, 'SeraphimACUMissile')  
        elseif enh == 'MissileRemove' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
            self:RemoveCommandCap('RULEUCC_Tactical')
            self:RemoveCommandCap('RULEUCC_SiloBuildTactical')        
            self:SetWeaponEnabledByLabel('Missile', false)
            if Buff.HasBuff( self, 'SeraphimACUMissile' ) then
                Buff.RemoveBuff( self, 'SeraphimACUMissile' )
            end

        #Blast Attack
        elseif enh == 'BlastAttack' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            wep:AddDamageRadiusMod(bp.NewDamageRadius or 5)
            wep:AddDamageMod(bp.AdditionalDamage)
            if not Buffs['SeraphimACUBlastAttack'] then
               BuffBlueprint {
                    Name = 'SeraphimACUBlastAttack',
                    DisplayName = 'SeraphimACUBlastAttack',
                    BuffType = 'ACUUPGRADEDMG',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                        Regen = {
                            Add = bp.NewRegenRate,
                            Mult = 1.0,
                        },
                    },
                } 
            end
            if Buff.HasBuff( self, 'SeraphimACUBlastAttack' ) then
                Buff.RemoveBuff( self, 'SeraphimACUBlastAttack' )
            end
            Buff.ApplyBuff(self, 'SeraphimACUBlastAttack')
        elseif enh == 'BlastAttackRemove' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            wep:AddDamageRadiusMod(-self:GetBlueprint().Enhancements['BlastAttack'].NewDamageRadius) # unlimited AOE bug fix by brute51 [117]
            wep:AddDamageMod(-self:GetBlueprint().Enhancements['BlastAttack'].AdditionalDamage)
            if Buff.HasBuff( self, 'SeraphimACUBlastAttack' ) then
                Buff.RemoveBuff( self, 'SeraphimACUBlastAttack' )
            end

        #Heat Sink Augmentation
        elseif enh == 'RateOfFire' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            wep:ChangeRateOfFire(bp.NewRateOfFire or 2)
            wep:ChangeMaxRadius(bp.NewMaxRadius or 44)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bp.NewMaxRadius or 44)            
            if not Buffs['SeraphimACURateOfFire'] then
               BuffBlueprint {
                    Name = 'SeraphimACURateOfFire',
                    DisplayName = 'SeraphimACURateOfFire',
                    BuffType = 'ACUUPGRADEDMG',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                        Regen = {
                            Add = bp.NewRegenRate,
                            Mult = 1.0,
                        },
                    },
                } 
            end
            if Buff.HasBuff( self, 'SeraphimACURateOfFire' ) then
                Buff.RemoveBuff( self, 'SeraphimACURateOfFire' )
            end
            Buff.ApplyBuff(self, 'SeraphimACURateOfFire')
        elseif enh == 'RateOfFireRemove' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            local bpDisrupt = self:GetBlueprint().Weapon[1].RateOfFire
            wep:ChangeRateOfFire(bpDisrupt or 1)
            bpDisrupt = self:GetBlueprint().Weapon[1].MaxRadius            
            wep:ChangeMaxRadius(bpDisrupt or 22)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bpDisrupt or 22)                        
            if Buff.HasBuff( self, 'SeraphimACURateOfFire' ) then
                Buff.RemoveBuff( self, 'SeraphimACURateOfFire' )
            end

        else
            oldXSL0001.CreateEnhancement(self, enh)
        end
    end,
}

TypeClass = XSL0001