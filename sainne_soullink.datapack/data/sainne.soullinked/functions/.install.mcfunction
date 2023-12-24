#built using mc-build (https://github.com/mc-build/mc-build)

scoreboard objectives add sainne.soullink.dmgtaken minecraft.custom:minecraft.damage_taken
scoreboard objectives add sainne.soullink.global dummy
scoreboard objectives add sainne.soullink.hp health
scoreboard objectives add sainne.soullink.highest_hp dummy
scoreboard objectives add sainne.soullink.hp_diff dummy
scoreboard objectives add sainne.soullink.gapple minecraft.used:minecraft.golden_apple
scoreboard objectives add sainne.soullink.egapple minecraft.used:minecraft.enchanted_golden_apple
scoreboard objectives add sainne.soullink.death deathCount
scoreboard objectives add sainne.soullink.totem_use minecraft.used:totem_of_undying
team add sainne.soullink.red {"text":"🌹 Red Roses","color":"red"}
team modify sainne.soullink.red prefix {"text":"🌹 ","color":"red"}
team modify sainne.soullink.red color red
team add sainne.soullink.blue {"text":"🔥 Blue Blazes","color":"blue"}
team modify sainne.soullink.blue prefix {"text":"🔥 ","color":"blue"}
team modify sainne.soullink.blue color blue
team add sainne.soullink.green {"text":"🦢 Green Grace","color":"green"}
team modify sainne.soullink.green prefix {"text":"🦢 ","color":"green"}
team modify sainne.soullink.green color green
team add sainne.soullink.yellow {"text":"🧶 Yellow Yarns","color":"yellow"}
team modify sainne.soullink.yellow prefix {"text":"🧶 ","color":"yellow"}
team modify sainne.soullink.yellow color yellow
execute as @a run function sainne.soullink:as_players/first_join