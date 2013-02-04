local oldXAS0204 = XAS0204

XAS0204 = Class(oldXAS0204) {

  OnLayerChange = function(self, new, old)
    ASubUnit.OnLayerChange(self, new, old)
    if( new == 'Water' ) then
      self:SetSpeedMult(1)
    elseif ( new == 'Sub' ) then
      self:SetSpeedMult(0.8)
    end
  end,

}

TypeClass = XAS0204