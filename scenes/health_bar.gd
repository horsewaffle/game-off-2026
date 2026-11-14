extends ProgressBar

var camera: Camera3D

@onready
var parent_enemy: Enemy = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera = get_viewport().get_camera_3d()
	if parent_enemy.fightable != null:
		initialise_health_bar()
	else:
		visible = false
		

func initialise_health_bar() -> void:
	camera = get_viewport().get_camera_3d()
	max_value = parent_enemy.fightable.health
	value = parent_enemy.fightable.health
	parent_enemy.fightable.health_updated.connect(_on_health_updated)
	visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var screen_pos = camera.unproject_position(get_parent().global_position + Vector3(0, 1.5, 0)) 
	global_position = screen_pos
	global_position += Vector2(-get_rect().size.x / 2, 0)

func _on_health_updated(new_health: int):
	value = new_health
