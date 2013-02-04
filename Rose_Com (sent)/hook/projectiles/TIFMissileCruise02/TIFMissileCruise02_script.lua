local oldTIFMissileCruise02 = TIFMissileCruise02

TIFMissileCruise02 = Class(oldTIFMissileCruise02) {

  SetTurnRateByDist = function(self)
    local dist = self:GetDistanceToTarget()
    #Get the nuke as close to 90 deg as possible
    if dist > 50 then        
      #Freeze the turn rate as to prevent steep angles at long distance targets
      WaitSeconds(1.25) #1
      self:SetTurnRate(40) #20
    elseif dist > 64 and dist <= 107 then
      # Increase check intervals
      self:SetTurnRate(30)
      WaitSeconds(0.5) #1.5
      self:SetTurnRate(60) #30
    elseif dist > 21 and dist <= 53 then
      # Further increase check intervals
      WaitSeconds(0.3)
      self:SetTurnRate(75) #50
    elseif dist > 0 and dist <= 21 then
      # Further increase check intervals            
      self:SetTurnRate(100)   
      KillThread(self.MoveThread)         
    end
  end,

}
TypeClass = TIFMissileCruise02