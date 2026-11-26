# BitRift

BitRift (working title) will be a top-down, Mystery Dungeon-esque dungeon crawler - presumably roguelike and infinite as the gameplay naturally limits itself with scaling. The main gameplay loop will revolve around fighting enemies and grabbing loot. The unique selling point is in the combat:

- players have a weapon with a binary number attached. This number might be defined by the weapon itself, or some form of socket-able "gem"
- when the character attacks, the base damage is set at this number.
- during an "attack", players have the opportunity to play a number of cards (defined by the weapon) from a customisable deck to augment the attack.
- the cards in the player's deck will consist of bitwise operations: bitshifting, rotating, or masking. This allows the player to increase their attack damage, and provides an opportunity for the game to scale by providing "stronger" (shift further, mask a more significant bit) and rarer cards as it progresses. Card effects only last for the duration of that attack, and are discarded from the deck (to be replenished either at the end of combat or the end of the "floor" of the dungeon)
- the loot pool should provide cards to add to the deck, along with permanent augments to weapons, or upgrades to deck cards (think Balatro arcana/planet cards). Some potential examples include summing the 1s in the final damage stat for a bonus effect, or triggering an effect when a 1 is in a certain bit. This encourages players to build more complex decks than just "higher number == better". Additionally, it opens the door for diversifying combat - e.g. damage types/resistances, if this is in scope.
- as the player progresses, they should naturally become stronger, and so the world should also progress to match this and provide an eventual lose condition rather than an intended end state.
- the world should be interacted with as a turn based dungeon crawler. When adjacent to an enemy, combat starts, providing additional UI elements to facilitate this. As a stretch goal, a turn in combat could continue to simulate the dungeon, leading to more enemies piling in, etc.
