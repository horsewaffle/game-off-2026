class_name Enemy
extends Entity

signal xp_awarded(amount: int)
signal turn_finished

var floor_number: int = 1


func _ready() -> void:
	var health = FloorDifficulty.get_enemy_health(20, floor_number)
	var attack_power = FloorDifficulty.get_enemy_attack(20, floor_number)
	fightable = Fightable.new(health, attack_power, 5, 1, 20)
	fightable.dead.connect(_on_death)
	$"Enemy/HealthBar".initialise_health_bar()
	self.on_interact = on_interact_dead


func _on_death() -> void:
	xp_awarded.emit(fightable.xp)
	self.fightable = null
	self.searchable = Searchable.new(["stick"])
	self.walkable = true
	remove_from_group("turn_listener")


func on_interact_dead():
	return searchable


func take_turn():
	if fightable == null:
		return

	can_take_action = true
	if adjacent_fightables.size() > 0:
		var target = adjacent_fightables.pick_random()
		look_at(target.position)
		target.fightable.receive_damage(self.fightable.attack)
		end_turn()
	else:
		var offset = [Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)].pick_random()
		var target_pos = Vector2i(roundi(position.x), roundi(position.z)) + offset
		look_at(Vector3(target_pos.x, 0, target_pos.y))
		turn_requested.emit(self, target_pos, "move")
		if can_take_action:
			await turn_finished


func end_turn():
	can_take_action = false
	turn_finished.emit()
