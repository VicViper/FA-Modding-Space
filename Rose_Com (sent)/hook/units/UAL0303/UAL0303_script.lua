local oldUAL0303 = UAL0303

UAL0303 = Class(oldUAL0303) {    

# idea(deadMG & Ze_PilOt) modified(brute51)

    OnShieldIsUp = function (self)
        self:SetCanTakeDamage(false)
        oldUAL0303.OnShieldIsUp(self)
    end,

    OnShieldIsDown = function (self)
        self:SetCanTakeDamage(true) 
        oldUAL0303.OnShieldIsDown(self)
    end,
}

TypeClass = UAL0303  