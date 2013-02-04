local oldUAS0304 = UAS0304

UAS0304 = Class(oldUAS0304) {

  OnLayerChange = function(self, new, old)
    ASubUnit.OnLayerChange(self, new, old)
    if( new == 'Water' ) then
      self:SetSpeedMult(1.5)
    elseif ( new == 'Sub' ) then
      self:SetSpeedMult(1)
    end
  end,

}

TypeClass = UAS0304