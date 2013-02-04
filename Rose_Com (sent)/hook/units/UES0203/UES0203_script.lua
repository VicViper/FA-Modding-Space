local oldUES0203 = UES0203

UES0203 = Class(oldUES0203) {

  OnLayerChange = function(self, new, old)
    TSubUnit.OnLayerChange(self, new, old)
    if( new == 'Water' ) then
      self:SetSpeedMult(1.5)
    elseif ( new == 'Sub' ) then
      self:SetSpeedMult(1)
    end
  end,

}

TypeClass = UES0203