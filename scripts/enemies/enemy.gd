class_name Enemy
extends Entity

signal xp_awarded(amount: int)

func _ready() -> void:
	fightable = Fightable.new(20, 20, 5, 1, 20)
	# (health, attack, defence, mult, xp)
	
	fightable.dead.connect(_on_death)
	$"HealthBar".initialise_health_bar()
	
func _on_death() -> void:
	print(self, " died!")
	xp_awarded.emit(fightable.xp)
	self.fightable = null
	self.searchable = Searchable.new(["stick"])
	self.walkable = true
	remove_from_group("turn_listener")
	
func take_turn():
	
	var offset = [Vector2i(1,0), Vector2i(0,1), Vector2i(-1,0), Vector2i(0,-1)].pick_random()
	# the below is stationary mode. uncomment the below and comment the above if you want to disable enemy movement
	#var offset = [Vector2i(0,0), Vector2i(0,0), Vector2i(0,0), Vector2i(0,0)].pick_random()
	@warning_ignore("narrowing_conversion")
	var target_pos = Vector2i(position.x, position.z) + offset
	turn_requested.emit(self, target_pos, "move")
