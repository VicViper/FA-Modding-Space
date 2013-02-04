local CBFP_oldXEA0306 = XEA0306

XEA0306 = Class(CBFP_oldXEA0306) {

# added by brute51 - bug fix for flak ignoring continental shields [122] -----------------
# This fix is about making the continental and its cargo invulnerable as long as it has a shield protecting it.

    ShieldIsOn = true,  # used to keep track of shield status

    OnTransportAttach = function(self, attachBone, unit)
        TAirUnit.OnTransportAttach(self, attachBone, unit)
        unit:SetCanTakeDamage(not ShieldIsOn) # making transported unit invulnerable if transport is too
    end,

    OnTransportDetach = function(self, attachBone, unit)
        unit:SetCanTakeDamage(true) # Units dropped by the transport shouldnt be invulnerable
        TAirUnit.OnTransportDetach(self, attachBone, unit)
    end,

    OnShieldIsUp = function (self)
        TAirUnit.OnShieldIsUp(self)
        self:ShieldStatusChanged(true)
    end,

    OnShieldIsDown = function (self)
        self:ShieldStatusChanged(false)
        TAirUnit.OnShieldIsDown(self)
    end,

    ShieldStatusChanged = function( self, ShieldIsOnline )
        ShieldIsOn = ShieldIsOnline
        self:SetCanTakeDamage(not ShieldIsOn) # turn invulnerability on when our shield is on
        local cargo = self:GetCargo()
        for k, v in cargo do
            v:SetCanTakeDamage(not ShieldIsOn) 
        end
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        if self.GetCargo then
            local cargo = self:GetCargo() # added by brute51  all carried units should be vulnerable again
            for k, v in cargo do
                v:SetCanTakeDamage(true) 
            end
        end
        CBFP_oldXEA0306.OnKilled(self, instigator, type, overkillRatio)
    end,
}

TypeClass = XEA0306