local oldXRS0204 = XRS0204

XRS0204 = Class(oldXRS0204) {

  OnLayerChange = function(self, new, old)
    CSubUnit.OnLayerChange(self, new, old)
    if( new == 'Water' ) then
      self:SetSpeedMult(1)
    elseif ( new == 'Sub' ) then
      self:SetSpeedMult(0.8)
    end
  end,

}

TypeClass = XRS0204