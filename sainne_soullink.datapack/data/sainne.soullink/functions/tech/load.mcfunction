#adding scoreboards
scoreboard objectives add sainne.soullink.dmgtaken minecraft.custom:minecraft.damage_taken
scoreboard objectives add sainne.soullink.constants dummy
scoreboard objectives add sainne.soullink.hp health

#constants
scoreboard players set 10 sainne.soullink.constants 10
scoreboard players set 20 sainne.soullink.constants 20
scoreboard players set 30 sainne.soullink.constants 30
scoreboard players set 40 sainne.soullink.constants 40
scoreboard players set 50 sainne.soullink.constants 50
scoreboard players set 60 sainne.soullink.constants 60
scoreboard players set 70 sainne.soullink.constants 70
scoreboard players set 80 sainne.soullink.constants 80
scoreboard players set 90 sainne.soullink.constants 90
scoreboard players set 100 sainne.soullink.constants 100
scoreboard players set 110 sainne.soullink.constants 110
scoreboard players set 120 sainne.soullink.constants 120
scoreboard players set 130 sainne.soullink.constants 130
scoreboard players set 140 sainne.soullink.constants 140
scoreboard players set 150 sainne.soullink.constants 150
scoreboard players set 160 sainne.soullink.constants 160
scoreboard players set 170 sainne.soullink.constants 170
scoreboard players set 180 sainne.soullink.constants 180
scoreboard players set 190 sainne.soullink.constants 190
scoreboard players set 200 sainne.soullink.constants 200

#adding teams
team add team1

#coloring teams
team modify team1 color red

#Clear the update schedule, and schedule the update once again
schedule function sainne.soullink:update/10tick 10t replace
