tag @s add damager
scoreboard players remove @s sainne.soullink.dmgtaken 160
execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 16
execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
tag @s remove damager