local oldUAS0401 = UAS0401

UAS0401 = Class(oldUAS0401) {

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
            if not self.UnitBeingBuilt:IsDead() then
                unitBuilding:AttachBoneTo( -2, self, bone )
                if EntityCategoryContains( categories.ENGINEER + categories.uas0102 + categories.uas0103, unitBuilding ) then
                    unitBuilding:SetParentOffset( {0,0,1} )
                elseif EntityCategoryContains( categories.TECH2 - categories.ENGINEER, unitBuilding ) then
                    unitBuilding:SetParentOffset( {0,0,3} )
                elseif EntityCategoryContains( categories.uas0203, unitBuilding ) then
                    unitBuilding:SetParentOffset( {0,0,1.5} )
                else
                    unitBuilding:SetParentOffset( {0,0,2.5} )
                end
            end
            self.UnitDoneBeingBuilt = false
        end,

        OnStopBuild = function(self, unitBeingBuilt)
            ASubUnit.OnStopBuild(self, unitBeingBuilt)
            ChangeState(self, self.FinishedBuildingState)
        end,
    },

    FinishedBuildingState = State {
        Main = function(self)
            local unitBuilding = self.UnitBeingBuilt  # added by brute51
            if not self:IsUnitBuildableByMe(unitBuilding) then
                IssueStop({self})
                IssueClearCommands({self})
                self:SetBusy(false)
                return
            end

            self:SetBusy(true)
            unitBuilding:DetachFrom(true)
            self:DetachAll(self.BuildAttachBone)
            local worldPos = self:CalculateWorldPositionFromRelative({0, 0, -20})
            IssueMoveOffFactory({unitBuilding}, worldPos)
            self:SetBusy(false)
            ChangeState(self, self.IdleState)
        end,
    },

  # Sub speed

  OnLayerChange = function(self, new, old)
    ASubUnit.OnLayerChange(self, new, old)
    if( new == 'Water' ) then
      self:SetSpeedMult(1)
    elseif ( new == 'Sub' ) then
      self:SetSpeedMult(0.8)
    end
  end,

}

TypeClass = UAS0401