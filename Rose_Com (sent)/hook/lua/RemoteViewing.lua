local oldRemoteViewing = RemoteViewing

function RemoteViewing(Superclass)
    local OldClass = oldRemoteViewing(Superclass)
    return Class(OldClass) {

        # Brute51: fixed a bug with the optics facility taking energie when trying to see something while the
        # building is paused [134].
        # while I was at it also implemented the means for a cooldown since I was going to do that in the balance
        # mod anyway. If you add a variable called 'Cooldown' in the intel table of the optics facility you can use
        # that to control the time beteen seeing different locations on the map. When the cooldown period is active
        # it cant change viewing locations. Another new feature is the viewtime. You can tell the optics facility 
        # how long to show a location and then stop viewing that. Use the variable 'Viewtime' in the intel table of
        # the units blueprint (same as prev value). If you use a value of 0 for any of these variables the feature 
        # is not used.

        # added by brute51 - a cooldown period. the vision marker cannot be changed during the is period
        CooldownThread = function(self, time)
            if time > 0 then
                self.Sync.Abilities = self:GetBlueprint().Abilities # dont use self:DisableRemoteViewingButtons(), that introduces a bug when using multiple remote viewing units
                self.Sync.Abilities.TargetLocation.Active = false
                self:RemoveToggleCap('RULEUTC_IntelToggle')
                WaitSeconds(time)
                self.Sync.Abilities = self:GetBlueprint().Abilities # dont use self:EnableRemoteViewingButtons()
                self.Sync.Abilities.TargetLocation.Active = true
                self:AddToggleCap('RULEUTC_IntelToggle')
            end
        end,

        # added by brute51 - an auto disable feature. removes the view after a set period
        ViewtimeThread = function(self, viewtime)
            if viewtime > 0 then
                WaitSeconds(viewtime)
                self:DisableVisibleEntity()
            end
        end,

        CreateVisibleEntity = function(self)
            local VisibilityEntityWillBeCreated = (self.RemoteViewingData.VisibleLocation and self.RemoteViewingData.DisableCounter == 0 and self.RemoteViewingData.IntelButton)
            OldClass.CreateVisibleEntity(self)
            if VisibilityEntityWillBeCreated then     # added by brue51
                local bp = self:GetBlueprint().Intel
                if bp.Cooldown and bp.Cooldown > 0 then
                    self:ForkThread(self.CooldownThread, bp.Cooldown)  # cooldown
                end
                if bp.Viewtime and bp.Viewtime > 0 then
                    self:ForkThread(self.ViewtimeThread, bp.Viewtime)  # auto-remove view
                end
            end
        end,

        OnTargetLocation = function(self, location)
            if not self.RemoteViewingData.IntelButton then # added by brute51 - bug fix [134]
                return
            end
            OldClass.OnTargetLocation(self, location)
        end,

        OnCreate = function(self)
            OldClass.OnCreate(self)
            #makes sure all scrying buttons are visible. sometimes they don't become visible by themselves.
            self.Sync.Abilities = self:GetBlueprint().Abilities # dont use self:EnableRemoteViewingButtons()
            self.Sync.Abilities.TargetLocation.Active = true
            self:AddToggleCap('RULEUTC_IntelToggle')
        end,
    }    
end