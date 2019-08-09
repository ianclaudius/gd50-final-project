# gd50-final-project

Welcome to my final project for Harvard’s CSCI S-23a (GD50) final project, which extends my Super 50 Bros. implementation with a boss level and several quality of life improvements. Let’s start with the latter:

* I’ve squashed some bugs, sanded down some corner cases, and tweaked some of the level generation conditionals to prevent the occasional “impossible” levels from spawning—for example a lock being “boxed in” by other elements.

* You can now press “W” to simply Warp to the next level. While this sort of functionality would probably be hidden or absent from a public-shipping game, in the meantime it will make our lives as testers and debuggers much easier.

* Rather than death leading to the end of the game and starting from scratch, the player instead gets to continue where they left off—albeit sacrificing half their score as a penalty.

## “Queen Bee” Boss Fight

Every fourth level, the player enters a “boss level” indicated by a danger sign, new soundtrack, and a chase. The boss will spawn additional smaller bees to attack the player. Eventually you’ll back them into a corner, and upon defeat, a goal will spawn to progress.

That first encounter isn’t too difficult, but bear in mind that the boss scales with higher levels, generating more bees and becoming harder and harder to overcome.

Will you conquer the hive? And more importantly: *will you do it with style?*
