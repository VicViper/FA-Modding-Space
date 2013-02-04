local oldXSS0304 = XSS0304

XSS0304 = Class(oldXSS0304) {

  OnLayerChange = function( self, new, old )
    SSubUnit.OnLayerChange(self, new, old)
    if new == 'Water' then
      ChangeState( self, self.OpenState )
      self:SetSpeedMult(1)
    elseif new == 'Sub' then
      ChangeState( self, self.ClosedState )
      self:SetSpeedMult(0.75)
    end
  end,

}

TypeClass = XSS0304