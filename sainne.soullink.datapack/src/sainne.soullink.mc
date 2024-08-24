# Function that runs upon reload, if the datapack has been installed
# dont run the initial setup again
function load{
    scoreboard objectives add sainne.soullink.global dummy
    execute unless score installed sainne.soullink.global matches 1 run function sainne.soullink:.install
    tellraw @a [{"text":"Soul","color": "green"},{"text":"-❤-","color":"red"},{"text":"Link","color":"yellow"},{"text":" has been reloaded!","color":"gold"}]
    function sainne.soullink:tick_update/1
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
    scoreboard objectives add sainne.soullink.members dummy
    # Adding teams prefixes and color, the arrays defined in the js block are global
    # Teams have prefixes and colors, this can be changed in settings.
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
    # Default settings
    # 0(no autojoin) 1(autojoin team green) 2(autojoin lowest member team))
    scoreboard players set auto_join sainne.soullink.global 0
    # if auto_join enabled, ignore teams of N members in the assignation
    scoreboard players set max_members sainne.soullink.global 2
    # 0(do not allow 1 member teams, if a team has 1 member, its reassigned to another team) 1(allow teams of 1 member)
    scoreboard players set allow_singles sainne.soullink.global 0
    # 0(respect teams when spreading) 1(do not respect teams when spreading players)
    scoreboard players set respectTeams sainne.soullink.global 1
    # Radius of player spread on quick start, only multiples of 250 up to 3000
    scoreboard players set spreadRadius sainne.soullink.global 750
    # Initializing all online players
    execute as @a run function sainne.soullink:as_players/first_join
    scoreboard players set installed sainne.soullink.global 1
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
    scoreboard objectives remove sainne.soullink.members
    # Removing teams
    <%%
        for (let i=0; i<teams.length; i++) {
            emit(`team remove sainne.soullink.${teams[i]}`)
        }
    %%>
}
# Settings function might delete later
function .settings{
    tellraw @s ["\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"]
    tellraw @s ["",{"text":"-------> ","color":"gold"},{"text":"Soul","color":"green"},{"text":"-❤-","color":"red"},{"text":"Link","color":"yellow"},{"text":" Settings <-------","color":"gold"}]
    tellraw @s ["",{"text":"Teams colors and prefixes:","color":"gold"},"\n",{"text":"[No color & prefixes]","color":"white","clickEvent":{"action":"run_command","value":"/function sainne.soullink:settings/teams_white"}},"       ",{"text":"[Teams colored with prefixes]","color":"dark_purple","clickEvent":{"action":"run_command","value":"/function sainne.soullink:settings/teams_color"}}]
    tellraw @s ["",{"text":"Auto join:","color":"gold"},"\n",{"text":"[OFF]","color":"red","clickEvent":{"action":"run_command","value":"/function sainne.soullink:settings/auto_join_off"}},"    ",{"text":"[Join Green]","color":"green","clickEvent":{"action":"run_command","value":"/function sainne.soullink:settings/auto_join_green"}},"    ",{"text":"[Join lowest]","color":"light_purple","clickEvent":{"action":"run_command","value":"/function sainne.soullink:settings/auto_join_lowest"}}]
    tellraw @s ["",{"text":"⚠","color":"red","hoverEvent":{"action":"show_text","contents":[{"text":"Only used if auto join is enabled on lowest member mode.","color":"red"},"\n"," ignores teams with over this amount of members in the assignation"]}},{"text":"Ignore teams of over N members:","color":"gold"},"\n",{"text":"[-]","color":"dark_red","clickEvent":{"action":"run_command","value":"/function sainne.soullink:settings/number_minus1"}},"   ",{"score":{"name":"max_members","objective":"sainne.soullink.global"},"color":"yellow"},"   ",{"text":"[+]","color":"dark_green","clickEvent":{"action":"run_command","value":"/function sainne.soullink:settings/number_plus1"}},"      ",{"text":"[RESET]","color":"light_purple","clickEvent":{"action":"run_command","value":"/function sainne.soullink:settings/number_reset"}}]
    tellraw @s ["",{"text":"Quick Start RespectTeams:","color":"gold"},"\n",{"text":"[False]   ","color":"dark_red","clickEvent":{"action":"run_command","value":"/function sainne.soullink:settings/teams_together_false"}},{"text":"   [True]","color":"green","clickEvent":{"action":"run_command","value":"/function sainne.soullink:settings/teams_together_true"}}]
    tellraw @s ["",{"text":"Quick Start SpreadRadius:","color":"gold"},"\n",{"text":"[-]   ","color":"dark_red","clickEvent":{"action":"run_command","value":"/function sainne.soullink:settings/radius_minus"}},{"score":{"name":"spreadRadius","objective":"sainne.soullink.global"},"color":"yellow"},{"text":"   [+]","color":"green","clickEvent":{"action":"run_command","value":"/function sainne.soullink:settings/radius_plus"}}]
    # tellraw @s ["",{"text":"Single teams allowed:","color":"gold","hoverEvent":{"action":"show_text","contents":[{"text":"If True, then teams with 1 member, will have their member reallocated, useful if ignoreN is 0","color":"red"}]}},"\n",{"text":"[False]","color":"red","clickEvent":{"action":"run_command","value":"/function sainne.soullink:settings/not_allow_singles"}},"    ",{"text":"[True]","color":"green","clickEvent":{"action":"run_command","value":"/function sainne.soullink:settings/allow_singles"}}]
    tellraw @s ["",{"text":"Start and spread all online players:","color":"gold"},"\n",{"text":"[GO!>>>]","bold":true,"underlined":true,"color":"dark_red","clickEvent":{"action":"run_command","value":"/function sainne.soullink:settings/quick_start"},"hoverEvent":{"action":"show_text","contents":[{"text":"This will reset all recipes and advancements of all players","color":"red"},"\n",{"text":"And spread them over 2000 blocks in the world","color":"red"},"\n",{"text":"Basically a quick start button","color":"dark_red"}]}}]
}
# Directory of settings functions
dir settings{
    # Give all teams prefixes and color, to distinguish players
    function teams_color{
        <%%
            for (let i=0; i<teams.length; i++) {
                emit(`team modify sainne.soullink.${teams[i]} prefix {"text":"${team_prefix[i]}","color":"${teams[i]}"}`)
                emit(`team modify sainne.soullink.${teams[i]} color ${teams[i]}`)
            }
        %%>
        function sainne.soullink:.settings
        playsound minecraft:entity.arrow.hit_player master @s ~ ~ ~ 0.2 1.6 0.2
    }
    # Give all teams the color white and no prefix
    # to hide the soul links of players
    function teams_white{
        <%%
            for (let i=0; i<teams.length; i++) {
                emit(`team modify sainne.soullink.${teams[i]} prefix {"text":""}`)
                emit(`team modify sainne.soullink.${teams[i]} color white`)
            }
        %%>
        function sainne.soullink:.settings
        playsound minecraft:entity.arrow.hit_player master @s ~ ~ ~ 0.2 1.6 0.2
    }
    function auto_join_off{
        scoreboard players set auto_join sainne.soullink.global 0
        function sainne.soullink:.settings
        playsound minecraft:entity.arrow.hit_player master @s ~ ~ ~ 0.2 1.6 0.2
    }
    function auto_join_green{
        scoreboard players set auto_join sainne.soullink.global 1
        function sainne.soullink:.settings
        playsound minecraft:entity.arrow.hit_player master @s ~ ~ ~ 0.2 1.6 0.2
    }
    function auto_join_lowest{
        scoreboard players set auto_join sainne.soullink.global 2
        function sainne.soullink:.settings
        playsound minecraft:entity.arrow.hit_player master @s ~ ~ ~ 0.2 1.6 0.2
    }
    function number_minus1{
        scoreboard players remove max_members sainne.soullink.global 1
        function sainne.soullink:.settings
        playsound minecraft:entity.arrow.hit_player master @s ~ ~ ~ 0.2 1.6 0.2
    }
    function number_plus1{
        scoreboard players add max_members sainne.soullink.global 1
        function sainne.soullink:.settings
        playsound minecraft:entity.arrow.hit_player master @s ~ ~ ~ 0.2 1.6 0.2
    }
    function number_reset{
        scoreboard players set max_members sainne.soullink.global 2
        function sainne.soullink:.settings
        playsound minecraft:entity.arrow.hit_player master @s ~ ~ ~ 0.2 1.6 0.2
    }
    function teams_together_true{
        scoreboard players set respectTeams sainne.soullink.global 1
        function sainne.soullink:.settings
        playsound minecraft:entity.arrow.hit_player master @s ~ ~ ~ 0.2 1.6 0.2
    }
    function teams_together_false{
        scoreboard players set respectTeams sainne.soullink.global 0
        function sainne.soullink:.settings
        playsound minecraft:entity.arrow.hit_player master @s ~ ~ ~ 0.2 1.6 0.2
    }
    function radius_minus{
        execute if score spreadRadius sainne.soullink.global matches 251.. run scoreboard players remove spreadRadius sainne.soullink.global 250
        function sainne.soullink:.settings
        execute if score spreadRadius sainne.soullink.global matches 251.. run playsound minecraft:entity.arrow.hit_player master @s ~ ~ ~ 0.2 1.6 0.2
    }
    function radius_plus{
        execute if score spreadRadius sainne.soullink.global matches ..2999 run scoreboard players add spreadRadius sainne.soullink.global 250
        function sainne.soullink:.settings
        execute if score spreadRadius sainne.soullink.global matches ..2999 run playsound minecraft:entity.arrow.hit_player master @s ~ ~ ~ 0.2 1.6 0.2
    }
    function allow_singles{
        scoreboard players set allow_singles sainne.soullink.global 1
        function sainne.soullink:.settings
        playsound minecraft:entity.arrow.hit_player master @s ~ ~ ~ 0.2 1.6 0.2
    }
    function not_allow_singles{
        scoreboard players set allow_singles sainne.soullink.global 0
        function sainne.soullink:.settings
        playsound minecraft:entity.arrow.hit_player master @s ~ ~ ~ 0.2 1.6 0.2
    }
    function quick_start{
        recipe take @a *
        advancement revoke @a everything
        clear @a
        <%%
            for (i = 0; i<teams.length; i++) {
                emit(`team empty sainne.soullink.${teams[i]}`)
            }
        %%>
        advancement grant @a[sort=random] only sainne.soullink:first_join
        execute as @a[sort=random] run function sainne.soullink:as_players/assign_team
        effect give @a minecraft:regeneration 5 100 true
        effect give @a minecraft:saturation 5 100 true
        function sainne.soullink:settings/spreadplayers
        tellraw @a ["\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"]
        tellraw @a ["",{"text":"All players have had their inventories,advancements and recipes cleared!","color":"dark_red"},"\n",{"text":"All players have been distributed on the map!","color":"dark_green"},"\n",{"text":"All players have been assigned new soul mates!","color":"dark_purple"}]
        playsound minecraft:entity.arrow.hit_player master @s ~ ~ ~ 0.2 1.6 0.2
    }
    function spreadplayers{
        execute if score respectTeams sainne.soullink.global matches 1 run function sainne.soullink:settings/spreadplayers/teams_together_true
        execute if score respectTeams sainne.soullink.global matches 0 run function sainne.soullink:settings/spreadplayers/teams_together_false
    }
    dir spreadplayers{
        function teams_together_true{
            <%%
                const radios = [250,500,750,1000,1250,1500,1750,2000,2250,2500,2750,3000]
                for (i = 0; i<radios.length; i++) {
                    radio = radios[i]
                    emit(`execute if score spreadRadius sainne.soullink.global matches ${radio} run spreadplayers 0 0 20 ${radio} true @a`)
                }
            %%>
        }
        function teams_together_false{
            <%%
                const radios = [250,500,750,1000,1250,1500,1750,2000,2250,2500,2750,3000]
                for (i = 0; i<radios.length; i++) {
                    radio = radios[i]
                    emit(`execute if score spreadRadius sainne.soullink.global matches ${radio} run spreadplayers 0 0 20 ${radio} false @a`)
                }
            %%>
        }
    }
}
# every ~2 seconds check healing updates
clock 51t{
    name update/51tick
    execute as @a run function sainne.soullink:as_players/computations/highest_hp
    execute as @a run function sainne.soullink:as_players/computations/hp_diff
    execute as @a[scores={sainne.soullink.dmgtaken=..0}] run function sainne.soullink:as_players/heal
    execute as @a[team=] if score auto_join sainne.soullink.global matches 1.. run function sainne.soullink:as_players/assign_team
}
# divided the updates in ticks to avoid checking all health updates in one tick
dir tick_update{
    function 1{
        schedule function sainne.soullink:tick_update/2 1t replace
        #damage updates
        execute as @a if score @s sainne.soullink.dmgtaken matches 1.. run function sainne.soullink:as_players/damage_update
    }
    function 2{
        schedule function sainne.soullink:tick_update/3 1t replace
        execute as @a if score @s sainne.soullink.gapple matches 1.. run function sainne.soullink:as_players/gapple_update
        execute as @a if score @s sainne.soullink.egapple matches 1.. run function sainne.soullink:as_players/egapple_update
    }
    function 3{
        schedule function sainne.soullink:tick_update/4 1t replace
        execute as @a if score @s sainne.soullink.death matches 1.. run function sainne.soullink:as_players/death_update
    }
    function 4{
        schedule function sainne.soullink:tick_update/5 1t replace
    }
    function 5{
        schedule function sainne.soullink:tick_update/6 1t replace
        # This deals when a team dies by receiving more damage than their hp
        # and revive with totem, to avoid falsely dying
        execute as @a if score @s sainne.soullink.totem_use matches 1.. run scoreboard players set @s sainne.soullink.dmgtaken 0
        execute as @a if score @s sainne.soullink.totem_use matches 1.. run scoreboard players set @s sainne.soullink.totem_use 0
    }
    function 6{
        schedule function sainne.soullink:tick_update/1 5t replace
    }
}

dir as_players{
    # On entering the world for the first time.
    function first_join{
        execute as @s if score auto_join sainne.soullink.global matches 1.. run function sainne.soullink:as_players/assign_team
        scoreboard players set @s sainne.soullink.dmgtaken 0
        give @s minecraft:bundle
    }
    # On login into the world
    function on_login{
        tellraw @s ["",{"text":"Welcome back!","color":"gold"},"\n",{"text":"-> This world is running ","color":"gold"},{"text":"Soul","color":"green"},{"text":"-❤-","color":"red"},{"text":"Link","color":"yellow"},"\n",{"text":"Your health is connected to other players in your team","color":"gold"}]
    }
    # Automatically assign team
    function assign_team{
        # calculate the amount of members in each team
        <%%
            for (i = 0; i<teams.length; i++) {
                emit(`execute store result score ${teams[i]} sainne.soullink.members run team list sainne.soullink.${teams[i]}`)
            }
        %%>
        # Run the correct algorithm depending on autojoin value
        execute if score auto_join sainne.soullink.global matches 1 run function sainne.soullink:as_players/assign_team/join_green
        execute if score auto_join sainne.soullink.global matches 2 run function sainne.soullink:as_players/assign_team/join_lowest
    }
    dir assign_team{
        function join_green{
            team join sainne.soullink.green @s
        }
        function join_lowest{
            <%%
                for (i = 0; i<teams.length; i++) {
                    emit(`execute if entity @s[team=] if score ${teams[i]} sainne.soullink.members < max_members sainne.soullink.global run team join sainne.soullink.${teams[i]}`)
                }
            %%>
            execute if entity @s[team=] run tellraw @a ["",{"selector":"@s","color":"gold"},{"text":" has not been assigned a team, as all teams are full!","color":"dark_red"}]
        }
    }
    # Health computations for teams
    dir computations{
        # Estimates the highest hp of the team
        function highest_hp{
            <%%
                for (let i=0; i<teams.length; i++) {
                    emit(`scoreboard players set ${teams[i]} sainne.soullink.highest_hp 1`)
                    emit(`execute as @a[team=sainne.soullink.${teams[i]}] run scoreboard players operation ${teams[i]} sainne.soullink.highest_hp > @s sainne.soullink.hp`)
                }
            %%>
            }
        # Calculates the hp difference with the highest hp from the team
        function hp_diff{
            scoreboard players operation @s sainne.soullink.hp_diff = @s sainne.soullink.hp
            <%%
                for (let i=0; i<teams.length; i++) {
                    emit(`execute if entity @s[team=sainne.soullink.${teams[i]}] run scoreboard players operation @s sainne.soullink.hp_diff -= ${teams[i]} sainne.soullink.highest_hp`)
                }
            %%>
        }
    }

    function heal{
        # If there is more than a heart of difference or more, regenerate 2hp
        # Thinking of changing this so it synchronizes based on hp_diff exactly instead of over periods of time syncing life
        # For that i need an exact formula of how regeneration scales.
        # so there could hipotetically exist, for some hp difference
        # a regeneration amplitude, time combination that heals that exactly
        # mojang please give /heal [player] [amount] command!
        execute if score @s sainne.soullink.hp_diff matches ..-2 run effect give @s minecraft:regeneration 3 1 true
    }
    # Team detection function for detecting damage
    function damage_update{
        <%%
            for (let i=0; i<teams.length; i++) {
                emit(`execute if entity @s[team=sainne.soullink.${teams[i]}] run function sainne.soullink:as_players/damage_update/${teams[i]}`)
            }
        %%>
    }
    # Damage detection functions (if adding a team, append a function and directory respectively)
    dir damage_update{
        # Team red estimate damage interval
        function red{
            <%%
                decimals = [1,2,3,4,5,6,7,8,9]
                for (let i=0; i<decimals.length; i++) {
                    emit(`execute as @a[team=sainne.soullink.red,scores={sainne.soullink.dmgtaken=${decimals[i]}}] run function sainne.soullink:as_players/damage_update/red/tkn${decimals[i]}`)
                }
            %%>
            <%%
                intervalos = [9,19,29,39,49,59,69,79,89,99,109,119,129,139,149,159,169,179,189,199]
                for (let i=1; i<intervalos.length; i++) {
                    let inferior = intervalos[i-1] + 1
                    let superior = intervalos[i]
                    let nombre = superior - 9
                    emit(`execute as @a[team=sainne.soullink.red,scores={sainne.soullink.dmgtaken=${inferior}..${superior}}] run function sainne.soullink:as_players/damage_update/red/tkn${nombre}`)
                }
            %%>
            execute as @a[team=sainne.soullink.red,scores={sainne.soullink.dmgtaken=200..}] run function sainne.soullink:as_players/damage_update/red/tkn200
        }
        # Team red, execute damage
        dir red{
            # daño decimal
            function tkn1{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 1
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 0.1
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn2{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 2
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 0.2
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn3{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 3
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 0.3
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn4{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 4
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 0.4
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn5{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 5
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 0.5
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn6{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 6
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 0.6
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn7{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 7
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 0.7
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn8{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 8
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 0.8
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn9{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 9
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 0.9
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            # daños enteros
            function tkn10{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 10
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 1
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn20{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 20
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 2
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn30{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 30
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 3
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn40{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 40
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 4
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn50{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 50
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 5
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn60{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 60
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 6
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn70{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 70
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 7
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn80{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 80
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 8
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn90{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 90
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 9
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn100{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 100
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 10
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn110{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 110
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 11
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn120{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 120
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 12
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn130{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 130
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 13
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn140{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 140
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 14
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn150{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 150
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 15
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn160{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 160
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 16
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn170{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 170
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 17
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn180{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 180
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 18
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn190{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 190
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 19
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn200{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 200
                execute as @a[team=sainne.soullink.red,tag=!damager] run damage @s 20
                execute as @a[team=sainne.soullink.red,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
        }
        # Team blue estimate damage interval
        function blue{
            <%%
                decimals = [1,2,3,4,5,6,7,8,9]
                for (let i=0; i<decimals.length; i++) {
                    emit(`execute as @a[team=sainne.soullink.blue,scores={sainne.soullink.dmgtaken=${decimals[i]}}] run function sainne.soullink:as_players/damage_update/blue/tkn${decimals[i]}`)
                }
            %%>
            <%%
                intervalos = [9,19,29,39,49,59,69,79,89,99,109,119,129,139,149,159,169,179,189,199]
                for (let i=1; i<intervalos.length; i++) {
                    let inferior = intervalos[i-1] + 1
                    let superior = intervalos[i]
                    let nombre = superior - 9
                    emit(`execute as @a[team=sainne.soullink.blue,scores={sainne.soullink.dmgtaken=${inferior}..${superior}}] run function sainne.soullink:as_players/damage_update/blue/tkn${nombre}`)
                }
            %%>
            execute as @a[team=sainne.soullink.blue,scores={sainne.soullink.dmgtaken=191..}] run function sainne.soullink:as_players/damage_update/blue/tkn200
        }
        # Team blue, execute damage
        dir blue{
            # daño decimal
            function tkn1{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 1
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 0.1
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn2{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 2
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 0.2
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn3{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 3
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 0.3
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn4{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 4
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 0.4
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn5{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 5
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 0.5
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn6{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 6
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 0.6
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn7{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 7
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 0.7
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn8{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 8
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 0.8
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn9{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 9
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 0.9
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            # daños enteros
            function tkn10{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 10
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 1
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn20{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 20
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 2
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn30{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 30
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 3
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn40{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 40
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 4
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn50{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 50
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 5
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn60{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 60
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 6
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn70{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 70
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 7
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn80{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 80
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 8
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn90{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 90
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 9
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn100{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 100
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 10
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn110{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 110
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 11
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn120{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 120
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 12
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn130{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 130
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 13
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn140{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 140
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 14
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn150{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 150
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 15
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn160{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 160
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 16
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn170{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 170
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 17
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn180{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 180
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 18
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn190{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 190
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 19
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn200{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 200
                execute as @a[team=sainne.soullink.blue,tag=!damager] run damage @s 20
                execute as @a[team=sainne.soullink.blue,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
        }
        # Team green estimate damage interval
        function green{
            <%%
                decimals = [1,2,3,4,5,6,7,8,9]
                for (let i=0; i<decimals.length; i++) {
                    emit(`execute as @a[team=sainne.soullink.green,scores={sainne.soullink.dmgtaken=${decimals[i]}}] run function sainne.soullink:as_players/damage_update/green/tkn${decimals[i]}`)
                }
            %%>
            <%%
                intervalos = [9,19,29,39,49,59,69,79,89,99,109,119,129,139,149,159,169,179,189,199]
                for (let i=1; i<intervalos.length; i++) {
                    let inferior = intervalos[i-1] + 1
                    let superior = intervalos[i]
                    let nombre = superior - 9
                    emit(`execute as @a[team=sainne.soullink.green,scores={sainne.soullink.dmgtaken=${inferior}..${superior}}] run function sainne.soullink:as_players/damage_update/green/tkn${nombre}`)
                }
            %%>
            execute as @a[team=sainne.soullink.green,scores={sainne.soullink.dmgtaken=191..}] run function sainne.soullink:as_players/damage_update/green/tkn200
        }
        # Team green, execute damage
        dir green{
            # daño decimal
            function tkn1{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 1
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 0.1
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn2{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 2
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 0.2
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn3{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 3
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 0.3
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn4{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 4
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 0.4
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn5{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 5
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 0.5
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn6{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 6
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 0.6
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn7{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 7
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 0.7
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn8{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 8
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 0.8
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn9{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 9
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 0.9
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            # daños enteros
            function tkn10{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 10
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 1
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn20{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 20
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 2
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn30{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 30
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 3
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn40{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 40
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 4
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn50{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 50
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 5
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn60{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 60
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 6
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn70{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 70
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 7
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn80{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 80
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 8
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn90{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 90
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 9
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn100{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 100
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 10
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn110{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 110
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 11
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn120{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 120
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 12
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn130{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 130
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 13
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn140{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 140
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 14
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn150{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 150
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 15
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn160{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 160
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 16
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn170{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 170
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 17
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn180{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 180
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 18
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn190{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 190
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 19
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn200{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 200
                execute as @a[team=sainne.soullink.green,tag=!damager] run damage @s 20
                execute as @a[team=sainne.soullink.green,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
        }
        # Team yellow estimate damage interval
        function yellow{
            <%%
                decimals = [1,2,3,4,5,6,7,8,9]
                for (let i=0; i<decimals.length; i++) {
                    emit(`execute as @a[team=sainne.soullink.yellow,scores={sainne.soullink.dmgtaken=${decimals[i]}}] run function sainne.soullink:as_players/damage_update/yellow/tkn${decimals[i]}`)
                }
            %%>
            <%%
                intervalos = [9,19,29,39,49,59,69,79,89,99,109,119,129,139,149,159,169,179,189,199]
                for (let i=1; i<intervalos.length; i++) {
                    let inferior = intervalos[i-1] + 1
                    let superior = intervalos[i]
                    let nombre = superior - 9
                    emit(`execute as @a[team=sainne.soullink.yellow,scores={sainne.soullink.dmgtaken=${inferior}..${superior}}] run function sainne.soullink:as_players/damage_update/yellow/tkn${nombre}`)
                }
            %%>
            execute as @a[team=sainne.soullink.yellow,scores={sainne.soullink.dmgtaken=191..}] run function sainne.soullink:as_players/damage_update/yellow/tkn200
        }
        # Team yellow, execute damage
        dir yellow{
            # daño decimal
            function tkn1{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 1
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 0.1
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn2{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 2
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 0.2
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn3{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 3
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 0.3
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn4{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 4
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 0.4
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn5{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 5
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 0.5
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn6{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 6
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 0.6
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn7{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 7
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 0.7
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn8{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 8
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 0.8
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn9{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 9
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 0.9
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            # daños enteros
            function tkn10{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 10
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 1
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn20{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 20
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 2
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn30{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 30
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 3
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn40{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 40
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 4
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn50{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 50
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 5
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn60{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 60
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 6
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn70{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 70
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 7
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn80{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 80
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 8
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn90{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 90
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 9
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn100{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 100
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 10
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn110{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 110
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 11
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn120{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 120
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 12
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn130{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 130
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 13
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn140{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 140
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 14
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn150{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 150
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 15
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn160{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 160
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 16
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn170{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 170
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 17
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn180{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 180
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 18
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn190{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 190
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 19
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
            function tkn200{
                tag @s add damager
                scoreboard players remove @s sainne.soullink.dmgtaken 200
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run damage @s 20
                execute as @a[team=sainne.soullink.yellow,tag=!damager] run scoreboard players set @s sainne.soullink.dmgtaken 0
                tag @s remove damager
            }
        }
    }
    # Gapple detection functions!
    function gapple_update{
        <%%
            for (i=0; i<teams.length; i++) {
                emit(`execute if entity @s[team=sainne.soullink.${teams[i]}] run function sainne.soullink:as_players/gapple_update/${teams[i]}`)
            }
        %%>
    }
    # Gapple execution functions by team (if adding a team, append a function)
    dir gapple_update{
        function red{
            effect give @a[team=sainne.soullink.red] absorption 120 0 false
            effect give @a[team=sainne.soullink.red] regeneration 5 1 false
            scoreboard players set @s sainne.soullink.gapple 0
        }
        function blue{
            effect give @a[team=sainne.soullink.blue] absorption 120 0 false
            effect give @a[team=sainne.soullink.blue] regeneration 5 1 false
            scoreboard players set @s sainne.soullink.gapple 0
        }
        function green{
            effect give @a[team=sainne.soullink.green] absorption 120 0 false
            effect give @a[team=sainne.soullink.green] regeneration 5 1 false
            scoreboard players set @s sainne.soullink.gapple 0
        }
        function yellow{
            effect give @a[team=sainne.soullink.yellow] absorption 120 0 false
            effect give @a[team=sainne.soullink.yellow] regeneration 5 1 false
            scoreboard players set @s sainne.soullink.gapple 0
        }
    }
    # EGapple detection functions!
    function egapple_update{
        <%%
            for (i=0; i<teams.length; i++) {
                emit(`execute if entity @s[team=sainne.soullink.${teams[i]}] run function sainne.soullink:as_players/egapple_update/${teams[i]}`)
            }
        %%>
    }
    # EGaaple execution functions by team (if adding a team, append a function)
    dir egapple_update{
        function red{
            effect give @a[team=sainne.soullink.red] absorption 120 3 false
            effect give @a[team=sainne.soullink.red] regeneration 20 1 false
            effect give @a[team=sainne.soullink.red] fire_resistance 300 0 false
            effect give @a[team=sainne.soullink.red] resistance 300 0 false
            scoreboard players set @s sainne.soullink.egapple 0
        }
        function blue{
            effect give @a[team=sainne.soullink.blue] absorption 120 3 false
            effect give @a[team=sainne.soullink.blue] regeneration 20 1 false
            effect give @a[team=sainne.soullink.blue] fire_resistance 300 0 false
            effect give @a[team=sainne.soullink.blue] resistance 300 0 false
            scoreboard players set @s sainne.soullink.egapple 0
        }
        function green{
            effect give @a[team=sainne.soullink.green] absorption 120 3 false
            effect give @a[team=sainne.soullink.green] regeneration 20 1 false
            effect give @a[team=sainne.soullink.green] fire_resistance 300 0 false
            effect give @a[team=sainne.soullink.green] resistance 300 0 false
            scoreboard players set @s sainne.soullink.egapple 0
        }
        function yellow{
            effect give @a[team=sainne.soullink.yellow] absorption 120 3 false
            effect give @a[team=sainne.soullink.yellow] regeneration 20 1 false
            effect give @a[team=sainne.soullink.yellow] fire_resistance 300 0 false
            effect give @a[team=sainne.soullink.yellow] resistance 300 0 false
            scoreboard players set @s sainne.soullink.egapple 0
        }
    }
    # Death detection functions!
    function death_update{
        <%%
            for (i=0; i<teams.length; i++) {
                emit(`execute if entity @s[team=sainne.soullink.${teams[i]}] run function sainne.soullink:as_players/death_update/${teams[i]}`)
            }
        %%>
    }
    # Death execution functions by team (if adding a team, append a function)
    dir death_update{
        function red{
            kill @a[team=sainne.soullink.red]
            scoreboard players set @a[team=sainne.soullink.red] sainne.soullink.dmgtaken 0
            scoreboard players set @s sainne.soullink.death 0
        }
        function blue{
            kill @a[team=sainne.soullink.blue]
            scoreboard players set @a[team=sainne.soullink.blue] sainne.soullink.dmgtaken 0
            scoreboard players set @s sainne.soullink.death 0
        }
        function green{
            kill @a[team=sainne.soullink.green]
            scoreboard players set @a[team=sainne.soullink.green] sainne.soullink.dmgtaken 0
            scoreboard players set @s sainne.soullink.death 0
        }
        function yellow{
            kill @a[team=sainne.soullink.yellow]
            scoreboard players set @a[team=sainne.soullink.yellow] sainne.soullink.dmgtaken 0
            scoreboard players set @s sainne.soullink.death 0
        }
    }
}