do


local OldShield = Shield
Shield = Class(OldShield) {

    RemoveShield = function(self)
        OldShield.RemoveShield(self)
        self.Owner:OnShieldIsDown()
    end,

    CreateShieldMesh = function(self)
        OldShield.CreateShieldMesh(self)
        self.Owner:OnShieldIsUp()
    end,

    ChargingUp = function(self, curProgress, time)
        self.Owner:OnShieldIsCharging()
        OldShield.ChargingUp(self, curProgress, time)
    end,

    OnState = State {
        Main = function(self)

            # If the shield was turned off; use the recharge time before turning back on
            if self.OffHealth >= 0 then
                self.Owner:SetMaintenanceConsumptionActive()
                self:ChargingUp(0, self.ShieldEnergyDrainRechargeTime)
                
                # If the shield has less than full health, allow the shield to begin regening
                if self:GetHealth() < self:GetMaxHealth() and self.RegenRate > 0 then
                    self.RegenThread = ForkThread(self.RegenStartThread, self)
                    self.Owner.Trash:Add(self.RegenThread)
                end
            end
            
            # We are no longer turned off
            self.OffHealth = -1
            self:UpdateShieldRatio(-1)
            self.Owner:OnShieldEnabled()
            self:CreateShieldMesh()

            WaitSeconds(1.0)

            local aiBrain = self.Owner:GetAIBrain()
            local fraction = self.Owner:GetResourceConsumed()
            local on = true
            local test = false
            
            # Test in here if we have run out of power; if the fraction is ever not 1 we don't have full power
            while on do
                WaitTicks(1)

                self:UpdateShieldRatio(-1)

                fraction = self.Owner:GetResourceConsumed()
 
                # shield not dropping when no energy [127] - bug fix by Ze PilOt
                if fraction != 1 and aiBrain:GetEconomyStored('ENERGY') <= 1 then  
                    if test then
                        on = false
                    else
                        test = true
                    end
                else
                    on = true
                    test = false
                end
            end
            
            # Record the amount of health on the shield here so when the unit tries to turn its shield
            # back on and off it has the amount of health from before.
            #self.OffHealth = self:GetHealth()
            ChangeState(self, self.EnergyDrainRechargeState)
        end,

        IsOn = function(self)
            return true
        end,
    },
}


end