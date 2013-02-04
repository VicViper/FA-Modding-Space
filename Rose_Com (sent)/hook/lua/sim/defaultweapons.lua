oldDefaultBeamWeapon = DefaultBeamWeapon
DefaultBeamWeapon = Class(oldDefaultBeamWeapon) {
    BeamLifetimeThread = function(self, beam, lifeTime) 
        WaitSeconds(lifeTime)
        WaitTicks(1) #brute51, beam weapon DPS bug [101]
        self:PlayFxBeamEnd(beam) 
    end,
}

# ///Inspect what this bit of code does///
oldDefaultProjectileWeapon = DefaultProjectileWeapon
DefaultProjectileWeapon = Class(oldDefaultProjectileWeapon) {		

    RackSalvoFiringState = State {
        WeaponWantEnabled = true,
        WeaponAimWantEnabled = true,

        RenderClockThread = function(self, rof)
            local clockTime = rof
            local totalTime = clockTime
            while clockTime > 0.0 and 
                  not self:BeenDestroyed() and 
                  not self.unit:IsDead() do
                self.unit:SetWorkProgress( 1 - clockTime / totalTime )
                clockTime = clockTime - 0.1
                WaitSeconds(0.1)                            
            end
        end,
    
        Main = function(self)
            self.unit:SetBusy(true)
            local bp = self:GetBlueprint()
            #LOG("Weapon " .. bp.DisplayName .. " entered RackSalvoFiringState.")
            self:DestroyRecoilManips()
            local numRackFiring = self.CurrentRackSalvoNumber
            #This is done to make sure that when racks fire together, they fire together.
            if bp.RackFireTogether == true then
                numRackFiring = table.getsize(bp.RackBones)
            end

            # Fork timer counter thread carefully....
            if not self:BeenDestroyed() and 
               not self.unit:IsDead() then
                if bp.RenderFireClock and bp.RateOfFire > 0 then
                    local rof = 1 / bp.RateOfFire                
                    self:ForkThread(self.RenderClockThread, rof)                
                end
            end

            #Most of the time this will only run once, the only time it doesn't is when racks fire together.
            while self.CurrentRackSalvoNumber <= numRackFiring and not self.HaltFireOrdered do
                local rackInfo = bp.RackBones[self.CurrentRackSalvoNumber]
                local numMuzzlesFiring = bp.MuzzleSalvoSize
                if bp.MuzzleSalvoDelay == 0 then
                    numMuzzlesFiring = table.getn(rackInfo.MuzzleBones)
                end
                local muzzleIndex = 1
                for i = 1, numMuzzlesFiring do
                    if self.HaltFireOrdered then
                        continue
                    end
                    local muzzle = rackInfo.MuzzleBones[muzzleIndex]
                    if rackInfo.HideMuzzle == true then
                        self.unit:ShowBone(muzzle, true)
                    end
                    if bp.MuzzleChargeDelay and bp.MuzzleChargeDelay > 0 then
                        if bp.Audio.MuzzleChargeStart then
                            self:PlaySound(bp.Audio.MuzzleChargeStart)
                        end
                        self:PlayFxMuzzleChargeSequence(muzzle)
                        if bp.NotExclusive then
                            self.unit:SetBusy(false)
                        end
                        WaitSeconds(bp.MuzzleChargeDelay)
                        if bp.NotExclusive then
                            self.unit:SetBusy(true)
                        end
                    end
                    self:PlayFxMuzzleSequence(muzzle)                    
                    if rackInfo.HideMuzzle == true then
                        self.unit:HideBone(muzzle, true)
                    end
                    if self.HaltFireOrdered then
                        continue
                    end
                    self:CreateProjectileAtMuzzle(muzzle)
                    #Decrement the ammo if they are a counted projectile
                    if bp.CountedProjectile == true then
                        if bp.NukeWeapon == true then
                            self.unit:NukeCreatedAtUnit()
                            self.unit:RemoveNukeSiloAmmo(1)

                            # added by brute51
                            self.unit:OnCountedMissileLaunch('nuke')
                        else
                            self.unit:RemoveTacticalSiloAmmo(1)

                            # added by brute51
                            self.unit:OnCountedMissileLaunch('tactical')
                        end
                    end
                    muzzleIndex = muzzleIndex + 1
                    if muzzleIndex > table.getn(rackInfo.MuzzleBones) then
                        muzzleIndex = 1
                    end
                    if bp.MuzzleSalvoDelay > 0 then
                        if bp.NotExclusive then
                            self.unit:SetBusy(false)
                        end
                        WaitSeconds(bp.MuzzleSalvoDelay)
                        if bp.NotExclusive then
                            self.unit:SetBusy(true)
                        end         
                    end
                end

                self:PlayFxRackReloadSequence()
                if self.CurrentRackSalvoNumber <= table.getn(bp.RackBones) then
                    self.CurrentRackSalvoNumber = self.CurrentRackSalvoNumber + 1
                end
            end

            self:DoOnFireBuffs()

            self.FirstShot = false

            self:StartEconomyDrain()

            self:OnWeaponFired()

            # We can fire again after reaching here
            self.HaltFireOrdered = false

            if self.CurrentRackSalvoNumber > table.getn(bp.RackBones) then
                self.CurrentRackSalvoNumber = 1
                if bp.RackSalvoReloadTime > 0 then
                    ChangeState(self, self.RackSalvoReloadState)
                elseif bp.RackSalvoChargeTime > 0 then
                    ChangeState(self, self.IdleState)
                elseif bp.CountedProjectile == true and bp.WeaponUnpacks == true then
                    ChangeState(self, self.WeaponPackingState)
                elseif bp.CountedProjectile == true and not bp.WeaponUnpacks then
                    ChangeState(self, self.IdleState)
                else
                    ChangeState(self, self.RackSalvoFireReadyState)
                end
            elseif bp.CountedProjectile == true and not bp.WeaponUnpacks then
                ChangeState(self, self.IdleState)
            elseif bp.CountedProjectile == true and bp.WeaponUnpacks == true then
                ChangeState(self, self.WeaponPackingState)
            else
                ChangeState(self, self.RackSalvoFireReadyState)
            end
        end,

        OnLostTarget = function(self)
            Weapon.OnLostTarget(self)
            local bp = self:GetBlueprint()
            if bp.WeaponUnpacks == true then
                ChangeState(self, self.WeaponPackingState)
            end
        end,

        # Set a bool so we won't fire if the target reticle is moved
        OnHaltFire = function(self)
            self.HaltFireOrdered = true
        end,
    },
}