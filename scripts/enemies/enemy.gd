class_name Enemy
extends Entity

@onready var board = $"../Board"

func _ready() -> void:
	fightable = Fightable.new(100, 20)
