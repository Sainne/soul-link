#built using mc-build (https://github.com/mc-build/mc-build)

recipe take @a *
advancement revoke @a everything
clear @a
team empty sainne.soullink.red
team empty sainne.soullink.blue
team empty sainne.soullink.green
team empty sainne.soullink.yellow
spreadplayers 0 0 20 2000 false @a
tellraw @a ["\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"]
tellraw @a ["",{"text":"All players have had their inventories,advancements and recipes cleared!","color":"dark_red"},"\n",{"text":"All players have been distributed on the map!","color":"dark_green"},"\n",{"text":"All players have been assigned new soul mates!","color":"dark_purple"}]
playsound minecraft:entity.arrow.hit_player master @s ~ ~ ~ 0.2 1.6 0.2