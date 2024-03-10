# untitled game

This repo contains my entry for [Acerola Jam 0](https://itch.io/jam/acerola-jam-0). The theme of this game jam is `Aberration`.

# random notes

-   I'm using this game jam not to win, but to learn godot.
-   The engine used will be [Godot 4.2.1](https://godotengine.org/), because I see no point in learning old ass godot3. New is good. I like new.
-   The language used will be GDScript, because ["Projects written in C# using Godot 4 currently cannot be exported to the web"](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html).
-   Export target will be Web, because it seems like easy way to make multiplatform game.
-   Seems like default viewport settings on itch.io is 640x360px. Sounds good, I'll hardcode this resolution.
-   It is solo game jam, so the game will be 2D, made in mspaint. It's great that this is solo jam, as I have no friends.

# world and constraints

Currently, game dev progress may seem smooth, but it lacks direction. This game is nothing more than a bunch of random ideas, as it lacks glue to connect everything. I will now define a world. This world is here not to provide a story, but to provide constraints. By outlining the characters and rules within this world, we can better determine the end goal of this game.

As a disclaimer: almost all of this story will not be present in the game itself, as it is nothing more than a mold to make the game take a shape.

### story:

Four magic students have been living together in conflict for many years. Their names are: Gerward, Bimbolious, Bert, and Roger Moore. They study magic under the watchful eye of the archmage Rombobombolini. One day, their rivalry reached its peak during a quarrel in a tavern, resulting in Bert getting a beer mug to the head and ending up with a black eye. To prevent further incidents like this in the future, Archmage Rombobombolini persuaded his students to settle all disputes once and for all with a magical tournament.

The rules of the magical tournament are simple. Each of the four young wizards will place their familiar in Rombobombolini's magical sphere (called Little Garden). Time inside Little Garden flows differently; while a second passes in reality, years go by in Little Garden. The winner of the tournament will be the mage whose familiar survives the longest. The tournament winner will be officially recognized by the other three mages as the big shot, and the rest can't do anything about it. Each wizard can use one spell on their familiar before placing it in Little Garden. To prevent cheating, Archmage Rombobombolini will personally supervise Little Garden.

Gerard's familiar is a boar named Boaris. He used a spell to increase its resistance to physical attacks.

Bimbolious's familiar is a spider named Webster. She used a spell to increase its speed.

Bert's familiar is a snake named Sneksquik. He used a spell for life regeneration.

Roger Moore's familiar is an ocelot named Momo. He used a spell to increase its physical strength.

After placing the familiars in Little Garden, Rombobombolini sealed the magical sphere so time could accelerate. However, secretly Rombobombolini used more than one spell! Rombobombolini's goal is for all his students to lose. Their teacher wants to teach them a lesson and show them that the world is bigger and more unpredictable than they think. And as an added extra bonus, it will give him the opportunity to exchange his students' hopeless (soon to be dead) familiars for some cool mythical beasts, because honestly, Boar, Spider, Snake, and Ocelot bring shame to him as a teacher.

The exact definition of the game rules written by Rombobombolini is that the tournament in Little Garden ends when only one Spiritual Beast is alive. A wizard wins the tournament if the remaining Spiritual Beast alive is their familiar. So, to make sure each of the four wizards fails, all Rombobombolini needs to do is place one more Spiritual Beast in the game.

Rombobombolini blindly shot his arch-magical spell, hitting a random beast. This beast was surrounded by necromantic death magic. When the beast dies, time in the entire Little Garden will rewind until the moment the beast was first hit by this spell. Considering the vastly accelerated time inside Little Garden, this beast is guaranteed to gain consciousness sooner or later and transform into a Spiritual Beast. Then it's downhill from there because since the new beast cannot die, it physically cannot lose this bet. In other words, Rombobombolini ensured that all four familiars of his students would die.

Rombobombolini's spell hit a little ocelot kitten. As it happens, this kitten lived in a pack led by Momo (the familiar). As a Spiritual Beast, Momo is intelligent and immediately senses that something is wrong with the kitten; he feels the aura of death from it. However, Momo cannot bring himself to kill the little ocelot, so he leaves it alive. Momo names the little kitten Purr Purr and allows it to do as it pleases. Unfortunately, the powerful aura of death surrounding Purr Purr makes other ocelots unfriendly towards him. Purr Purr must hunt and take care of his own life without any help from the pack.

The player's beast is Purr Purr.

The game can only end in one way: Rombobombolini's victory. Either Purr Purr kills all the other familiars and wins the tournament, or time in Little Garden loops until eventually Purr Purr lives long enough that all other familiars die of old age.
