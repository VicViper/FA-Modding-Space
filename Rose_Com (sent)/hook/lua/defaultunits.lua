oldFactoryUnit = FactoryUnit
FactoryUnit = Class(oldFactoryUnit) {
    OnKilled = function(self, instigator, type, overkillRatio)
        StructureUnit.OnKilled(self, instigator, type, overkillRatio)
        if self.UnitBeingBuilt and not self.UnitBeingBuilt:IsDead() and self.UnitBeingBuilt:GetFractionComplete() != 1 then
            self.UnitBeingBuilt:Destroy()
        end
    end,
}

oldLandFactoryUnit = LandFactoryUnit
LandFactoryUnit = Class(oldLandFactoryUnit) {

    # moved from factoryunit to each individual factory type cause it wouldnt work right without overwriting the
    # original file + variables.
    OnKilled = function(self, instigator, type, overkillRatio)
        StructureUnit.OnKilled(self, instigator, type, overkillRatio) # bypassing factoryunit onkilled event
        # added by brute51 - made this IF-statement check whether the unit being built is completed yet. [114]
        if self.UnitBeingBuilt and not self.UnitBeingBuilt:IsDead() and self.UnitBeingBuilt:GetFractionComplete() != 1 then
            self.UnitBeingBuilt:Destroy()
        end
    end,

    # the means to add a rolloff time between unit productions. Can be used to increase the time between the 
    # construction of 2 units. Add to blueprint in general section variable name RolloffDelay and set time
    # in seconds to halt after each produced unit.
    OnStopBuild = function(self, unitBeingBuilt, order )
        local bp = self:GetBlueprint()
        if bp.General.RolloffDelay and bp.General.RolloffDelay > 0 and not self.FactoryBuildFailed then
            self:ForkThread(self.PauseThread, unitBeingBuilt, order)
        else
            oldLandFactoryUnit.OnStopBuild(self, unitBeingBuilt, order)
        end
    end,

    # takes care of the rolloff delay if required in the blueprint
    PauseThread = function(self, unitBeingBuilt, order)
         # adds a pause between unit productions
        self:StopBuildFx()
        local productionpause = self:GetBlueprint().General.RolloffDelay
        if productionpause and productionpause > 0 then
            self:SetBusy(true) 
            self:SetBlockCommandQueue(true) 
            WaitSeconds(productionpause)
            self:SetBusy(false) 
            self:SetBlockCommandQueue(false) 
        end
        oldLandFactoryUnit.OnStopBuild(self, unitBeingBuilt, order)
    end,
}


oldAirFactoryUnit = AirFactoryUnit
AirFactoryUnit = Class(oldAirFactoryUnit) {

    # moved from factoryunit to each individual factory type cause it wouldnt work right without overwriting the
    # original file + variables.
    OnKilled = function(self, instigator, type, overkillRatio)
        StructureUnit.OnKilled(self, instigator, type, overkillRatio) # bypassing factoryunit onkilled event
        # added by brute51 - made this IF-statement check whether the unit being built is completed yet. [114]
        if self.UnitBeingBuilt and not self.UnitBeingBuilt:IsDead() and self.UnitBeingBuilt:GetFractionComplete() != 1 then
            self.UnitBeingBuilt:Destroy()
        end
    end,

    # the means to add a rolloff time between unit productions. Can be used to increase the time between the 
    # construction of 2 units. Add to blueprint in general section variable name RolloffDelay and set time
    # in seconds to halt after each produced unit.
    OnStopBuild = function(self, unitBeingBuilt, order )
        local bp = self:GetBlueprint()
        if bp.General.RolloffDelay and bp.General.RolloffDelay > 0 and not self.FactoryBuildFailed then
            self:ForkThread(self.PauseThread, unitBeingBuilt, order)
        else
            oldAirFactoryUnit.OnStopBuild(self, unitBeingBuilt, order)
        end
    end,

    # takes care of the rolloff delay if required in the blueprint
    PauseThread = function(self, unitBeingBuilt, order)
         # adds a pause between unit productions
        self:StopBuildFx()
        local productionpause = self:GetBlueprint().General.RolloffDelay
        if productionpause and productionpause > 0 then
            self:SetBusy(true) 
            self:SetBlockCommandQueue(true) 
            WaitSeconds(productionpause)
            self:SetBusy(false) 
            self:SetBlockCommandQueue(false) 
        end
        oldAirFactoryUnit.OnStopBuild(self, unitBeingBuilt, order)
    end,
}

oldSeaFactoryUnit = SeaFactoryUnit
SeaFactoryUnit = Class(oldSeaFactoryUnit) {

    # moved from factoryunit to each individual factory type cause it wouldnt work right without overwriting the
    # original file + variables.
    OnKilled = function(self, instigator, type, overkillRatio)
        StructureUnit.OnKilled(self, instigator, type, overkillRatio) # bypassing factoryunit onkilled event
        # added by brute51 - made this IF-statement check whether the unit being built is completed yet. [114]
        if self.UnitBeingBuilt and not self.UnitBeingBuilt:IsDead() and self.UnitBeingBuilt:GetFractionComplete() != 1 then
            self.UnitBeingBuilt:Destroy()
        end
    end,

    # the means to add a rolloff time between unit productions. Can be used to increase the time between the 
    # construction of 2 units. Add to blueprint in general section variable name RolloffDelay and set time
    # in seconds to halt after each produced unit.
    OnStopBuild = function(self, unitBeingBuilt, order )
        local bp = self:GetBlueprint()
        if bp.General.RolloffDelay and bp.General.RolloffDelay > 0 and not self.FactoryBuildFailed then
            self:ForkThread(self.PauseThread, unitBeingBuilt, order)
        else
            oldSeaFactoryUnit.OnStopBuild(self, unitBeingBuilt, order)
        end
    end,

    # takes care of the rolloff delay if required in the blueprint
    PauseThread = function(self, unitBeingBuilt, order)
         # adds a pause between unit productions
        self:StopBuildFx()
        local productionpause = self:GetBlueprint().General.RolloffDelay
        if productionpause and productionpause > 0 then
            self:SetBusy(true) 
            self:SetBlockCommandQueue(true) 
            WaitSeconds(productionpause)
            self:SetBusy(false) 
            self:SetBlockCommandQueue(false) 
        end
        oldSeaFactoryUnit.OnStopBuild(self, unitBeingBuilt, order)
    end,
}

# ///WARNING WORKS BY MAGIC///REQUIRES ADDITIONAL ATTENTION///
oldMassCollectionUnit = MassCollectionUnit
MassCollectionUnit = Class(oldMassCollectionUnit) {
    #FIX BY RAGNAROK_X/COMBINE:  Pausing was handled incorrectly.  Fixed. [100]
    #FIX BY GOWERLY: 
    #If you run out of mass, nothing happens.  If you run out of energy, your mass production from the mex 
    #will decrease as expected.  I've had to go insane to fix this. 
    #I got rid of most of the GPG code where it takes the mass production from the mass consumed, etc. 
    #That screws up your eco balance anyway, by lowering the proportion of mass in / mass out, which sucks. 
    #So I implemented a version where you keep both, giving you a better overall eco balance.  Well, it will 
    #when I find out how to implement it in less of a dark magic hack.  Yay. 
	
    WatchUpgradeConsumption = function(self, massConsumption, massProduction) 
        while true do 
            if not self:IsPaused() then 
                if self:GetResourceConsumed() != 1 then 
                    local aiBrain = self:GetAIBrain() 
                    if aiBrain and aiBrain:GetEconomyStored('ENERGY') <= 1 then 
                        #We are out of energy.  Do nothing.  Something else deals with this, it seems 
                        self:SetProductionPerSecondMass(massProduction) 
                        self:SetConsumptionPerSecondMass(massConsumption) 
                    else 
                        #Insanity by Gowerly, version 1. 
                        #So, if you run out of mass, there's something happening that divides the production by 
                        #how much you're missing mass by.  This sucks, and I Can't find out where this is happening 
                        #If someone knows where this happens, please let me know, so I can fix that instead.  
                        #It would be much less of a hack if I could do that. 
                        #So, I can work out how much I'm out mass by (proportionally) 
                        #and that's how much the mass production is divided by somewhere else 
                        #so if I do the OPPOSITE here, they CANCEL OUT LIKE MATTER AND ANTIMATTER AND I WIN 
                        #Um, so there's a bit when you start upgrading a mex where GetResourceConsumed is 0.  
                        #I have to bypass that, because otherwise you have Aleph-0 mass for a frame. 
                   
                        #Current Issue(s).  Mass goes wild for a second or two when you hit 0, 
                        #but levels out pretty quickly.  I would estimate you end up befitting by about 10 mass. 
                        #Looking at how to fix that, but it won't be easy.  As I end up saying 3 times in here, 
                        #if someone finds out where the mex actually calculates how much mass it's producing, 
                        #I'll give them a cookie.  Somehow. 
                        if self:GetResourceConsumed() != 0 then 
                            self:SetConsumptionPerSecondMass(massConsumption) 
                            self:SetProductionPerSecondMass(massProduction / self:GetResourceConsumed()) 
                            #LOG('Out of mass, setting mex output to ', repr(massProduction / self:GetResourceConsumed()), ' to compensate') 
                        else 
                            #There's no logical way I can deal with you having 0 mass coming in (your ACU produces 1) 
                            #So if you're not playing Assassination and you're out of mass, I can't help you 
                            #PLEASE SOMEONE FIND ME WHERE THE MEX CALCULATES HOW MUCH MASS IT PRODUCES - GOWERLY 
                            self:SetProductionPerSecondMass(0) 
                        end 
                    end                
                else 
                    #Pause fix by R_X and Combine [100]
                    self:SetConsumptionPerSecondMass(massConsumption) 
                    self:SetProductionPerSecondMass(massProduction) 
                end 
            else 
                self:SetProductionPerSecondMass(massProduction) 
            end 
            WaitSeconds(0.2) 
        end 
    end,  	
}