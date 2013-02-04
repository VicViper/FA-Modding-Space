local oldXSS0201 = XSS0201

XSS0201 = Class(oldXSS0201) {

  OnMotionVertEventChange = function( self, new, old )
    SSubUnit.OnMotionVertEventChange(self, new, old)
    if new == 'Top' then
      self:SetWeaponEnabledByLabel('FrontTurret', true)
      self:SetWeaponEnabledByLabel('BackTurret', true)
      #self:SetSpeedMult(1.0)
    elseif new == 'Down' then
      self:SetWeaponEnabledByLabel('FrontTurret', false)
      self:SetWeaponEnabledByLabel('BackTurret', false)
      #self:SetSpeedMult(0.5)
    end
  end,

  OnLayerChange = function(self, new, old)
    SSubUnit.OnLayerChange(self, new, old)
    if new == 'Sub' then
      self:SetSpeedMult(0.8)
    elseif new == 'Water' then
      self:SetSpeedMult(1)
    end
  end,

}

TypeClass = XSS0201