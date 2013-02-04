local CBFP_oldAANTorpedoCluster01 = AANTorpedoCluster01

AANTorpedoCluster01 = Class(CBFP_oldAANTorpedoCluster01) {

    OnCreate = function(self)
        ATorpedoCluster.OnCreate(self)
        self.HasImpacted = false
#        self.CountdownLength = self:GetBlueprint().Physics.Lifetime # added by brute51 to fix outrun problem [113]
#        self:ForkThread(self.CountdownExplosion)
        CreateTrail(self, -1, self:GetArmy(), import('/lua/EffectTemplates.lua').ATorpedoPolyTrails01)
    end,

}
TypeClass = AANTorpedoCluster01