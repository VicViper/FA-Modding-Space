local oldCAAMissileNanite02 = CAAMissileNanite02

CAAMissileNanite02 = Class(oldCAAMissileNanite02) {

    UpdateThread = function(self)
        WaitSeconds(1.5)
        if not self:BeenDestroyed() then # added by brute51
            self:SetMaxSpeed(80)
            self:SetAcceleration(10 + Random() * 8)
            self:ChangeMaxZigZag(0.5)
            self:ChangeZigZagFrequency(2)
        end
    end,
}

TypeClass = CAAMissileNanite02

