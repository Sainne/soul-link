#built using mc-build (https://github.com/mc-build/mc-build)

execute as @s if score auto_join sainne.soullink.global matches 1.. run function sainne.soullink:as_players/assign_team
scoreboard players set @s sainne.soullink.dmgtaken 0
give @s minecraft:bundle