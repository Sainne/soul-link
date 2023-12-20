tag @s add damager
scoreboard players remove @s sainne.soullink.dmgtaken 150
execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 15
execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
tag @s remove damager