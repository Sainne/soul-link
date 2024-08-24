#built using mc-build (https://github.com/mc-build/mc-build)

execute if entity @s[team=] if score red sainne.soullink.members < max_members sainne.soullink.global run team join sainne.soullink.red
execute if entity @s[team=] if score blue sainne.soullink.members < max_members sainne.soullink.global run team join sainne.soullink.blue
execute if entity @s[team=] if score green sainne.soullink.members < max_members sainne.soullink.global run team join sainne.soullink.green
execute if entity @s[team=] if score yellow sainne.soullink.members < max_members sainne.soullink.global run team join sainne.soullink.yellow
execute if entity @s[team=] run tellraw @a ["",{"selector":"@s","color":"gold"},{"text":" has not been assigned a team, as all teams are full!","color":"dark_red"}]