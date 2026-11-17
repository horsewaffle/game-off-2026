class_name Entity
extends Node3D

# Make a request to perform a turn-consuming action to the Orchestrator.
@warning_ignore("unused_signal")
signal turn_requested(origin: Node3D, pos: Vector2i, default_action: String)

# Request information from the orchestrator.
@warning_ignore("unused_signal")
signal request_information(origin: Node3D, packet: Dictionary)

# Disables input from this Entity when it's not their turn.
# Only really useful for the player, but...
var can_take_action = false

# Set by Orchestrator if Entity starts a turn next to a Fightable Entity, useful for combat logic
var is_adjacent_to_fightable = false

var on_interact: Callable = Callable()
var fightable: Fightable = null
var searchable: Searchable = null
var walkable: bool = false

func _init(
	resOn_interact: Callable = Callable(),
	capFightable: Fightable = null,
	capSearchable: Searchable = null,
	capWalkable: bool = false
	) -> void:
		self.on_interact = resOn_interact
		self.fightable = capFightable
		self.searchable = capSearchable
		self.walkable = capWalkable

func take_turn():
	pass
	
func end_turn():
	pass

# When an entity tries to perform an action, but the Orchestrator does not
# allow it, handle the alternative action.
# e.g. request a move to a tile where an Entity already is => attack instead
# A lot of these are barebones as most Entities can't interact like the player can.
func handle_turn_response(result, pos, pos_entity: Entity = null):
	match(result):
		MoveResult.MoveEnum.INTERACT_AND_MOVE:
			move(pos)
		MoveResult.MoveEnum.INTERACT:
			pass
		MoveResult.MoveEnum.FAIL:
			pass

func move(target_pos: Vector2i):
	self.position = Vector3(target_pos.x, 0, target_pos.y)

func interact(_pos: Vector2i, _pos_entity: Entity = null):
	pass
	
func attack(entity: Entity):
	pass
