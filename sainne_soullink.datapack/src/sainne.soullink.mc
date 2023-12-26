# Function that runs upon reload, if the datapack has been installed
# dont run the initial setup again
function load{
    scoreboard objectives add sainne.soullink.global dummy
    execute unless score installed sainne.soullink.global matches 1 run function sainne.soullink:.install
    tellraw @a [{"text":"Soul","color": "green"},{"text":"-💙-","color":"red"},{"text":"Link","color":"yellow"},{"text":" has been reloaded!","color":"gold"}]
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
    # execute as @a run function sainne.soullink:as_players/first_join
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
    }
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
    # Damage detection functions
    dir damage_update{
        # Team red estimate damage interval
        function red{
            execute as @a[team=sainne.soullink.red,scores={sainne.soullink.dmgtaken=1..5}] run function sainne.soullink:as_players/damage_update/red/tkn1
            <%%
                intervalos = [5,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180,190]
                for (let i=1; i<intervalos.length; i++) {
                    let inferior = intervalos[i-1] + 1
                    let superior = intervalos[i]
                    emit(`execute as @a[team=sainne.soullink.red,scores={sainne.soullink.dmgtaken=${inferior}..${superior}}] run function sainne.soullink:as_players/damage_update/red/tkn${superior}`)
                }
            %%>
            execute as @a[team=sainne.soullink.red,scores={sainne.soullink.dmgtaken=191..}] run function sainne.soullink:as_players/damage_update/red/tkn200
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
            execute as @a[team=sainne.soullink.blue,scores={sainne.soullink.dmgtaken=1..5}] run function sainne.soullink:as_players/damage_update/blue/tkn1
            <%%
                intervalos = [5,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180,190]
                for (let i=1; i<intervalos.length; i++) {
                    let inferior = intervalos[i-1] + 1
                    let superior = intervalos[i]
                    emit(`execute as @a[team=sainne.soullink.blue,scores={sainne.soullink.dmgtaken=${inferior}..${superior}}] run function sainne.soullink:as_players/damage_update/blue/tkn${superior}`)
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
            execute as @a[team=sainne.soullink.green,scores={sainne.soullink.dmgtaken=1..5}] run function sainne.soullink:as_players/damage_update/green/tkn1
            <%%
                intervalos = [5,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180,190]
                for (let i=1; i<intervalos.length; i++) {
                    let inferior = intervalos[i-1] + 1
                    let superior = intervalos[i]
                    emit(`execute as @a[team=sainne.soullink.green,scores={sainne.soullink.dmgtaken=${inferior}..${superior}}] run function sainne.soullink:as_players/damage_update/green/tkn${superior}`)
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
            execute as @a[team=sainne.soullink.yellow,scores={sainne.soullink.dmgtaken=1..5}] run function sainne.soullink:as_players/damage_update/yellow/tkn1
            <%%
                intervalos = [5,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180,190]
                for (let i=1; i<intervalos.length; i++) {
                    let inferior = intervalos[i-1] + 1
                    let superior = intervalos[i]
                    emit(`execute as @a[team=sainne.soullink.yellow,scores={sainne.soullink.dmgtaken=${inferior}..${superior}}] run function sainne.soullink:as_players/damage_update/yellow/tkn${superior}`)
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
    # Gapple execution functions by team
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
    # EGaaple execution functions by team
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
    # Death execution functions by team
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