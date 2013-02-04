local oldUES0202 = UES0202

UES0202 = Class(oldUES0202) {

    Weapons = {
        FrontTurret01 = Class(TDFGaussCannonWeapon) {},
        BackTurret02 = Class(TSAMLauncher) {
            FxMuzzleFlash = EffectTemplate.TAAMissileLaunchNoBackSmoke,
        },
        PhalanxGun01 = Class(TAMPhalanxWeapon) {
            PlayFxWeaponUnpackSequence = function(self)
                if not self.SpinManip then 
                    self.SpinManip = CreateRotator(self.unit, 'Center_Turret_Barrel', 'z', nil, 270, 180, 60)
                    self.SpinManip:SetPrecedence(10)
                    self.unit.Trash:Add(self.SpinManip)
                end
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(270)
                end
                TAMPhalanxWeapon.PlayFxWeaponUnpackSequence(self)
            end,

            PlayFxWeaponPackSequence = function(self)
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(0)
                end
                TAMPhalanxWeapon.PlayFxWeaponPackSequence(self)
            end,
        },
        
        CruiseMissile = Class(TIFCruiseMissileLauncher) {
            CurrentRack = 1,

            # added by brute51 - bug fix / workaround for cruiser not firing both weapons simultaniously [133]
            # removed old commented out code, added createcruisemissile thread and adapted the function below.
            # there seems code in the engine that upon firing a weapon disables all other weapons. Since the cruiser
            # uses a salvo and a fairly large delay between shots the total waiting time is a lot and during that
            # time the cruiser cannot use its other weapons. changed this so the salvo for the engine is 1 and so
            # it doesnt have to wait to do another shot. Added another variable in the BP override that tells us
            # the number of missiles. using that instead.
            CreateProjectileAtMuzzle = function(self, muzzle)
                local bp = self:GetBlueprint()
                local SalvoSize = bp.MuzzleSalvoSizeNonGreedy or 4
                local SalvoDelay = bp.MuzzleSalvoDelayNonGreedy or 1.5
                local k = 0
                while k < SalvoSize do
                    muzzle = bp.RackBones[self.CurrentRack].MuzzleBones[1]
                    self:ForkThread(self.CreateCruiseMissile, muzzle, (SalvoDelay * k))
                    if self.CurrentRack >= 8 then
                        self.CurrentRack = 1
                    else
                        self.CurrentRack = self.CurrentRack + 1
                    end
                    k = k + 1
                end
            end,

            CreateCruiseMissile = function(self, muzzle, delay)
                WaitSeconds(delay)
                if self.unit:IsDead() then return end
                TIFCruiseMissileLauncher.PlayFxMuzzleSequence(self, muzzle)
                WaitSeconds(1)
                if self.unit:IsDead() then return end
                TIFCruiseMissileLauncher.CreateProjectileAtMuzzle(self, muzzle)
            end,
        },
    },
}

TypeClass = UES0202
