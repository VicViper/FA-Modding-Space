local oldURL0306 = URL0306

URL0306 = Class(oldURL0306) {

  IntelEffects = {
    {
      Bones = {
        'AttachPoint',
      },
      Offset = {
        0,
        0, #0.3
        0,
      },
      Scale = 0.2,
      Type = 'Jammer01',
    },
  },

  OnIntelEnabled = function(self)
    CLandUnit.OnIntelEnabled(self)
    if not self.IntelEffectsBag then
      self.IntelEffectsBag = {}
      self.CreateTerrainTypeEffects( self, self.IntelEffects, 'FXIdle',  self:GetCurrentLayer(), nil, self.IntelEffectsBag )
    end
  end,

  OnIntelDisabled = function(self)
    CLandUnit.OnIntelDisabled(self)
    if self.IntelEffectsBag then
      EffectUtil.CleanupEffectBag(self,'IntelEffectsBag')
      self.IntelEffectsBag = nil
    end
  end,

}

TypeClass = URL0306