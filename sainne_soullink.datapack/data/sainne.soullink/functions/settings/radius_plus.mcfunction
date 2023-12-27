#built using mc-build (https://github.com/mc-build/mc-build)

execute if score spreadRadius sainne.soullink.global matches ..2999 run scoreboard players add spreadRadius sainne.soullink.global 250
function sainne.soullink:.settings
execute if score spreadRadius sainne.soullink.global matches ..2999 run playsound minecraft:entity.arrow.hit_player master @s ~ ~ ~ 0.2 1.6 0.2