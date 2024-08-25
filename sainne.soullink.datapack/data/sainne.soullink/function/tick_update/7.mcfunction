#built using mc-build (https://github.com/mc-build/mc-build)

execute as @a if score @s sainne.soullink.totem_use matches 1.. run function sainne.soullink:as_players/totem_use
schedule function sainne.soullink:tick_update/9 2t replace