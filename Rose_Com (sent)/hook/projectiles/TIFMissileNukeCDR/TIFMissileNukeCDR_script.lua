local oldTIFMissileNukeCDR = TIFMissileNukeCDR

TIFMissileNukeCDR = Class(oldTIFMissileNukeCDR) {

  SetTurnRateByDist = function(self)
    local dist = self:GetDistanceToTarget()
    if dist > 50 then        
      #Freeze the turn rate as to prevent steep angles at long distance targets
      WaitSeconds(1.25) #2
      self:SetTurnRate(20)
    elseif dist > 128 and dist <= 213 then
      # Increase check intervals
      self:SetTurnRate(60) #30
      WaitSeconds(0.5)
      self:SetTurnRate(60) #30
    elseif dist > 43 and dist <= 107 then
      # Further increase check intervals
      WaitSeconds(0.3)
      self:SetTurnRate(75)
    elseif dist > 0 and dist <= 43 then
      # Further increase check intervals            
      self:SetTurnRate(200)   
      KillThread(self.MoveThread)         
    end
  end,

}
TypeClass = TIFMissileNukeCDR