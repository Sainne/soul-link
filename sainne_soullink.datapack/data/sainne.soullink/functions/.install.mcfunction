#adding scoreboards
scoreboard objectives add sainne.soullink.dmgtaken minecraft.custom:minecraft.damage_taken
scoreboard objectives add sainne.soullink.global dummy
scoreboard objectives add sainne.soullink.hp health
scoreboard objectives add sainne.soullink.highest_hp dummy
scoreboard objectives add sainne.soullink.hp_diff dummy
scoreboard objectives add sainne.soullink.gapple minecraft.used:minecraft.golden_apple
scoreboard objectives add sainne.soullink.egapple minecraft.used:minecraft.enchanted_golden_apple
scoreboard objectives add sainne.soullink.death deathCount
scoreboard objectives add sainne.soullink.totem_use minecraft.used:totem_of_undying

#adding teams
team add sainne.soullink.red {"text":"🌹 Red Roses","color":"red"}
team add sainne.soullink.blue {"text":"🔥 Blue Blazes","color":"blue"}

#team prefixes
team modify sainne.soullink.red prefix {"text":"🌹 ","color":"red"}
team modify sainne.soullink.blue prefix {"text":"🔥 ","color":"blue"}

#coloring teams
team modify sainne.soullink.red color red
team modify sainne.soullink.blue color blue

#Initializing scoreboards
scoreboard players set @a sainne.soullink.dmgtaken 0
scoreboard players set @a sainne.soullink.hp 0