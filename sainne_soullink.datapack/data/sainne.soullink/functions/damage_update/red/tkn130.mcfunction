tag @s add damager
scoreboard players remove @s sainne.soullink.dmgtaken 130
execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 13
execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
tag @s remove damager