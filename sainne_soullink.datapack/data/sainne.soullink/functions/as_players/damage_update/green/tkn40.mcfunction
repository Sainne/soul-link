#built using mc-build (https://github.com/mc-build/mc-build)

tag @s add damager
scoreboard players remove @s sainne.soullink.dmgtaken 40
execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 4
execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
tag @s remove damager