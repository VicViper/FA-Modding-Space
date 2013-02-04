OldUnit = Unit
Unit = Class(OldUnit) {

    OnPreCreate = function(self)
        OldUnit.OnPreCreate(self)
        self.EventCallbacks = {
                OnKilled = {},
                OnUnitBuilt = {},
                OnStartBuild = {},
                OnReclaimed = {},
                OnStartReclaim = {},
                OnStopReclaim = {},
                OnStopBeingBuilt = {},
                OnHorizontalStartMove = {},
                OnCaptured = {},
                OnCapturedNewUnit = {},
                OnDamaged = {},
                OnStartCapture = {},
                OnStopCapture = {},
                OnFailedCapture = {},
                OnStartBeingCaptured = {},
                OnStopBeingCaptured = {},
                OnFailedBeingCaptured = {},
                OnFailedToBuild = {},
                OnVeteran = {},
                ProjectileDamaged = {},
                SpecialToggleEnableFunction = false,
                SpecialToggleDisableFunction = false,

                # new eventcallbacks. returns only 'self' as argument unless otherwise noted
                OnCreated = {},
                OnTransportAttach = {},
                OnTransportDetach = {},
                OnShieldIsUp = {},
                OnShieldIsDown = {},
                OnShieldIsCharging = {},
                OnPaused = {}, # pause button
                OnUnpaused = {},
                OnProductionPaused = {}, # production button for f.e. mass fab
                OnProductionUnpaused = {},
                OnHealthChanged = {}, # returns self, newHP, oldHP   
                OnTMLAmmoIncrease = {}, # use AddOnMLammoIncreaseCallback function. uses 6 sec interval polling so not accurate
                OnTMLaunched = {},
                OnSMLAmmoIncrease = {}, # use AddOnMLammoIncreaseCallback function. uses 6 sec interval polling so not accurate
                OnSMLaunched = {},
                OnStartRefueling = {},
                OnRunOutOfFuel = {},
                OnGotFuel = {}, # fires when the meter isnt empty anymore.
                OnCmdrUpgradeFinished = {}, # happens when a commander unit is upgraded. doesnt work for factories
                OnCmdrUpgradeStart = {},
                OnTeleportCharging = {}, # returns self, location
                OnTeleported = {}, # returns self, location

                # new in v3
                OnTimedEvent = {}, # returns self, variable (can be antyhing, value is determined when adding event callback)
                OnAttachedToTransport = {}, # returns self, transport unit
                OnDetachedToTransport = {}, # returns self, transport unit
        }
    end,

    OnCreate = function(self)
        OldUnit.OnCreate(self)
        # added by brute51
        self:DisableRestrictedWeapons() # added by brute51 [119]
        local bp = self:GetBlueprint()
        if self.BuffFields and bp.BuffFields then
            for k, field in self.BuffFields do
                if not bp.BuffFields[k] then
                    WARN('BuffField: unknown field definition for buff field '..repr(k))
                    continue
                end
                # we need a different buff field instance for each unit. this takes care of that.
                if not self.BuffFieldInstances then
                    self.BuffFieldInstances = {}
                end
                self.BuffFieldInstances[k] = table.deepcopy(field)
                self.BuffFieldInstances[k]:Create(self, bp.BuffFields[k])
                #self.BuffFields[k]:Create(self, bp.BuffFields[k]) # this doesn't work properly for multiple units of the same type
            end
        end
        self:OnCreated() # event callback
    end,

# added by brute51
    OnCreated = function(self)
        self:DoUnitCallbacks('OnCreated')
    end,
# end

    ##########################################################################################
    ## MISC FUNCTIONS
    ##########################################################################################

# added by brute51 ----------------------------

    # buff field function
    GetBuffFieldByName = function(self, Name)
        if not self.BuffFieldInstances then
            return nil
        end
        for k, field in self.BuffFieldInstances do
            if field:GetBlueprint().Name == Name then
                return field
            end
        end
        return nil
    end,

    # disables some weapons as defined in the unit restriction list, if unit restrictions enabled ofcrouse. [119]
    DisableRestrictedWeapons = function(self)
        if Game.NukesRestricted() then
            self:SetWeaponEnabledByLabel('InainoMissiles',false) # seraphim battleship
            self:SetWeaponEnabledByLabel('NukeMissiles',false) # aeon, uef nuke sub
            self:SetWeaponEnabledByLabel('NukeMissile',false) # cybran nuke sub
        end
        if Game.TacticalMissilesRestricted() then
            # todo (if this is ever used). also edit game.lua
        end
    end,

# end -----------

    OnPaused = function(self)
        OldUnit.OnPaused(self)
        # added by brute51
        self:DoUnitCallbacks('OnPaused')
    end,

    OnUnpaused = function(self)
        OldUnit.OnUnpaused(self)
        # added by brute51
        self:DoUnitCallbacks('OnUnpaused')
    end,

    ##########################################################################################
    ## MISC EVENTS
    ##########################################################################################

    OnCaptured = function(self, captor)
        if self and not self:IsDead() and captor and not captor:IsDead() and self:GetAIBrain() ~= captor:GetAIBrain() then
            if not self:IsCapturable() then
                self:Kill()
                return
            end
            # kill non capturable things on a transport
            if EntityCategoryContains( categories.TRANSPORTATION, self ) then
                local cargo = self:GetCargo()
                for _,v in cargo do
                    if not v:IsDead() and not v:IsCapturable() then
                        v:Kill()
                    end
                end
            end 
            self:DoUnitCallbacks('OnCaptured', captor)
            local newUnitCallbacks = {}
            if self.EventCallbacks.OnCapturedNewUnit then
                newUnitCallbacks = self.EventCallbacks.OnCapturedNewUnit
            end
            local entId = self:GetEntityId()
            local unitEnh = SimUnitEnhancements[entId]
            local captorArmyIndex = captor:GetArmy()
            local captorBrain = false
            
            # For campaigns:
            # We need the brain to ignore army cap when transfering the unit
            # do all necessary steps to set brain to ignore, then un-ignore if necessary the unit cap
            
            if ScenarioInfo.CampaignMode then
                captorBrain = captor:GetAIBrain()
                SetIgnoreArmyUnitCap(captorArmyIndex, true)
            end

             # added by brute51 - bugfix when capturing an enemy it should retain its data [120]
            local newUnits = import('/lua/SimUtils.lua').TransferUnitsOwnership( {self}, captorArmyIndex)
           
            if ScenarioInfo.CampaignMode and not captorBrain.IgnoreArmyCaps then
                SetIgnoreArmyUnitCap(captorArmyIndex, false)
            end

            # the unit transfer function returns a table of units. since we transfered 1 unit the table contains 1
            # unit (the new unit).
            if table.getn(newUnits) != 1 then
                return
            end
            local newUnit
            for k, unit in newUnits do
                newUnit = unit
                break
            end
            
            # no need for this anymore
            #if unitEnh then
            #    for k,v in unitEnh do
            #        newUnit:CreateEnhancement(v)
            #    end
            #end
            # Because the old unit is lost we cannot call a member function for newUnit callbacks
            for k,cb in newUnitCallbacks do
                if cb then
                    cb(newUnit, captor)
                end
            end
        end
    end,

# added by brute51 - timed event, fired every so much seconds.
    TimedEventThread = function(self, interval, passData)
        while not self:IsDead() do
            WaitSeconds(interval)
            if not self:IsDead() then
                self:OnTimedEvent(interval, passData)
            end
        end
    end,

    OnTimedEvent = function(self, interval, passData)
        self:DoOnTimedEventCallbacks(interval, passData)
    end,
# ------------

    ##########################################################################################
    ## ECONOMY
    ##########################################################################################

    OnProductionPaused = function(self)
        OldUnit.OnProductionPaused(self)
        # added by brute51
        self:DoUnitCallbacks('OnProductionPaused')
    end,

    OnProductionUnpaused = function(self)
        OldUnit.OnProductionUnpaused(self)
        # added by brute51
        self:DoUnitCallbacks('OnProductionUnpaused')
    end,

    #
    # Called when we start building a unit, turn on/off, get/lose bonuses, or on
    # any other change that might affect our build rate or resource use.
    #
    UpdateConsumptionValues = function(self)
        local myBlueprint = self:GetBlueprint()

        local energy_rate = 0
        local mass_rate = 0
        local build_rate = 0

        if self.ActiveConsumption then
            local focus = self:GetFocusUnit()
            local time = 1
            local mass = 0
            local energy = 0


            # added by brute51 - to make sure we use the proper consumption values. [132]
            if focus and self.WorkItem and self.WorkProgress < 1 and (focus:IsUnitState('Enhancing') or focus:IsUnitState('Building')) then
                self.WorkItem = focus.WorkItem
            end

            if self.WorkItem then
                time, energy, mass = Game.GetConstructEconomyModel(self, self.WorkItem)
            elseif focus and focus:IsUnitState('SiloBuildingAmmo') then
                # If building silo ammo; create the energy and mass costs based on build rate of the silo
                #     against the build rate of the assisting unit
                time, energy, mass = focus:GetBuildCosts(focus.SiloProjectile)
                
                local siloBuildRate = focus:GetBuildRate() or 1
                energy = (energy / siloBuildRate) * (self:GetBuildRate() or 1)
                mass = (mass / siloBuildRate) * (self:GetBuildRate() or 1)
            elseif focus then
                # bonuses are already factored in by GetBuildCosts
                time, energy, mass = self:GetBuildCosts(focus:GetBlueprint())
            end
            energy = energy * (self.EnergyBuildAdjMod or 1)
            if energy < 1 then
                energy = 1
            end
            mass = mass * (self.MassBuildAdjMod or 1)
            if mass < 1 then
                mass = 1
            end

            energy_rate = energy / time
            mass_rate = mass / time
        end

        if self.MaintenanceConsumption then
            local mai_energy = (self.EnergyMaintenanceConsumptionOverride or myBlueprint.Economy.MaintenanceConsumptionPerSecondEnergy)  or 0
            local mai_mass = myBlueprint.Economy.MaintenanceConsumptionPerSecondMass or 0

            # apply bonuses
            mai_energy = mai_energy * (100 + self.EnergyModifier) * (self.EnergyMaintAdjMod or 1) * 0.01
            mai_mass = mai_mass * (100 + self.MassModifier) * (self.MassMaintAdjMod or 1) * 0.01

            energy_rate = energy_rate + mai_energy
            mass_rate = mass_rate + mai_mass
        end

        # apply minimum rates
        energy_rate = math.max(energy_rate, myBlueprint.Economy.MinConsumptionPerSecondEnergy or 0)
        mass_rate = math.max(mass_rate, myBlueprint.Economy.MinConsumptionPerSecondMass or 0)

        self:SetConsumptionPerSecondEnergy(energy_rate)
        self:SetConsumptionPerSecondMass(mass_rate)

        if (energy_rate > 0) or (mass_rate > 0) then
            self:SetConsumptionActive(true)
        else
            self:SetConsumptionActive(false)
        end
    end,

    ##########################################################################################
    ## DAMAGE
    ##########################################################################################

    OnDamage = function(self, instigator, amount, vector, damageType)
        if self.CanTakeDamage then

# bug fix ---------------------------------
# do a check to see if weapon is allowed to hit unit. Interceptors and ASFs shouldnt be able to damage ground units
# like air staging facilities or fatboys. This bug occurs when a plane docks with the ground unit and an enemy
# ASF or interceptor attacks that plane. Both the docking plane and the dock unit are damaged.
# added by brute51 [124]


        if instigator and IsUnit(instigator) and not instigator:IsDead() then  # to allow crash damage

            local instigatorBP = instigator:GetBlueprint()
            local selfBP = self:GetBlueprint()

            # this is (for now) a fix for pure air units only. if the instigator is not an air unit skip the rest.
            if instigatorBP.Physics.MotionType == 'RULEUMT_Air' and selfBP.Physics.MotionType != 'RULEUMT_Air' then

                # checking the instigator for weapons that are categorized as something else than 'Anti Air'.
                # This is a best guess cause T2 fighter/bombers can still use their anti-air gun to hit the ground unit
                # because they have another weapon thats not Anti Air

                local allowed = false
                local wepCount = instigator:GetWeaponCount()
                for i = 1, wepCount do
                    local wepBP = instigator:GetWeapon(i):GetBlueprint()
                    if wepBP.WeaponCategory != 'Anti Air' and wepBP.WeaponCategory != 'anti air' then
                        allowed = true
                        break
                    end
                end

                if allowed == false then
                    return
                end
            end
        end

# end fix ---------------------------------

            self:DoOnDamagedCallbacks(instigator)
            self:DoTakeDamage(instigator, amount, vector, damageType)
        end
    end,

    DoTakeDamage = function(self, instigator, amount, vector, damageType)
        local preAdjHealth = self:GetHealth()
        self:AdjustHealth(instigator, -amount)
        local health = self:GetHealth()
        if( health < 1 ) then    # was <= 0   fixed by brute51, fixes 0 hp but not destroyed bug (actually in that case hp = 0.001) [128]
            if( damageType == 'Reclaimed' ) then
                self:Destroy()
            else
                local excessDamageRatio = 0.0
                # Calculate the excess damage amount
                local excess = preAdjHealth - amount
                local maxHealth = self:GetMaxHealth()
                if(excess < 0 and maxHealth > 0) then
                    excessDamageRatio = -excess / maxHealth
                end
                self:Kill(instigator, damageType, excessDamageRatio)
            end
        end
        if EntityCategoryContains(categories.COMMAND, self) then
            local aiBrain = self:GetAIBrain()
            if aiBrain then
                aiBrain:OnPlayCommanderUnderAttackVO()
            end
        end
    end,

    OnHealthChanged = function(self, new, old)
        OldUnit.OnHealthChanged(self, new, old)
        #added by brute51
        self:DoOnHealthChangedCallbacks(self, new, old)
    end,

# additional missile events added by brute51. These actually work ---------------------------

    OnCountedMissileLaunch = function(self, missileType) #is called in defaultweapons.lua when a counted missile (tactical, nuke) is launched
        if missileType == 'nuke' then
            self:OnSMLaunched()
        else
            self:OnTMLaunched()
        end
    end,

    OnTMLaunched = function(self)
        self:DoUnitCallbacks('OnTMLaunched')
    end,

    OnSMLaunched = function(self)
        self:DoUnitCallbacks('OnSMLaunched')
    end,

    CheckCountedMissileAmmoIncrease = function(self)
        # polls the ammo count every 6 secs 
        local nukeCount = 0
        local tacticalCount = 0
        local lastTimeNukeCount = 0
        local lastTimeTacticalCount = 0
        while not self:IsDead() do
            nukeCount = self:GetNukeSiloAmmoCount() or 0
            tacticalCount = self:GetTacticalSiloAmmoCount() or 0

            if nukeCount > lastTimeNukeCount then
                self:OnSMLAmmoIncrease()
            end
            if tacticalCount > lastTimeTacticalCount then
                self:OnTMLAmmoIncrease()
            end

            lastTimeNukeCount = nukeCount 
            lastTimeTacticalCount = tacticalCount 
            WaitSeconds(6)
        end
    end,

    OnTMLAmmoIncrease = function(self)
        self:DoUnitCallbacks('OnTMLAmmoIncrease')
    end,

    OnSMLAmmoIncrease = function(self)
        self:DoUnitCallbacks('OnSMLAmmoIncrease')
    end,

# end

    #############################################################################################
    ## CONSTRUCTING - BUILDING - REPAIR
    #############################################################################################

    OnStartBuild = function(self, unitBeingBuilt, order)
        local bp = self:GetBlueprint()
        if order != 'Upgrade' or bp.Display.ShowBuildEffectsDuringUpgrade then
            self:StartBuildingEffects(unitBeingBuilt, order)
        end

        # added by brute51 - to make sure we use the proper consumption values. [132]
        self:UpdateConsumptionValues()

        self:SetActiveConsumptionActive()
        self:DoOnStartBuildCallbacks(unitBeingBuilt)
        self:PlayUnitSound('Construct')
        self:PlayUnitAmbientSound('ConstructLoop')
        if bp.General.UpgradesTo and unitBeingBuilt:GetUnitId() == bp.General.UpgradesTo and order == 'Upgrade' then
            unitBeingBuilt.DisallowCollisions = true
        end
        
        if unitBeingBuilt:GetBlueprint().Physics.FlattenSkirt and not unitBeingBuilt:HasTarmac() then
            if self.TarmacBag and self:HasTarmac() then
                unitBeingBuilt:CreateTarmac(true, true, true, self.TarmacBag.Orientation, self.TarmacBag.CurrentBP )
            else
                unitBeingBuilt:CreateTarmac(true, true, true, false, false)
            end
        end
    end,

    ##########################################################################################
    ## INTEL
    ##########################################################################################

    #Watch the economy.  If this unit doesn't get all it needs, shut off the intel.
    #FIX BY GOWERLY - Intel should only care about energy, let's not die if we run out of mass while upgrading, ok? 
    IntelWatchThread = function(self) 

        local bp = self:GetBlueprint() 

        while self:ShouldWatchIntel() do 

            WaitSeconds(0.5) 

            local hasresources = true 
            local fraction = self:GetResourceConsumed() 

            if fraction < 1 then    #check to see if our aiBrain has energy (don't care about mass) 
                local aiBrain = self:GetAIBrain() 

                if aiBrain then 
                    local energyStored = aiBrain:GetEconomyStored( 'ENERGY' ) 
                    if energyStored <= 1 then 
                        hasresources = false 
                    end 
                end 
            end 
                
            while hasresources == true do 

                WaitSeconds(0.5) 

                fraction = self:GetResourceConsumed() 
                if fraction < 1 then   #check to see if our aiBrain has energy (don't care about mass) 
                    
                    local aiBrain = self:GetAIBrain() 
                    if aiBrain then 
                        local energyStored = aiBrain:GetEconomyStored( 'ENERGY' ) 
                        if energyStored <= 1 then 
                            hasresources = false 
                        end 
                    end 
                end 
            end 

            self:DisableUnitIntel(nil) 
            local recharge = bp.Intel.ReactivateTime or 10 
            # Gowerly: took 0.5 seconds off the wait here, because it waits 0.5 seconds at the top
            # Brute51: dont, what if recharge <= 0.5 ?
            WaitSeconds(recharge) 
            self:EnableUnitIntel(nil) 
        end 
        if self.IntelThread then 
            self.IntelThread = nil 
        end 
    end, 

    ##########################################################################################
    ## GENERIC WORK
    ##########################################################################################


    ##########################################################################################
    ##
    ##########################################################################################

    OnStartRefueling = function(self)
        OldUnit.OnStartRefueling(self)
        #added by brute51
        self:DoUnitCallbacks('OnStartRefueling')
    end,

    OnRunOutOfFuel = function(self)
        OldUnit.OnRunOutOfFuel(self)
        #added by brute51
        self:DoUnitCallbacks('OnRunOutOfFuel')
    end,

    OnGotFuel = function(self)
        OldUnit.OnGotFuel(self)
        #added by brute51
        self:DoUnitCallbacks('OnGotFuel')
    end,

    GetCaptureCosts = function(self, target_entity) #Ianz
        local target_bp = target_entity:GetBlueprint().Economy
        local bp = self:GetBlueprint().Economy

        local time = ((target_bp.BuildTime or 10) / self:GetBuildRate()) / 4 #/2
        local energy = target_bp.BuildCostEnergy / 2 or 100 #/2
        time = time * (self.CaptureTimeMultiplier or 1)

        return time, energy, 0
    end,

    ##########################################################################################
    ## UNIT CALLBACKS
    ##########################################################################################

#added by brute51

    #use addunitcallback and dounitcallback for normal callback handling. these are special cases

    DoOnHealthChangedCallbacks = function(self, newHP, oldHP) # use normal add callback function
        local type = 'OnHealthChanged'
        if ( self.EventCallbacks[type] ) then
            for num,cb in self.EventCallbacks[type] do
                if cb then
                    cb( self, newHP, oldHP )
                end
            end
        end
    end,

    ThreadForAmmoCheckRuns = false,
    AddOnMLammoIncreaseCallback = function(self, fn) # specialized cause this starts the ammo check thread
        if not fn then
            error('*ERROR: Tried to add a callback type - OnTMLAmmoIncrease with a nil function')
            return
        end
        table.insert( self.EventCallbacks.OnTMLAmmoIncrease, fn )
        if not self.ThreadForAmmoCheckRuns then
            self.ThreadForAmmoCheckRuns = true    # so the thread is only started once
            self:ForkThread(self.CheckCountedMissileAmmoIncrease)
        end
    end,

    AddOnTimedEventCallback = function(self, fn, interval, passData) 
        # specialized because this starts a timed even thread (interval = secs between events, passData can be
        # anything, is passed to callback when event is fired)
        if not fn then
            error('*ERROR: Tried to add a callback type - OnTimedEvent with a nil function')
            return
        end
        table.insert( self.EventCallbacks.OnTimedEvent, {fn = fn, interval = interval} )
        self:ForkThread(self.TimedEventThread, interval, passData)
    end,

    DoOnTimedEventCallbacks = function(self, interval, passData)
        local type = 'OnTimedEvent'
        if ( self.EventCallbacks[type] ) then
            for num,cb in self.EventCallbacks[type] do
                if cb and cb['fn'] and cb['interval'] == interval then
                    cb['fn']( self, passData )
                end
            end
        end
    end,

#end

    ##########################################################################################
    ## STATES
    ##########################################################################################

    WorkingState = State {
        Main = function(self)
            #added by brute51
            self:OnCmdrUpgradeStart()

            while self.WorkProgress < 1 and not self:IsDead() do
                WaitSeconds(0.1)
            end
        end,

        OnWorkEnd = function(self, work)
            self:SetActiveConsumptionInactive()
            AddUnitEnhancement(self, work)
            self:CleanupEnhancementEffects(work)
            self:CreateEnhancement(work)
            self.WorkItem = nil
            self.WorkItemBuildCostEnergy = nil
            self.WorkItemBuildCostMass = nil
            self.WorkItemBuildTime = nil
            self:PlayUnitSound('EnhanceEnd')
            self:StopUnitAmbientSound('EnhanceLoop')
            self:EnableDefaultToggleCaps()
            ChangeState(self, self.IdleState)

            #added by brute51
            self:OnCmdrUpgradeFinished()
        end,
    },

    ##########################################################################################
    ## BUFFS
    ##########################################################################################


    ##########################################################################################
    ## VETERANCY
    ##########################################################################################
    

    ##########################################################################################
    ## SHIELDS
    ##########################################################################################

# Added by brute51, fires shield events for units. The other shield events dont run at the correct times (to early)

    OnShieldIsUp = function(self)
        self:DoUnitCallbacks('OnShieldIsUp')
    end,

    OnShieldIsDown = function(self)
        self:DoUnitCallbacks('OnShieldIsDown')
    end,

    OnShieldIsCharging = function(self)
        self:DoUnitCallbacks('OnShieldIsCharging')
    end,

# end

    ##########################################################################################
    ## TRANSPORTING
    ##########################################################################################

    OnTransportAttach = function(self, attachBone, unit)
        OldUnit.OnTransportAttach(self, attachBone, unit)
        # added by brute51
        unit:OnAttachedToTransport(self)
        self:DoUnitCallbacks( 'OnTransportAttach', unit )
    end,

    OnAttachedToTransport = function(self, transport)
        self:DoUnitCallbacks( 'OnAttachedToTransport', transport )
    end,

    OnTransportDetach = function(self, attachBone, unit)
        OldUnit.OnTransportDetach(self, attachBone, unit)
        # added by brute51
        unit:OnDetachedToTransport(self)
        self:DoUnitCallbacks( 'OnTransportDetach', unit )
    end,

    OnDetachedToTransport = function(self, transport)
        self:DoUnitCallbacks( 'OnDetachedToTransport', transport )
    end,

    TransportAnimationThread = function(self,rate) # Added to Remove Transport Leg Bug
        local bp = self:GetBlueprint().Display.TransportAnimation
        
        if rate and rate < 0 and self:GetBlueprint().Display.TransportDropAnimation then
            bp = self:GetBlueprint().Display.TransportDropAnimation
            rate = -rate
        end

        WaitSeconds(.5)
        if bp then
            local animBlock = self:ChooseAnimBlock( bp )
            if animBlock.Animation then
                if not self.TransAnimation then
                    self.TransAnimation = CreateAnimator(self)
                    self.Trash:Add(self.TransAnimation)
                end
                # self.TransAnimation:PlayAnim(animBlock.Animation) 
                # Despite how cool the transport animations can look it causes the units to break their legs upon landing
                rate = rate or 1
                self.TransAnimation:SetRate(rate)
                WaitFor(self.TransAnimation)
            end
        end
    end,

    ##########################################################################################
    ## TELEPORTING
    ##########################################################################################

    InitiateTeleportThread = function(self, teleporter, location, orientation)
        # added by brute51
        self:OnTeleportCharging(location)
        OldUnit.InitiateTeleportThread(self, teleporter, location, orientation)
        # added by brute51
        self:OnTeleported(location)
    end,

# added by brute51

    OnTeleportCharging = function(self, location)
        self:DoUnitCallbacks('OnTeleportCharging', location)
    end,

    OnTeleported = function(self, location)
        self:DoUnitCallbacks('OnTeleported', self, location)
    end,

# end

    PlayTeleportChargeEffects = function(self)
        local army = self:GetArmy()
        local bp = self:GetBlueprint()

        self.TeleportChargeBag = {}
        for k, v in EffectTemplate.GenericTeleportCharge01 do
            local fx = CreateEmitterAtEntity(self,army,v):OffsetEmitter(0, ( bp.TeleportHeight * 2 or bp.Physics.MeshExtentsY or 1) / 2, 0) #added TeleportHeight for commanders
            self.Trash:Add(fx)
            table.insert( self.TeleportChargeBag, fx)
        end
    end,

    PlayTeleportOutEffects = function(self)
        local army = self:GetArmy()
        local bp = self:GetBlueprint()
        local emit = nil
        for k, v in EffectTemplate.GenericTeleportOut01 do
            emit = CreateEmitterAtEntity(self,army,v):OffsetEmitter(0, (bp.TeleportHeight * 2 or bp.Physics.MeshExtentsY or 1) / 2, 0)
        end
    end,


    PlayTeleportInEffects = function(self)
        local army = self:GetArmy()
        local bp = self:GetBlueprint()
        for k, v in EffectTemplate.GenericTeleportIn01 do
            emit = CreateEmitterAtEntity(self,army,v):OffsetEmitter(0, (bp.TeleportHeight * 2 or bp.Physics.MeshExtentsY or 1) / 2, 0)
        end
    end,

    #########################################################################################
    ## ROCKING
    ##########################################################################################

# added by brute51

    #########################################################################################
    ## COMMANDER UPGRADING
    ##########################################################################################
    # Events that happen when a commander unit (ACU or SCU) is upgraded with a new toy

    OnCmdrUpgradeFinished = function(self)
        self:DoUnitCallbacks('OnCmdrUpgradeFinished')
    end,

    OnCmdrUpgradeStart = function(self)
        self:DoUnitCallbacks('OnCmdrUpgradeStart')
    end,

# ----------------

}