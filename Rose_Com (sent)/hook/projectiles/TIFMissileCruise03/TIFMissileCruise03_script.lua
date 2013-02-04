local oldTIFMissileCruise03 = TIFMissileCruise03

TIFMissileCruise03 = Class(oldTIFMissileCruise03) {

    SetTurnRateByDist = function(self)
        local dist = self:GetDistanceToTarget()
        if dist > self.Distance then
            self:SetTurnRate(75)
            WaitSeconds(3)
            self:SetTurnRate(8)
            self.Distance = self:GetDistanceToTarget()
        end
        if dist > 50 then        
            #Freeze the turn rate as to prevent steep angles at long distance targets
            WaitSeconds(1.25) #2
            self:SetTurnRate(20) #10
        elseif dist > 30 and dist <= 50 then
	    self:SetTurnRate(25) #12
	    WaitSeconds(0.5) #1.5
            self:SetTurnRate(25) #12
        elseif dist > 10 and dist <= 25 then
            WaitSeconds(0.15) #0.3
            self:SetTurnRate(50)
        elseif dist > 0 and dist <= 10 then       
            self:SetTurnRate(100)   
            KillThread(self.MoveThread)         
        end
    end,

}
TypeClass = TIFMissileCruise03