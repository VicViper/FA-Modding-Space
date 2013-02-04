local oldURS0304 = URS0304

URS0304 = Class(oldURS0304) {

  OnLayerChange = function(self, new, old)
    CSubUnit.OnLayerChange(self, new, old)
    if( new == 'Water' ) then
      self:SetSpeedMult(1.5)
    elseif ( new == 'Sub' ) then
      self:SetSpeedMult(1)
    end
  end,

}

TypeClass = URS0304