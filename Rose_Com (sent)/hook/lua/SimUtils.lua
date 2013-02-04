do

# should always use this function when transfering units from one player to another (voluntary or otherwise). It
# retains most unit data.
function TransferUnitsOwnership(units, ToArmyIndex)
    local toBrain = GetArmyBrain(ToArmyIndex)
    if not toBrain or toBrain:IsDefeated() or not units or table.getn(units) < 1 then
        return
    end
    local newUnits = {}
    for k,v in units do
        local owner = v:GetArmy()
        if owner == ToArmyIndex or GetArmyBrain(owner):IsDefeated() then
            continue
            # removed " not IsAlly(owner,ToArmyIndex) or " because else it doesnt work when unit captured
        end
        # Only allow units not attached to be given. This is because units will give all of it's children over
        # aswell, so we only want the top level units to be given. Also, don't allow commanders to be given.
        if v:GetParent() != v or (v.Parent and v.Parent != v) then
            continue
        end

        local unit = v
        local bp = unit:GetBlueprint()
        local unitId = unit:GetUnitId()

        # B E F O R E
        local numNukes = unit:GetNukeSiloAmmoCount()  #looks like one of these 2 works for SMDs also
        local numTacMsl = unit:GetTacticalSiloAmmoCount()
        local unitKills = unit:GetStat('KILLS', 0).Value   #also takes care of the veteran level
        local unitHealth = unit:GetHealth()
        local shieldIsOn = false
        local ShieldHealth = 0
        local hasFuel = false
        local fuelRatio = 0
        local enh = {} # enhancements

        if unit.MyShield then
            shieldIsOn = unit:ShieldIsOn()
            ShieldHealth = unit.MyShield:GetHealth()
        end
        if bp.Physics.FuelUseTime and bp.Physics.FuelUseTime > 0 then   # going through the BP to check for fuel
            fuelRatio = unit:GetFuelRatio()                             # usage is more reliable then unit.HasFuel
            hasFuel = true                                              # cause some buildings say they use fuel
        end
        local posblEnh = bp.Enhancements
        if posblEnh then
            for k,v in posblEnh do
                if unit:HasEnhancement( k ) then
                   table.insert( enh, k )
                end
            end
        end

        # changing owner
        unit = ChangeUnitArmy(unit,ToArmyIndex)
        if not unit then
            continue
        end
        table.insert(newUnits, unit)

        # A F T E R
        if unitKills and unitKills > 0 then # set veterancy first
            unit:AddKills( unitKills )
        end
        if enh and table.getn(enh) > 0 then
            for k, v in enh do
                unit:CreateEnhancement( v )
            end
        end
        if unitHealth > unit:GetMaxHealth() then
            unitHealth = unit:GetMaxHealth()
        end
        unit:SetHealth(unit,unitHealth)
        if hasFuel then
            unit:SetFuelRatio(fuelRatio)
        end
        if numNukes and numNukes > 0 then
            unit:GiveNukeSiloAmmo( (numNukes - unit:GetNukeSiloAmmoCount()) )
        end
        if numTacMsl and numTacMsl > 0 then
            unit:GiveTacticalSiloAmmo( (numTacMsl - unit:GetTacticalSiloAmmoCount()) )
        end
        if unit.MyShield then
            unit.MyShield:SetHealth( unit, ShieldHealth )
            if shieldIsOn then
                unit:EnableShield()
            else
                unit:DisableShield()
            end
        end
    end
    return newUnits
end

function GiveUnitsToPlayer( data, units )
    if units then
        local owner = units[1]:GetArmy()
        if OkayToMessWithArmy(owner) then
            TransferUnitsOwnership( units, data.To )
        end
    end
end


end