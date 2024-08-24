#built using mc-build (https://github.com/mc-build/mc-build)

tag @s add damager
scoreboard players remove @s sainne.soullink.dmgtaken 190
execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 19
execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
tag @s remove damager