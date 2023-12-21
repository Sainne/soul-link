#obtain what the highest hp is for every team
function sainne.soullink:computations/highest_hp/red
function sainne.soullink:computations/highest_hp/blue

#obtain the difference to the max hp for every team
function sainne.soullink:computations/hp_diff/red
function sainne.soullink:computations/hp_diff/blue

#heal updates
execute as @a[scores={sainne.soullink.dmgtaken=..0}] run function sainne.soullink:heal_update/main

schedule function sainne.soullink:update/50tick 50t replace