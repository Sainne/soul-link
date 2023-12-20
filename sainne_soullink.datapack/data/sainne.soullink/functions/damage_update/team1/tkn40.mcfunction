tag @s add damager
scoreboard players operation @s sainne.soullink.dmgtaken -= 40 sainne.soullink.constants
execute as @a[team=team1,tag=!damager] run damage @s 4
execute as @a[team=team1,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
tag @s remove damager