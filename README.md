# Soul-💙-Link
A Minecraft datapack, about linking your soul to other players.
# Main Mechanic 💞
- The health from players in a team is shared between all members from that team
- When a player from a team receives damage, every player from that same team receives the same amount of damage
- If no player from the team has received damage then all players will heal up until reaching the player with the most amount of HP
- If a player from a team obtains absorption then all players from the team receive the effect as well
- If a player from a team dies then all players from that team die as well.
- To join a team and sync souls use "/team join sainne.soullink.\<color\> \<player\>"
# How to use and play (quick start guide)
- First use "/function sainne.soullink:.settings" ro configure your game and assign max number of players and other values.
- Then click GO on that menu, all players will be spread out and assigned teams, and given a bundle
- Enjoy!
### Technicalities 🔧
- Since the datapack depends on events happening then disconnecting has potential for abuse, for example: a player from a team can disconnect while having max hp, and then reconnect to heal all players from their team up.
- And also infinite regeneration is possible if a player from a team has more max hp than every other player from that team.
- And if a player has more max HP than another then it is possible to die while having still HP left, since if one player from a team dies, then every other player from that team also dies.
- If a player from a team has a totem and receives lethal damage, killing a teammate in the process, then they die and lose the totem, this is partially intended, since saving a team from death should cost N totems, with the totems being in the off hand of every member(if every member from the team has a totem, then they are all spent and saved).
- Because of how regeneration works, the only possible value to heal exactly is 2hp, and 0.8hp, ended up deciding for the former for healing since health scoreboard uses int values(mojang give /heal command please and thank)
### Planned features 🧠
- 4 more teams, making a total of 8 teams!
# Credits and Inspiration! ✨
This datapack is built with the help of mc-build!, go show it some love:

[MC-Build's Github](https://github.com/mc-build)

This datapack is inspired first by the double life series made by Grian on Youtube:

[Double Life Episode 1](https://www.youtube.com/watch?v=UwFbtE4YS7g)

And also it is very much inspired by the "Shared Life" Datapack from "Boid":

[Shared Life datapack on modrinth](https://modrinth.com/datapack/shared-life/version/5LFVxkQW)

The reason for making this datapack comes from wanting synced health but with teams, as to not sync the health of all players on the server, and also making it so it works with any max hp, given that all players from a team have the same max hp. In the process there are some compromises however, stated in the technicalities above.