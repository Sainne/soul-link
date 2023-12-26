#built using mc-build (https://github.com/mc-build/mc-build)

scoreboard objectives add sainne.soullink.global dummy
execute unless score installed sainne.soullink.global matches 1 run function sainne.soullink:.install
tellraw @a [{"text":"Soul","color": "green"},{"text":"-💙-","color":"red"},{"text":"Link","color":"yellow"},{"text":" has been reloaded!","color":"gold"}]
function sainne.soullink:tick_update/1