local AIUtils = import('/lua/ai/aiutilities.lua')
local Buff = import('/lua/sim/Buff.lua')
local BuffDefinitions = import('/lua/sim/BuffDefinitions.lua')
#local Entity = import('/lua/sim/Entity.lua').Entity
#local Weapon = import('/lua/sim/Weapon.lua').Weapon
local Game = import('/lua/game.lua')
local BuffFieldBlueprints = import('/mods/Ianz_Mod/hook/lua/BuffFieldDefinitions.lua').BuffFieldBlueprints

# READ for modders - buff fields.txt BEFORE USING THIS!!

# Ideas for future versions:
# - effects for affected units
# - resource consumption
# - possibility to affect enemy and allied units aswell



DefaultBuffField = Class() {

    # change these in an inheriting class if you want
    FieldVisualEmitter = '',   # the FX on the unit that carries the buff field

    # ----------------------------------------------------------------------------------------------------------
    # EVENTS

    OnCreated = function(self)    
        # fires when the field is initalised
    end,

    OnEnabled = function(self)
        # fires when the field begins to work
    end,

    OnDisabled = function(self)
        # fires when the field stops working
    end,

    OnNewUnitsInFieldCheck = function(self)
        # fires when another check is done to find new units in range that aren't yet under the influence of the
        # field. This happens approximately every 4.9 seconds.
    end,

    OnPreUnitEntersField = function(self, unit)
        # fired before unit receives the buffs, but it will. Any data returned by this event function is used as an
        # argument for OnUnitEntersField, OnPreUnitLeavesField and OnUnitLeavesField
    end,

    OnUnitEntersField = function(self, unit, OnPreUnitEntersFieldData)
        # fired when a new unit begins being affected by the field. the unit argument contains the newly affected 
        # unit. The OnPreUnitEntersFieldData argument is the data (if any) returned by OnPreUnitEntersField. Any
        # data returned by this event function is used as an argument for OnPreUnitLeavesField and
        # OnUnitLeavesField
    end,

    OnPreUnitLeavesField = function(self, unit, OnPreUnitEntersFieldData, OnUnitEntersFieldData)
        # fired when a unit leaves the field, just before the field buffs are removed. The OnPreUnitEntersFieldData
        # argument is the data (if any) returned by OnPreUnitEntersField and the OnUnitEntersFieldData argument
        # is the data (if any) returned by OnUnitEntersField. Any data returned by this event function is used as 
        # an argument for OnUnitLeavesField.
    end,

    OnUnitLeavesField = function(self, unit, OnPreUnitEntersFieldData, OnUnitEntersFieldData, OnPreUnitLeavesField)
        # fired after a unit left the field and the field buffs have been removed. the last 3 arguments contain
        # data returned by the other events.
    end,

    # ----------------------------------------------------------------------------------------------------------
    # ACTUAL CODE (dont change anything)

    Owner = false,
    Enabled = false,
    CreateFuncRan = false,
    ThreadHandle = false,
    Emitter = false,
    Blueprint = {},
    WasEnabledBeforeTransporting = false,
    DisabledForTransporting = false,

    Create = function(self, Owner, BuffFieldName)
        #LOG('Buffield: ['..repr(BuffFieldName)..']create')
        if self.CreateFuncRan then
            WARN('BuffField: ['..repr(BuffFieldName)..'] this field is already created!')
            return
        end
        self.Owner = Owner
        self:LoadBlueprint(BuffFieldName)
        local bp = self:GetBlueprint()
        if not bp then
            return
        end
        # verifying blueprint
        if not bp.Name or type(bp.Name) != 'string' or bp.Name == '' then
            WARN('BuffField: Invalid name or name not set!')
            return
        end
        if type(bp.AffectsUnitCategories) == 'string' then
            self.Blueprint.AffectsUnitCategories = ParseEntityCategory(bp.AffectsUnitCategories)
        end
        if type(bp.Buffs) == 'string' then
            self.Blueprint.Buffs = { bp.Buffs }
        end
        if table.getn(self.Blueprint.Buffs) < 1 then
            WARN('BuffField: [..repr(bp.Name)..] no buffs specified!')
            return
        end
        for k, v in self.Blueprint.Buffs do
            if not Buffs[v] then
                WARN('BuffField: [..repr(bp.Name)..] the field uses a buff that doesn\'t exist! '..repr(v))
                return
            end
        end
        if not bp.Radius or bp.Radius <= 0 then
            WARN('BuffField: [..repr(bp.Name)..] Invalid radius or radius not set!')
            return
        end
        # wrapping it up
        if bp.DisableInTransport then
            Owner:AddUnitCallback(self.DisableInTransport, 'OnAttachedToTransport')
            Owner:AddUnitCallback(self.EnableOutTransport, 'OnDetachedToTransport')
        end
        self.CreateFuncRan = true
        self:OnCreated()
        if not bp.EnabledOnCreate then
            return
        end
        #LOG('BuffField: [..repr(bp.Name)..] auto-enabling buff field')
        self:Enable()
    end,

    LoadBlueprint = function(self, BuffFieldName)
        #LOG('Buffield: ['..repr(BuffFieldName)..'] load bp')
        for k, v in BuffFieldBlueprints do
            if v.Name == BuffFieldName then
                self.Blueprint = table.deepcopy(v)
                return
            end
        end
        WARN('BuffField: Couldn\'t find blueprint with name '..repr(BuffFieldName))
        return
    end,

    GetBlueprint = function(self)
        return self.Blueprint or nil
    end,

    Enable = function(self)
        #LOG('Buffield: ['..repr(self.Blueprint.Name)..'] enable')
        if not self.CreateFuncRan then
            WARN('BuffField: ['..repr(self.Blueprint.Name)..'] Cannot be enabled yet! Run Create() first')
        elseif not self:IsEnabled() then
            self.ThreadHandle = self.Owner:ForkThread(self.FieldThread, self)
            self.Enabled = true
            # show field FX
            if self.FieldVisualEmitter and type(self.FieldVisualEmitter) == 'string' and self.FieldVisualEmitter != '' then
                if not self.Owner.BuffFieldEffectsBag then
                    self.Owner.BuffFieldEffectsBag = {}
                end
                self.Emitter = CreateAttachedEmitter(self.Owner, 0, self.Owner:GetArmy(), self.FieldVisualEmitter)
                table.insert( self.Owner.BuffFieldEffectsBag, self.Emitter)
            end
            self:OnEnabled()
        end
    end,

    Disable = function(self)
        #LOG('Buffield: ['..repr(self.Blueprint.Name)..'] disable')
        if self:IsEnabled() then
            KillThread(self.ThreadHandle)
            self.Enabled = false
            if self.Emitter and self.Owner.BuffFieldEffectsBag then    # remove field FX
                for k, v in self.Owner.BuffFieldEffectsBag do
                    if v == self.Emitter then
                        v:Destroy()
                        table.remove(self.Owner.BuffFieldEffectsBag, k)
                        break
                    end
                end
            end
            self:OnDisabled()
        end
    end,

    IsEnabled = function(self)
        return self.Enabled or false
    end,

    GetBuffs = function(self)
        return self:GetBlueprint().Buffs or nil
    end,

    # applies the buff to any unit in range each 5 seconds
    # Owner is the unit that carries the field. This is a bit weird to have it like this but its the result of
    # of the forkthread in the enable function.
    FieldThread = function(Owner, self)
        #LOG('Buffield: ['..repr(self.Blueprint.Name)..'] FieldThread')
        local bp = self:GetBlueprint()
        while self:IsEnabled() and not Owner:IsDead() do
            #LOG('BuffField: ['..repr(self.Blueprint.Name)..'] check new units')
            # limiting the field to own units on purpose
            local units = AIUtils.GetOwnUnitsAroundPoint(Owner:GetAIBrain(), bp.AffectsUnitCategories, Owner:GetPosition(), bp.Radius)
            for k, unit in units do
                if unit == Owner and not bp.AffectsSelf then
                   continue
                end
                if not unit.HasBuffFieldThreadHandle[bp.Name] then
                    if type(unit.HasBuffFieldThreadHandle) != 'table' then
                        unit.HasBuffFieldThreadHandle = {}
                        unit.BuffFieldThreadHandle = {}
                    end
                    #LOG('BuffField: ['..repr(self.Blueprint.Name)..'] new unit')
                    unit.BuffFieldThreadHandle[bp.Name] = unit:ForkThread(self.UnitBuffFieldThread, Owner, self)
                    unit.HasBuffFieldThreadHandle[bp.Name] = true
                end
            end
            self:OnNewUnitsInFieldCheck()
            WaitSeconds(4.9) # this should be anything but 5 (of the other wait) to help spread the cpu load
        end
    end,

    # ============================================================================================

    # this will be run on the units affected by the field so self means the unit that is affected by the field
    UnitBuffFieldThread = function(self, instigator, BuffField)
        local bp = BuffField:GetBlueprint()
        local PreEnterData = BuffField:OnPreUnitEntersField(self)
        for _, buff in bp.Buffs do
            Buff.ApplyBuff(self, buff)
        end
        local EnterData = BuffField:OnUnitEntersField(self, PreEnterData)
        while not self:IsDead() and not instigator:IsDead() and BuffField:IsEnabled() do
            #LOG('BuffField: ['..repr(bp.Name)..'] unit thread check distance')
            dist = VDist3( self:GetPosition(), instigator:GetPosition() )
            if dist > bp.Radius then
                break # ideally we should check for another nearby buff field emitting unit but it doesn't really matter (no more than 5 sec anyway)
            end
            WaitSeconds(5)
        end
        local PreLeaveData = BuffField:OnPreUnitLeavesField(self, PreEnterData, EnterData)
        for _, buff in bp.Buffs do
            if Buff.HasBuff(self, buff) then
                Buff.RemoveBuff( self, buff)
            end
        end
        BuffField:OnUnitLeavesField(self, PreEnterData, EnterData, PreLeaveData)
        self.HasBuffFieldThreadHandle[bp.Name] = false
        #LOG('BuffField: ['..repr(bp.Name)..'] end unit thread')
    end,

    # ============================================================================================

    # these 2 are a bit weird. they'r supposed to disable the enabled fields when on a transport and re-enable the
    # fields that were enabled and leave the disabled fields off.
    DisableInTransport = function(Owner, Transport)
        for k, field in Owner.BuffFields do
            if not field.DisabledForTransporting then
                local Enabled = field:IsEnabled()
                field.WasEnabledBeforeTransporting = Enabled
                if Enabled then
                    field:Disable()
                end
                field.DisabledForTransporting = true # to make sure the above is done once even if we have 2 fields or more
            end
        end
    end,

    EnableOutTransport = function(Owner, Transport)
        for k, field in Owner.BuffFields do
            if field.DisabledForTransporting then
                if field.WasEnabledBeforeTransporting then
                    field:Enable()
                end
                field.DisabledForTransporting = false
            end
        end
    end,
}