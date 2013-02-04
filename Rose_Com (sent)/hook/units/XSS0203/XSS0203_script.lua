local oldXSS0203 = XSS0203

XSS0203 = Class(oldXSS0203) {

  OnLayerChange = function(self, new, old)
    SSubUnit.OnLayerChange(self, new, old)
    if new == 'Sub' then
      ChangeState( self, self.CannonDisabled )
      self:SetSpeedMult(1)
    elseif new == 'Water' then
      ChangeState( self, self.CannonEnabled )
      self:SetSpeedMult(1.5)
    end
  end,

}

TypeClass = XSS0203