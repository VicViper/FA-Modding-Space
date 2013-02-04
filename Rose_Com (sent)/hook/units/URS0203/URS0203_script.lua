local oldURS0203 = URS0203

URS0203 = Class(oldURS0203) {

  OnLayerChange = function(self, new, old)
    CSubUnit.OnLayerChange(self, new, old)
    if self.WeaponsEnabled then
      if( new == 'Water' ) then
        # Enable Minigun
        self:SetWeaponEnabledByLabel('MainGun', true)
        #self:SetSpeedMult(10)
      elseif ( new == 'UnderWater' ) then
        # Disable Land Minigun
        self:SetWeaponDisableByLabel('MainGun', false)
        #self:SetSpeedMult(10)
      end
    end
    if( new == 'Water' ) then
      self:SetSpeedMult(1.5)
    elseif ( new == 'Sub' ) then
      self:SetSpeedMult(1)
    end
  end,

}

TypeClass = URS0203