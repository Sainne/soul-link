#built using mc-build (https://github.com/mc-build/mc-build)

schedule function sainne.soullink:update/51tick 51t
execute as @a run function sainne.soullink:as_players/computations/highest_hp
execute as @a run function sainne.soullink:as_players/computations/hp_diff
execute as @a[scores={sainne.soullink.dmgtaken=..0}] run function sainne.soullink:as_players/heal
execute as @a[team=] if score auto_join sainne.soullink.global matches 1.. run function sainne.soullink:as_players/assign_team