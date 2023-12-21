#obtain what the highest hp is for every team
function sainne.soullink:computations/highest_hp/red

#obtain the difference to the max hp for every team
function sainne.soullink:computations/hp_diff/red

#heal updates
execute as @a[team=sainne.soullink.red,scores={sainne.soullink.dmgtaken=..0}] run function sainne.soullink:heal_update/red/main

schedule function sainne.soullink:update/50tick 50t replace