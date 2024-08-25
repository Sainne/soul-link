#built using mc-build (https://github.com/mc-build/mc-build)

schedule function sainne.soullink:tick_update/6 1t replace
execute as @a if score @s sainne.soullink.totem_use matches 1.. run scoreboard players set @s sainne.soullink.dmgtaken 0