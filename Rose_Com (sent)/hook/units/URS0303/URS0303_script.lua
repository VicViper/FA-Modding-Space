local oldURS0303 = URS0303

URS0303 = Class(oldURS0303) {

    # added by brute51 -------------------------------------------------------------
    # bug fix copied from the Atlantis fix

    OnStartReclaim = function(self, target)
        IssueStop({self})
        IssueClearCommands({self})
    end,

    OnStartCapture = function(self, target)
        IssueStop({self})
        IssueClearCommands({self})
    end,

    IsUnitBuildableByMe = function(self, unit)

        # check whether we can actually build the unit we wanna build

        local IsUnitBuildableByMe = false
        local MyBuildableCategories = self:GetBlueprint().Economy.BuildableCategory
        for k, v in MyBuildableCategories do
            if EntityCategoryContains(ParseEntityCategory(v), unit) then
                IsUnitBuildableByMe = true
                break
            end
        end
        return IsUnitBuildableByMe
    end,

    # ----------------

    BuildingState = State {
        Main = function(self)
            local unitBuilding = self.UnitBeingBuilt
            if not self:IsUnitBuildableByMe(unitBuilding) then  # added by brute51
                IssueStop({self})
                IssueClearCommands({self})
                self:SetBusy(false)
                return
            end

            self:SetBusy(true)
            local bone = self.BuildAttachBone
            self:DetachAll(bone)
            unitBuilding:HideBone(0, true)
            self.UnitDoneBeingBuilt = false
        end,

        OnStopBuild = function(self, unitBeingBuilt)
            CSeaUnit.OnStopBuild(self, unitBeingBuilt)
            ChangeState(self, self.FinishedBuildingState)
        end,
    },

    FinishedBuildingState = State {
        Main = function(self)
            local unitBuilding = self.UnitBeingBuilt
            if not self:IsUnitBuildableByMe(unitBuilding) then  # added by brute51
                IssueStop({self})
                IssueClearCommands({self})
                self:SetBusy(false)
                return
            end

            self:SetBusy(true)
            unitBuilding:DetachFrom(true)
            self:DetachAll(self.BuildAttachBone)
            if self:TransportHasAvailableStorage() then
                self:AddUnitToStorage(unitBuilding)
            else
                local worldPos = self:CalculateWorldPositionFromRelative({0, 0, -20})
                IssueMoveOffFactory({unitBuilding}, worldPos)
                unitBuilding:ShowBone(0,true)
            end
            self:SetBusy(false)
            self:RequestRefreshUI()
            ChangeState(self, self.IdleState)
        end,
    },
}

TypeClass = URS0303

