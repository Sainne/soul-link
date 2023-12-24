#built using mc-build (https://github.com/mc-build/mc-build)

schedule function sainne.soullinked:update/51tick 51t
execute as @a run function sainne.soullink:as_players/computations/highest_hp
execute as @a run function sainne.soullink:as_players/computations/hp_diff
execute as @a[scores={sainne.soullink.dmgtaken=..0}] run function sainne.soullink:as_players/heal