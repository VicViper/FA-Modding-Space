local CBFP_oldCIFEMPFluxWarhead01 = CIFEMPFluxWarhead01

CIFEMPFluxWarhead01 = Class(CIFEMPFluxWarhead01) {
    OnImpact = function(self, TargetType, TargetEntity)
        if not TargetEntity or not EntityCategoryContains(categories.PROJECTILE, TargetEntity) then
            # Play the explosion sound
            local myBlueprint = self:GetBlueprint()
            if myBlueprint.Audio.Explosion then
                self:PlaySound(myBlueprint.Audio.Explosion)
            end

            # bug fix by gowerly, should fix cybran nuke having hard time against shields [106]
            # removed the warping so it doesn't explode 20 units above the ground.
            nukeProjectile = self:CreateProjectile('/projectiles/CIFEMPFluxWarhead02/CIFEMPFluxWarhead02_proj.bp', 0, 0, 0, nil, nil, nil):SetCollision(false)
            nukeProjectile:PassData(self.Data)
        end
        CEMPFluxWarheadProjectile.OnImpact(self, TargetType, TargetEntity)
    end,
}

TypeClass = CIFEMPFluxWarhead01
