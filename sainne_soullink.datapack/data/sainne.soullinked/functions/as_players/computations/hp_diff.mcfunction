#built using mc-build (https://github.com/mc-build/mc-build)

execute if entity @s[team=sainne.soullink.red] run scoreboard players operation @s sainne.soullink.hp_diff = @s sainne.soullink.hp
execute if entity @s[team=sainne.soullink.red] run scoreboard players operation @s sainne.soullink.hp_diff -= red sainne.soullink.hp
execute if entity @s[team=sainne.soullink.blue] run scoreboard players operation @s sainne.soullink.hp_diff = @s sainne.soullink.hp
execute if entity @s[team=sainne.soullink.blue] run scoreboard players operation @s sainne.soullink.hp_diff -= blue sainne.soullink.hp
execute if entity @s[team=sainne.soullink.green] run scoreboard players operation @s sainne.soullink.hp_diff = @s sainne.soullink.hp
execute if entity @s[team=sainne.soullink.green] run scoreboard players operation @s sainne.soullink.hp_diff -= green sainne.soullink.hp
execute if entity @s[team=sainne.soullink.yellow] run scoreboard players operation @s sainne.soullink.hp_diff = @s sainne.soullink.hp
execute if entity @s[team=sainne.soullink.yellow] run scoreboard players operation @s sainne.soullink.hp_diff -= yellow sainne.soullink.hp