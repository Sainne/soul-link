#built using mc-build (https://github.com/mc-build/mc-build)

schedule function sainne.soullink:tick_update/3 2t replace
execute as @a if score @s sainne.soullink.dmgtaken matches 1.. run function sainne.soullink:as_players/damage_update