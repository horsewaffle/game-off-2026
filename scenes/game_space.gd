extends Node3D

@onready var board = $Board
@onready var player = $PlayerCharacter

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var registered: bool = board.register_entity(player)

	if not registered:
		push_error("Failed to register PlayerCharacter with Board")
