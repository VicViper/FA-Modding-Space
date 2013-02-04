do

#Global Variables
Rose_ModUID = '6ba7fa0e-e713-4086-808d-7e659bf9cc28'
NoSML = 1
NoTML = 1


function GetActiveModLocation( mod_Id )
    for k, mod in __active_mods do
        if  mod_Id == mod.uid then
            return mod.location
        end
    end
    WARN("Unable to get mod directory! Wrong or missing UID. Searched for UID "..repr(mod_Id))
    return nil
end


Ianz_Path = GetActiveModLocation(Rose_ModUID)

# -------------------------------------------------------------------------------------------------------------
# UNIT RESTRICTION FUNCTIONS   (see bug 119)

# tells you whether unit restrictions are enabled
function CheckUnitRestrictionsEnabled()
    if ScenarioInfo.Options.RestrictedCategories then return true end
    return false
end

# tells you whether nuke launchers should be disabled
function NukesRestricted( WeaponLabel )
    if not CheckUnitRestrictionsEnabled() then     # if no restrictions defined then dont bother
        return false
    end
    if NoSML == 1 then
        local restrictedUnits = import('/lua/ui/lobby/restrictedUnitsData.lua').restrictedUnits
        for k, restriction in ScenarioInfo.Options.RestrictedCategories do # loops through enabled restrictions
            if not restrictedUnits[restriction].specialweapons then   # if no specialweapons table in restriction..
                continue
            end
            for l, cat in restrictedUnits[restriction].specialweapons do    # loops through all specialweapons
                if cat == 'StrategicMissile' or cat == 'strategicmissile' or cat == 'sm' or cat == 'SM' then
                    NoSML = true
                end
            end
        end
    end
    return NoSML
end

# tells you whether tactical missile launcehrs should be disabled
function TacticalMissilesRestricted( WeaponLabel )
    if not CheckUnitRestrictionsEnabled() then     # if no restrictions defined then dont bother
        return false
    end
    if NoTML == 1 then
        local restrictedUnits = import('/lua/ui/lobby/restrictedUnitsData.lua').restrictedUnits
        for k, restriction in ScenarioInfo.Options.RestrictedCategories do # loops through enabled restrictions
            if not restrictedUnits[restriction].specialweapons then   # if no specialweapons table in restriction..
                continue
            end
            for l, cat in restrictedUnits[restriction].specialweapons do    # loops through all specialweapons
                if cat == 'TacticalMissile' or cat == 'tacticalmissile' or cat == 'tm' or cat == 'TM' then
                    NoTML = true
                end
            end
        end
    end
    return NoTML
end

# -------------------------------------------------------------------------------------------------------------


end