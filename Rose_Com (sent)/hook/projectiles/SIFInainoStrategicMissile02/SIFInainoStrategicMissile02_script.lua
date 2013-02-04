local CBFP_oldSIFInainoStrategicMissile02 = SIFInainoStrategicMissile02

SIFInainoStrategicMissile02 = Class(CBFP_oldSIFInainoStrategicMissile02) {

    MovementThread = function(self) # added by brute51. copied static nuke launcher function here. fixes very high altitude nuke missile [115]
        local army = self:GetArmy()
        local launcher = self:GetLauncher()
        self.CreateEffects( self, self.InitialEffects, army, 1 )
        self:TrackTarget(false)
        WaitSeconds(2.5)
        self:SetCollision(true)
        self.CreateEffects( self, self.LaunchEffects, army, 1 )
        WaitSeconds(2.5)
        self:SetTurnRate(5)
        self.CreateEffects( self, self.ThrustEffects, army, 3 )
        WaitSeconds(2.5)
        self:TrackTarget(true)
        self:SetDestroyOnWater(true)
        self:SetTurnRate(50)
        WaitSeconds(2)
        self:SetBallisticAcceleration(10)
        while not self:BeenDestroyed() do
            self:SetTurnRateByDist()
            WaitSeconds(0.5)
        end
    end,

    SetTurnRateByDist = function(self) # added by brute51. copied static nuke launcher function here. fixes very high altitude nuke missile [115]
        local dist = self:GetDistanceToTarget()
        #Get the nuke as close to 90 deg as possible
        if dist > 150 then        
            #Freeze the turn rate as to prevent steep angles at long distance targets
            self:SetTurnRate(0)
        elseif dist > 75 and dist <= 150 then
						# Increase check intervals
            self.WaitTime = 0.3
        elseif dist > 32 and dist <= 75 then
						# Further increase check intervals
            self.WaitTime = 0.1
        elseif dist < 32 then
						# Turn the missile down
            self:SetTurnRate(80)
        end
    end,
}

TypeClass = SIFInainoStrategicMissile02
