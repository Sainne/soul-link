#built using mc-build (https://github.com/mc-build/mc-build)

scoreboard players set red sainne.soullink.highest_hp 1
execute as @a[team=sainne.soullink.red] run scoreboard players operation red sainne.soullink.highest_hp > @s sainne.soullink.hp
scoreboard players set blue sainne.soullink.highest_hp 1
execute as @a[team=sainne.soullink.blue] run scoreboard players operation blue sainne.soullink.highest_hp > @s sainne.soullink.hp
scoreboard players set green sainne.soullink.highest_hp 1
execute as @a[team=sainne.soullink.green] run scoreboard players operation green sainne.soullink.highest_hp > @s sainne.soullink.hp
scoreboard players set yellow sainne.soullink.highest_hp 1
execute as @a[team=sainne.soullink.yellow] run scoreboard players operation yellow sainne.soullink.highest_hp > @s sainne.soullink.hp