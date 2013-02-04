AIFArtillerySonanceShellWeapon = Class(DefaultProjectileWeapon) { # bug fix - wrong FX for Aeon t3 artillery [142]
    FxChargeMuzzleFlash = {   # this had a typo, missing 'charge'
        '/effects/emitters/aeon_sonance_muzzle_01_emit.bp',
        '/effects/emitters/aeon_sonance_muzzle_02_emit.bp',
        '/effects/emitters/aeon_sonance_muzzle_03_emit.bp',
    },
}
