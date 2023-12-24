# Function that runs upon reload, if the datapack has been installed
# dont run the initial setup again
function load{
    scoreboard objectives add sainne.soullink.global dummy
    execute unless score installed sainne.soullink.global matches 1 run function sainne.soullink:.install
    tellraw @a [{"text":"Soul","color": "green"},{"text":"-💙-","color":"red"},{"text":"Link","color":"yellow"},{"text":" has been reloaded!","color":"gold"}]tellraw @a [{"text":"Soul","color": "green"},{"text":"🔗","color":"red"},{"text":"Linked","color":"yellow"},{"text":" has been reloaded!","color":"gold"}]
}
# Initial setup commands
function .install{
    # Adding scoreboards
    scoreboard objectives add sainne.soullink.dmgtaken minecraft.custom:minecraft.damage_taken
    scoreboard objectives add sainne.soullink.global dummy
    scoreboard objectives add sainne.soullink.hp health
    scoreboard objectives add sainne.soullink.highest_hp dummy
    scoreboard objectives add sainne.soullink.hp_diff dummy
    scoreboard objectives add sainne.soullink.gapple minecraft.used:minecraft.golden_apple
    scoreboard objectives add sainne.soullink.egapple minecraft.used:minecraft.enchanted_golden_apple
    scoreboard objectives add sainne.soullink.death deathCount
    scoreboard objectives add sainne.soullink.totem_use minecraft.used:totem_of_undying
    # Adding teams prefixes and color, the arrays defined in the js block are global
    <%%
        teams = ["red","blue","green","yellow"]
        team_names = ["🌹 Red Roses","🔥 Blue Blazes","🦢 Green Grace","🧶 Yellow Yarns"]
        team_prefix = ["🌹 ", "🔥 ", "🦢 ", "🧶 "]
        for (let i=0; i<teams.length; i++) {
            emit(`team add sainne.soullink.${teams[i]} {"text":"${team_names[i]}","color":"${teams[i]}"}`)
            emit(`team modify sainne.soullink.${teams[i]} prefix {"text":"${team_prefix[i]}","color":"${teams[i]}"}`)
            emit(`team modify sainne.soullink.${teams[i]} color ${teams[i]}`)
        }
    %%>
    # Initializing online players
    execute as @a run function sainne.soullink:as_players/first_join
}
# Remove all scoreboards and team, making the datapack esentially useless
function .uninstall{
    # Removing scoreboards
    scoreboard objectives remove sainne.soullink.dmgtaken
    scoreboard objectives remove sainne.soullink.global
    scoreboard objectives remove sainne.soullink.hp
    scoreboard objectives remove sainne.soullink.highest_hp
    scoreboard objectives remove sainne.soullink.hp_diff
    scoreboard objectives remove sainne.soullink.gapple
    scoreboard objectives remove sainne.soullink.egapple
    scoreboard objectives remove sainne.soullink.death
    scoreboard objectives remove sainne.soullink.totem_use
    # Removing teams
    <%%
        for (let i=0; i<teams.length; i++) {
            emit(`team remove sainne.soullink.${teams[i]}`)
        }
    %%>
}
# Settings function might delete later
function .settings{
    say settings test
}
# every ~2 seconds check healing updates
clock 51t{
    name update/51tick
    execute as @a run function sainne.soullink:as_players/computations/highest_hp
    execute as @a run function sainne.soullink:as_players/computations/hp_diff
    execute as @a[scores={sainne.soullink.dmgtaken=..0}] run function sainne.soullink:as_players/heal
}
# divided the updates in ticks to avoid checking all health updates in one tick
dir tick_update{
    function 1{
        schedule function sainne.soullink:tick_update/3 2t replace
        #damage updates
        execute as @a if score @s sainne.soullink.dmgtaken matches 1.. run function sainne.soullink:as_players/damage_update
    }
    function 3{
        schedule function sainne.soullink:tick_update/5 2t replace
        execute as @a if score @s sainne.soullink.gapple matches 1.. run function sainne.soullink:as_players/gapple_update
        execute as @a if score @s sainne.soullink.egapple matches 1.. run function sainne.soullink:as_players/egapple_update
    }
    function 5{
        schedule function sainne.soullink:tick_update/7 2t replace
        execute as @a if score @s sainne.soullink.death matches 1.. run function sainne.soullink:as_players/death_update
    }
    function 7{
        schedule function sainne.soullink:tick_update/9 2t replace
    }
    function 9{
        schedule function sainne.soullink:tick_update/11 2t replace
        # This deals when a team dies by receiving more damage than their hp
        # and revive with totem, to avoid falsely dying
        execute as @a if score @s sainne.soullink.totem_use matches 1.. run scoreboard players set @s sainne.soullink.dmgtaken 0
        execute as @a if score @s sainne.soullink.totem_use matches 1.. run scoreboard players set @s sainne.soullink.totem_use 0
    }
    function 11{
        schedule function sainne.soullink:tick_update/1 10t replace
    }
}

dir as_players{
    # Health computations for teams
    dir computations{
        # Estimates the highest hp of the team
        function highest_hp{
            <%%
                for (let i=0; i<teams.length; i++) {
                    emit(`scoreboard players set ${teams[i]} sainne.soullink.highest_hp 1`)
                    emit(`scoreboard players operation ${teams[i]} sainne.soullink.highest_hp > @s[team=sainne.soullink.${teams[i]}] sainne.soullink.hp`)
                }
            %%>
            }
        # Calculates the hp difference with the highest hp from the team
        function hp_diff{
            <%%
                for (let i=0; i<teams.length; i++) {
                    emit(`execute if entity @s[team=sainne.soullink.${teams[i]}] run scoreboard players operation @s sainne.soullink.hp_diff = @s sainne.soullink.hp`)
                    emit(`execute if entity @s[team=sainne.soullink.${teams[i]}] run scoreboard players operation @s sainne.soullink.hp_diff -= ${teams[i]} sainne.soullink.hp`)
                }
            %%>
        }
    }

    function heal{
        # If there is more than a heart of difference or more, regenerate 2hp
        # Thinking of changing this so it synchronizes based on hp_diff exactly instead of over periods of time syncing life
        # For that i need an exact formula of how regeneration scales.
        execute if score @s sainne.soullink.hp_diff matches ..-2 run effect give @s minecraft:regeneration 3 1 true
    }

    function damage_update{
    }
}