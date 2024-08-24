#built using mc-build (https://github.com/mc-build/mc-build)

recipe take @a *
advancement revoke @a everything
clear @a
team empty sainne.soullink.red
team empty sainne.soullink.blue
team empty sainne.soullink.green
team empty sainne.soullink.yellow
advancement grant @a[sort=random] only sainne.soullink:first_join
execute as @a[sort=random] run function sainne.soullink:as_players/assign_team
effect give @a minecraft:regeneration 5 100 true
effect give @a minecraft:saturation 5 100 true
function sainne.soullink:settings/spreadplayers
tellraw @a ["\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"]
tellraw @a ["",{"text":"All players have had their inventories,advancements and recipes cleared!","color":"dark_red"},"\n",{"text":"All players have been distributed on the map!","color":"dark_green"},"\n",{"text":"All players have been assigned new soul mates!","color":"dark_purple"}]
playsound minecraft:entity.arrow.hit_player master @s ~ ~ ~ 0.2 1.6 0.2