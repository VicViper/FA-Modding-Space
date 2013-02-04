local oldUAS0203 = UAS0203

UAS0203 = Class(oldUAS0203) {

  OnLayerChange = function(self, new, old)
    ASubUnit.OnLayerChange(self, new, old)
    if( new == 'Water' ) then
      self:SetSpeedMult(1.5)
    elseif ( new == 'Sub' ) then
      self:SetSpeedMult(1)
    end
  end,

}

TypeClass = UAS0203