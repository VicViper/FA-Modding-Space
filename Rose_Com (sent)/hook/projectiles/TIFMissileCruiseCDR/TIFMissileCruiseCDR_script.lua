local oldTIFMissileCruiseCDR = TIFMissileCruiseCDR

TIFMissileCruiseCDR = Class(oldTIFMissileCruiseCDR) {

  SetTurnRateByDist = function(self)
    local dist = self:GetDistanceToTarget()
    #Get the nuke as close to 90 deg as possible
    if dist > 50 then        
      #Freeze the turn rate as to prevent steep angles at long distance targets
      WaitSeconds(1.25) #2
      self:SetTurnRate(20) #10
    elseif dist > 30 and dist <= 50 then
      # Increase check intervals
      self:SetTurnRate(25) #12
      WaitSeconds(0.5)
      self:SetTurnRate(25) #12
    elseif dist > 10 and dist <= 25 then
      # Further increase check intervals
      WaitSeconds(0.3)
      self:SetTurnRate(75) #50
    elseif dist > 0 and dist <= 10 then
      # Further increase check intervals            
      self:SetTurnRate(100)
      KillThread(self.MoveThread)         
    end
  end,

}
TypeClass = TIFMissileCruiseCDR