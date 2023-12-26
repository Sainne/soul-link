#built using mc-build (https://github.com/mc-build/mc-build)

execute store result score red sainne.soullink.members run team list sainne.soullink.red
execute store result score blue sainne.soullink.members run team list sainne.soullink.blue
execute store result score green sainne.soullink.members run team list sainne.soullink.green
execute store result score yellow sainne.soullink.members run team list sainne.soullink.yellow
execute if score auto_join sainne.soullink.global matches 1 run function sainne.soullink:as_players/assign_team/join_green
execute if score auto_join sainne.soullink.global matches 2 run function sainne.soullink:as_players/assign_team/join_lowest