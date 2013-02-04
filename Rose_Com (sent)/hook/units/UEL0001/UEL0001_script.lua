local oldUEL0001 = UEL0001

UEL0001 = Class(oldUEL0001) {

    NotifyOfPodDeath = function(self, pod)
        if pod == 'LeftPod' then
            if self.HasRightPod then
                TWalkingLandUnit.CreateEnhancement(self, 'RightPodRemove') # cant use CreateEnhancement function
                TWalkingLandUnit.CreateEnhancement(self, 'LeftPod') #makes the correct upgrade icon light up
                if self.LeftPod and not self.LeftPod:IsDead() then
                    self.LeftPod:Kill()
                end
            else
                self:CreateEnhancement('LeftPodRemove')
            end
            self.HasLeftPod = false

        elseif pod == 'RightPod' then   #basically the same as above but we can use the CreateEnhancement function this time
            if self.HasLeftPod then
                TWalkingLandUnit.CreateEnhancement(self, 'RightPodRemove') # cant use CreateEnhancement function
                TWalkingLandUnit.CreateEnhancement(self, 'LeftPod') #makes the correct upgrade icon light up
                if self.LeftPod and not self.LeftPod:IsDead() then
                    self.RightPod:Kill()
                end
            else
                self:CreateEnhancement('LeftPodRemove')
            end
            self.HasRightPod = false

        end
        self:RequestRefreshUI()
    end,

    CreateEnhancement = function(self, enh)
#        TWalkingLandUnit.CreateEnhancement(self, enh) # Moved to each individual function so it wont run twice
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end

        # Drone Pods # Includes bug fix
        if enh == 'LeftPod' or enh == 'RightPod' then
            TWalkingLandUnit.CreateEnhancement(self, enh)

            if not self.LeftPod or self.LeftPod:IsDead() then  # making sure we have up to date information (dont delete! needed for bug fix below)
                self.HasLeftPod = false
            end
            if not self.RightPod or self.RightPod:IsDead() then
                self.HasRightPod = false
            end

            if enh == 'RightPod' and (not self.HasLeftPod or not self.HasRightPod) then  # fix for a bug that occurs when pod 1 is destroyed while upgrading to get pod 2
                TWalkingLandUnit.CreateEnhancement(self, 'RightPodRemove')
                TWalkingLandUnit.CreateEnhancement(self, 'LeftPod')
            end

            # add new pod to left or right
            if not self.HasLeftPod then
                local location = self:GetPosition('AttachSpecial02')
                local pod = CreateUnitHPR('UEA0001', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
                pod:SetCreator(self)
                pod:SetParent(self, 'LeftPod')
                self.Trash:Add(pod)
                self.LeftPod = pod
                self.HasLeftPod = true
            else
                local location = self:GetPosition('AttachSpecial01')
                local pod = CreateUnitHPR('UEA0001', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
                pod:SetCreator(self)
                pod:SetParent(self, 'RightPod')
                self.Trash:Add(pod)
                self.RightPod = pod
                self.HasRightPod = true
            end

            if self.HasLeftPod and self.HasRightPod then  # highlight correct icons: right if we have 2 pods, left if we have 1 pod (no other possibilities)
                TWalkingLandUnit.CreateEnhancement(self, 'RightPod')
            else
                TWalkingLandUnit.CreateEnhancement(self, 'LeftPod')
            end

        # for removing the pod upgrades
        elseif enh == 'RightPodRemove' then
            TWalkingLandUnit.CreateEnhancement(self, enh)
            if self.RightPod and not self.RightPod:IsDead() then
                self.RightPod:Kill()
                self.HasRightPod = false
            end
            if self.LeftPod and not self.LeftPod:IsDead() then
                self.LeftPod:Kill()
                self.HasLeftPod = false
            end
        elseif enh == 'LeftPodRemove' then
            TWalkingLandUnit.CreateEnhancement(self, enh)
            if self.LeftPod and not self.LeftPod:IsDead() then
                self.LeftPod:Kill()
                self.HasLeftPod = false
            end

        # Teleporter
        elseif enh == 'Teleporter' then
            TWalkingLandUnit.CreateEnhancement(self, enh)
            self:AddCommandCap('RULEUCC_Teleport')
            if not Buffs['UefACUTeleporter'] then
               BuffBlueprint {
                    Name = 'UefACUTeleporter',
                    DisplayName = 'UefACUTeleporter',
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
            if Buff.HasBuff( self, 'UefACUTeleporter' ) then
                Buff.RemoveBuff( self, 'UefACUTeleporter' )
            end  
            Buff.ApplyBuff(self, 'UefACUTeleporter')
        elseif enh == 'TeleporterRemove' then
            TWalkingLandUnit.CreateEnhancement(self, enh)
            self:RemoveCommandCap('RULEUCC_Teleport')
            if Buff.HasBuff( self, 'UefACUTeleporter' ) then
                Buff.RemoveBuff( self, 'UefACUTeleporter' )
            end  

--       # Personal Shield
--        elseif enh == 'Shield' then
--            TWalkingLandUnit.CreateEnhancement(self, enh)
--            self:AddToggleCap('RULEUTC_ShieldToggle')
--            self:CreatePersonalShield(bp)
--            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
--            self:SetMaintenanceConsumptionActive()
--            if not Buffs['UefACUShield'] then
--               BuffBlueprint {
--                    Name = 'UefACUShield',
--                    DisplayName = 'UefACUShield',
--                    BuffType = 'ACUREGENERATEBONUS',
--                    Stacks = 'ALWAYS',
--                    Duration = -1,
--                    Affects = {
--                        MaxHealth = {
--                            Add = bp.NewHealth,
--                            Mult = 1.0,
--                        },
--                    },
--                } 
--            end
--            if Buff.HasBuff( self, 'UefACUShield' ) then
--                Buff.RemoveBuff( self, 'UefACUShield' )
--            end  
--            Buff.ApplyBuff(self, 'UefACUShield')
--        elseif enh == 'ShieldRemove' then
--            TWalkingLandUnit.CreateEnhancement(self, enh)
--            self:DestroyShield()
--            self:SetMaintenanceConsumptionInactive()
--            RemoveUnitEnhancement(self, 'ShieldRemove')
--            self:RemoveToggleCap('RULEUTC_ShieldToggle')
--            if Buff.HasBuff( self, 'UefACUShield' ) then
--                Buff.RemoveBuff( self, 'UefACUShield' )
--            end  

--        # Shield Generator # These do not give health
--        elseif enh == 'ShieldGeneratorField' then
--            TWalkingLandUnit.CreateEnhancement(self, enh)
--            self:DestroyShield()
--            ForkThread(function()
--                WaitTicks(1)
--                self:CreateShield(bp)
--                self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
--                self:SetMaintenanceConsumptionActive()
--            end)
--            if not Buffs['UefACUBubble'] then
--               BuffBlueprint {
--                    Name = 'UefACUBubble',
--                    DisplayName = 'UefACUBubble',
--                    BuffType = 'ACUREGENERATEBONUS',
--                    Stacks = 'ALWAYS',
--                    Duration = -1,
--                    Affects = {
--                        MaxHealth = {
--                            Add = bp.NewHealth,
--                            Mult = 1.0,
--                        },
--                    },
--                } 
--            end
--            if Buff.HasBuff( self, 'UefACUBubble' ) then
--                Buff.RemoveBuff( self, 'UefACUBubble' )
--            end  
--            Buff.ApplyBuff(self, 'UefACUBubble')
--        elseif enh == 'ShieldGeneratorFieldRemove' then
--            TWalkingLandUnit.CreateEnhancement(self, enh)
--            self:DestroyShield()
--            self:SetMaintenanceConsumptionInactive()
--            self:RemoveToggleCap('RULEUTC_ShieldToggle')
--            if Buff.HasBuff( self, 'UefACUBubble' ) then
--                Buff.RemoveBuff( self, 'UefACUBubble' )
--            end
--            if Buff.HasBuff( self, 'UefACUShield' ) then # Remove both buffs
--                Buff.RemoveBuff( self, 'UefACUShield' )
--            end  

        # Nano Repair Upgrade # Fixes veterancy bug
        elseif enh =='DamageStablization' then
            TWalkingLandUnit.CreateEnhancement(self, enh)
            local bpRegenRate = bp.NewRegenRate or 0  # added by brute51 - fix for bug SCU regen upgrade doesnt stack with veteran bonus [140]
            if not Buffs['UefACURegenerateBonus'] then
               BuffBlueprint {
                    Name = 'UefACURegenerateBonus',
                    DisplayName = 'UefACURegenerateBonus',
                    BuffType = 'ACUREGENERATEBONUS',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                        Regen = {
                            Add = bpRegenRate,
                            Mult = 1.0,
                        },
                    },
                } 
            end
            if Buff.HasBuff( self, 'UefACURegenerateBonus' ) then
                Buff.RemoveBuff( self, 'UefACURegenerateBonus' )
            end  
            Buff.ApplyBuff(self, 'UefACURegenerateBonus')
        elseif enh =='DamageStablizationRemove' then
            TWalkingLandUnit.CreateEnhancement(self, enh)
            if Buff.HasBuff( self, 'UefACURegenerateBonus' ) then  # added by brute51 - fix for bug SCU regen upgrade doesnt stack with veteran bonus [140]
                Buff.RemoveBuff( self, 'UefACURegenerateBonus' )
            end  

        # Zephyr Cannon
        elseif enh =='HeavyAntiMatterCannon' then
            TWalkingLandUnit.CreateEnhancement(self, enh)
            local wep = self:GetWeaponByLabel('RightZephyr')
            wep:AddDamageMod(bp.ZephyrDamageMod)        
            wep:ChangeMaxRadius(bp.NewMaxRadius or 44)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bp.NewMaxRadius or 44)
            if not Buffs['UefACUZephyr'] then
               BuffBlueprint {
                    Name = 'UefACUZephyr',
                    DisplayName = 'UefACUZephyr',
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
            if Buff.HasBuff( self, 'UefACUZephyr' ) then
                Buff.RemoveBuff( self, 'UefACUZephyr' )
            end  
            Buff.ApplyBuff(self, 'UefACUZephyr')
        elseif enh =='HeavyAntiMatterCannonRemove' then
            TWalkingLandUnit.CreateEnhancement(self, enh)
            local bp = self:GetBlueprint().Enhancements['HeavyAntiMatterCannon']
            if not bp then return end
            local wep = self:GetWeaponByLabel('RightZephyr')
            wep:AddDamageMod(-bp.ZephyrDamageMod)
            local bpDisrupt = self:GetBlueprint().Weapon[1].MaxRadius
            wep:ChangeMaxRadius(bpDisrupt or 22)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bpDisrupt or 22)           
            if Buff.HasBuff( self, 'UefACUZephyr' ) then
                Buff.RemoveBuff( self, 'UefACUZephyr' )
            end   

        # Resource Allocation
        elseif enh == 'ResourceAllocation' then
            TWalkingLandUnit.CreateEnhancement(self, enh)
            local bp = self:GetBlueprint().Enhancements[enh]
            local bpEcon = self:GetBlueprint().Economy
            if not bp then return end
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + bpEcon.ProductionPerSecondMass or 0)
            if not Buffs['UefACUResourceAllocation'] then
               BuffBlueprint {
                    Name = 'UefACUResourceAllocation',
                    DisplayName = 'UefACUResourceAllocation',
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
            if Buff.HasBuff( self, 'UefACUResourceAllocation' ) then
                Buff.RemoveBuff( self, 'UefACUResourceAllocation' )
            end  
            Buff.ApplyBuff(self, 'UefACUResourceAllocation')
        elseif enh == 'ResourceAllocationRemove' then
            TWalkingLandUnit.CreateEnhancement(self, enh)
            local bpEcon = self:GetBlueprint().Economy
            self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)
            if Buff.HasBuff( self, 'UefACUResourceAllocation' ) then
                Buff.RemoveBuff( self, 'UefACUResourceAllocation' )
            end  

        # Tactical Missile and Billy
        elseif enh =='TacticalMissile' then
            TWalkingLandUnit.CreateEnhancement(self, enh)
            self:AddCommandCap('RULEUCC_Tactical')
            self:AddCommandCap('RULEUCC_SiloBuildTactical')
            self:SetWeaponEnabledByLabel('TacMissile', true)
            if not Buffs['UefACUMissile'] then
               BuffBlueprint {
                    Name = 'UefACUMissile',
                    DisplayName = 'UefACUMissile',
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
            if Buff.HasBuff( self, 'UefACUMissile' ) then
                Buff.RemoveBuff( self, 'UefACUMissile' )
            end  
            Buff.ApplyBuff(self, 'UefACUMissile')
        elseif enh =='TacticalNukeMissile' then
            TWalkingLandUnit.CreateEnhancement(self, enh)
            self:RemoveCommandCap('RULEUCC_Tactical')
            self:RemoveCommandCap('RULEUCC_SiloBuildTactical')
            self:AddCommandCap('RULEUCC_Nuke')
            self:AddCommandCap('RULEUCC_SiloBuildNuke')
            self:SetWeaponEnabledByLabel('TacMissile', false)
            self:SetWeaponEnabledByLabel('TacNukeMissile', true)
            local amt = self:GetTacticalSiloAmmoCount()
            self:RemoveTacticalSiloAmmo(amt or 0)
            self:StopSiloBuild()
            if not Buffs['UefACUNukeMissile'] then
               BuffBlueprint {
                    Name = 'UefACUNukeMissile',
                    DisplayName = 'UefACUNukeMissile',
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
            if Buff.HasBuff( self, 'UefACUNukeMissile' ) then
                Buff.RemoveBuff( self, 'UefACUNukeMissile' )
            end  
            Buff.ApplyBuff(self, 'UefACUNukeMissile')
        elseif enh == 'TacticalMissileRemove' or enh == 'TacticalNukeMissileRemove' then
            TWalkingLandUnit.CreateEnhancement(self, enh)
            self:RemoveCommandCap('RULEUCC_Nuke')
            self:RemoveCommandCap('RULEUCC_SiloBuildNuke')
            self:RemoveCommandCap('RULEUCC_Tactical')
            self:RemoveCommandCap('RULEUCC_SiloBuildTactical')
            self:SetWeaponEnabledByLabel('TacMissile', false)
            self:SetWeaponEnabledByLabel('TacNukeMissile', false)
            local amt = self:GetTacticalSiloAmmoCount()
            self:RemoveTacticalSiloAmmo(amt or 0)
            local amt = self:GetNukeSiloAmmoCount()
            self:RemoveNukeSiloAmmo(amt or 0)
            self:StopSiloBuild()
            if Buff.HasBuff( self, 'UefACUMissile' ) then
                Buff.RemoveBuff( self, 'UefACUMissile' )
            end  
            if Buff.HasBuff( self, 'UefACUNukeMissile' ) then
                Buff.RemoveBuff( self, 'UefACUNukeMissile' )
            end  

        else
            oldUEL0001.CreateEnhancement(self, enh)
        end
    end,

}

TypeClass = UEL0001