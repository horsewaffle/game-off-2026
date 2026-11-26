class_name PlayerCamera
extends Camera3D

# Time taken for the player to complete a move
const move_time = 0.3

# Where the camera should sit relative to the player
const offset = Vector3(0, 3, 2)

# Counter for how long a move has taken
var counter: float = 0

var is_moving = false
var target_pos: Vector3 = Vector3(0, 3, 2)
var old_pos: Vector3 = Vector3(0, 3, 2)

var player: PlayerController

func init_player_camera(init_player: PlayerController):
	player = init_player
	self.position = player.position + Vector3(0, 3, 2)
	self.rotation = Vector3(deg_to_rad(-50), 0, 0)
	
	player.camera_pos_updated.connect(_on_camera_pos_updated)
	current = true
	
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_moving and target_pos != null:
		counter += delta
		position = old_pos.lerp(target_pos, counter / move_time)
		# Force move to finish after move_time
		if counter >= move_time:
			is_moving = false
			position = target_pos
		
func set_target_orbited_position(pos: Vector3) -> void:
	is_moving = true
	counter = 0
	old_pos = position
	target_pos = pos + offset

func snap_to_player() -> void:
	is_moving = false
	counter = 0
	position = player.position + offset
	old_pos = position
	target_pos = position
	
func _on_camera_pos_updated(target_cam_pos: Vector2i):
	set_target_orbited_position(
		Vector3(
			target_cam_pos.x,
			0,
			target_cam_pos.y
		)
	)
