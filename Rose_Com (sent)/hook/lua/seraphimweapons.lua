local Game = import('/lua/game.lua')
local DefaultBuffField = import(Game.Ianz_Path..'/hook/lua/defaultbufffield.lua').DefaultBuffField


SeraphimBuffField = Class(DefaultBuffField) {
    FieldVisualEmitter = '/effects/emitters/seraphim_regenerative_aura_01_emit.bp',
}