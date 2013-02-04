#****************************************************************************
#**
#**  File     :  /cdimage/units/XEA3204/XEA3204_script.lua
#**  Author(s):  Dru Staltman
#**
#**  Summary  :  UEF CDR Pod Script
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
 
local TConstructionUnit = import('/lua/terranunits.lua').TConstructionUnit
#local XEA3204 = import('/units/XEA3204/XEA3204.lua').XEA3204
local utils = import('/lua/utilities.lua')
local oldXEA3204=TConstructionUnit

XEA3204 = Class(TConstructionUnit) {
 
    OnCreate = function(self)
        TConstructionUnit.OnCreate(self)
        self.docked = true
        self.returning = false
    end,
 
    SetParent = function(self, parent, podName)
        self.Parent = parent
        self.PodName = podName
        self:SetCreator(parent)
    end,
 
    OnKilled = function(self, instigator, type, overkillRatio)
        if self.Parent and not self.Parent:IsDead() then
            self.Parent:NotifyOfPodDeath(self.PodName)
            self.Parent = nil
        end
        TConstructionUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
    
    OnStartBuild = function(self, unitBeingBuilt, order )
  local pbp = self.Parent:GetBlueprint()
  local dists = { 
   actual = utils.GetDistanceBetweenTwoEntities(self,self.Parent),
   blueprint = pbp.AI.GuardScanRadius,
  } 
  #LOG(repr(dists)) 
  if (dists.actual < dists.blueprint) then 
   TConstructionUnit.OnStartBuild(self, unitBeingBuilt, order )
   self.returning = false
  else
   IssueClearCommands({self}) 
   IssueStop({self})
  end
    end,    
    OnStopBuild = function(self, unitBuilding)
        TConstructionUnit.OnStopBuild(self, unitBuilding)
        self.returning = true
    end,
    OnFailedToBuild = function(self)
        TConstructionUnit.OnFailedToBuild(self)
        self.returning = true
    end,
    OnMotionHorzEventChange = function( self, new, old )
        if self and not self:IsDead() then
            if self.Parent and not self.Parent:IsDead() then
   local pbp = self.Parent:GetBlueprint()
   local dist = pbp.AI.GuardScanRadius
   local distance = utils.GetDistanceBetweenTwoEntities(self,self.Parent)
   if distance<dist!=2.0<1 then
    #IssueClearCommands({self}) 
    #IssueStop({self})
   end
                local myPosition = self:GetPosition()
                local parentPosition = self.Parent:GetPosition(self.Parent.PodData[self.PodName].PodAttachpoint)
                local distSq = VDist2Sq(myPosition[1], myPosition[3], parentPosition[1], parentPosition[3])
                if self.docked and distSq > 0 and not self.returning then
                    self.docked = false
                    self.Parent:ForkThread(self.Parent.NotifyOfPodStartBuild)
                    #LOG("Leaving dock! " .. distSq)
                elseif not self.docked and distSq < 1 and self.returning then
                    self.docked = true
                    self.Parent:ForkThread(self.Parent.NotifyOfPodStopBuild)
                    #LOG("Docked again " .. distSq)
                end
            end
        
  end
    end,
    #################################################
 OnStartCapture = function(self, target)
  local pbp = self.Parent:GetBlueprint()
  local dists = { 
   actual = utils.GetDistanceBetweenTwoEntities(self,self.Parent),
   blueprint = pbp.AI.GuardScanRadius, 
  } 
  #LOG(repr(dists)) 
  if (dists.actual < dists.blueprint) then 
   self:DoUnitCallbacks( 'OnStartCapture', target)
   self:StartCaptureEffects(target)
   self:PlayUnitSound('StartCapture')
   self:PlayUnitAmbientSound('CaptureLoop')
  else
   IssueClearCommands({self}) 
   IssueStop({self})
  end
    end,
 OnStartReclaim = function(self, target)
  local pbp = self.Parent:GetBlueprint()
  local dists = { 
   actual = utils.GetDistanceBetweenTwoEntities(self,self.Parent),
   blueprint = pbp.AI.GuardScanRadius, 
  }
  #LOG(repr(dists)) 
  if (dists.actual < dists.blueprint) then 
   #LOG('not detected')
   self:DoUnitCallbacks('OnStartReclaim', target)
   self:StartReclaimEffects(target)
   self:PlayUnitSound('StartReclaim')
   self:PlayUnitAmbientSound('ReclaimLoop')
  else
   #LOG('detected')
   IssueClearCommands({self}) 
   #IssueDestroySelf({self})
   IssueStop({self})
  end
    end,
               
}
 
TypeClass = XEA3204
