#built using mc-build (https://github.com/mc-build/mc-build)

schedule function sainne.soullink:tick_update/3 1t replace
execute as @a if score @s sainne.soullink.gapple matches 1.. run function sainne.soullink:as_players/gapple_update
execute as @a if score @s sainne.soullink.egapple matches 1.. run function sainne.soullink:as_players/egapple_update