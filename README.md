# untitled game

This repo contains my entry for [Acerola Jam 0](https://itch.io/jam/acerola-jam-0). The theme of this game jam is `Aberration`.

# random notes

-   I'm using this game jam not to win, but to learn godot.
-   The engine used will be [Godot 4.2.1](https://godotengine.org/), because I see no point in learning old ass godot3. New is good. I like new.
-   The language used will be GDScript, because ["Projects written in C# using Godot 4 currently cannot be exported to the web"](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html).
-   Export target will be Web, because it seems like easy way to make multiplatform game.
-   Seems like default viewport settings on itch.io is 640x360px. Sounds good, I'll hardcode this resolution.
-   It is solo game jam, so the game will be 2D, made in mspaint. It's great that this is solo jam, as I have no friends.

# todo

-   ~~terrain tileset: grass, dirt, water~~
-   ~~player animation: movement~~
-   player animation: attack
-   player animation: death
-   object: tree (few variants)
-   object: bush (few variants)
-   critter: bird
-   critter: mouse
-   critter ai: run way based on line of sight
-   player ai: focus on nearest point of interest (enemy > critter > object) and face towards poi. else face forward
-   player ai: facial expressions based on health, pain, mood
-   collectable food: berries (from destroyed bushes) meat (from critters)
-   facial animation for eating (restores health over time)
-   render collected food items on player's back. eating removes items. getting hit scatters items
-   player ai: there is limited carry capacity, the beast will decide what food items to pick up and what throw away
-   make player grow over time if feed well, increasing health and damage dealt
-   make respawn animation where player hatches from egg and his parents chase him away
-   create recolor shader to make player look different from its spiecies and parents
-   critters and enemies should use the same ai, based on size difference between creature and player decide when to attack and when to run away
-   create more enemies with various size (maybe boar, stag, giant snake)
-   swimming for player and creatures (sprite mask, slower movement). swimming based on points connected to feet, if all feet touch water tile then swim otherwise walk with water splatter particles. bigger creatures will be able to walk on bigger bodies of water.

# notes

right now this looks like sandbox, other than exploration there is no goal.
defeating stronger enemies, growing, defeating bosses may be considered a goal, but right now player lacks incentive to do so.
