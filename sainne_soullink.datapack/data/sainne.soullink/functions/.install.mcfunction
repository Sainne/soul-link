#adding scoreboards
scoreboard objectives add sainne.soullink.dmgtaken minecraft.custom:minecraft.damage_taken
scoreboard objectives add sainne.soullink.constants dummy
scoreboard objectives add sainne.soullink.hp health

#adding teams
team add sainne.soullink.red {"text":"🌹 Red Roses","color":"red"}

#team prefixes
team modify sainne.soullink.red prefix {"text":"🌹 ","color":"red"}

#coloring teams
team modify sainne.soullink.red color red


#Initializing scoreboards
scoreboard players set @a sainne.soullink.dmgtaken 0
scoreboard players set @a sainne.soullink.hp 0