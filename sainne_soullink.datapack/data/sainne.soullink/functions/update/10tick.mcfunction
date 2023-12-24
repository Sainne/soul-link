#damage updates
execute as @a if score @s sainne.soullink.dmgtaken matches 1.. run function sainne.soullink:damage_update/main

#gapple update
execute as @a if score @s sainne.soullink.gapple matches 1.. run function sainne.soullink:gapple_update/main
#enchanted gapple update
execute as @a if score @s sainne.soullink.egapple matches 1.. run function sainne.soullink:egapple_update/main

#death update
execute as @a if score @s sainne.soullink.death matches 1.. run function sainne.soullink:death_update/main

#totem update
execute as @a if score @s sainne.soullink.totem_use matches 1.. run scoreboard players set @s sainne.soullink.dmgtaken 0
execute as @a if score @s sainne.soullink.totem_use matches 1.. run scoreboard players set @s sainne.soullink.totem_use 0


schedule function sainne.soullink:update/10tick 10t replace
