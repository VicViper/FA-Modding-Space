#*****************************************************************
# BUFF FIELD BLUEPRINT LIST
#
# This is an improvised list of buff field blueprints. Just copy-
# paste and edit a previous blueprint to add one of your own.
# Using a function to mimic regular blueprint lists cause I don't
# know how to replicate the way it is done with other blueprints.
#*****************************************************************

BuffFieldBlueprints = {}
function BuffFieldBlueprint( bpData)
    table.insert(BuffFieldBlueprints, bpData)
end

##################################################################
## SERAPHIM BUFF FIELDS
##################################################################

BuffFieldBlueprint( {                         # Seraphim ACU Restoration
    Name = 'SeraphimACURegenBuffField',
    AffectsUnitCategories = 'ALLUNITS',
    AffectsSelf = true,
    DisableInTransport = true,
    EnabledOnCreate = false,
    Radius = 15,
    Buffs = {
        'SeraphimACURegenAura',
    },
})

BuffFieldBlueprint( {                         # Seraphim ACU Advanced Restoration
    Name = 'SeraphimAdvancedACURegenBuffField',
    AffectsUnitCategories = 'ALLUNITS',
    AffectsSelf = true,
    DisableInTransport = true,
    EnabledOnCreate = false,
    Radius = 15,
    Buffs = {
        'SeraphimAdvancedACURegenAura',
    },
})
