tag @s add damager
scoreboard players remove @s sainne.soullink.dmgtaken 10
execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 1
execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
tag @s remove damager