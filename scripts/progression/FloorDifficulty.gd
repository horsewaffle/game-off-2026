class_name FloorDifficulty
extends RefCounted

const max_enemies: int = 8
const floors_per_enemy: int = 2
const integer_limit: int = 9223372036854775807


static func get_enemy_count(floor_number: int) -> int:
	var completed_floors = maxi(floor_number - 1, 0)
	return mini(max_enemies, 1 + floori(float(completed_floors) / floors_per_enemy))


static func get_enemy_health(base_health: int, floor_number: int) -> int:
	var completed_floors = float(maxi(floor_number - 1, 0))
	var exponent = 0.04 * completed_floors + 0.006 * completed_floors * completed_floors
	return scale_stat(base_health, exponent)


static func get_enemy_attack(base_attack: int, floor_number: int) -> int:
	var completed_floors = float(maxi(floor_number - 1, 0))
	var exponent = 0.025 * completed_floors + 0.004 * completed_floors * completed_floors
	return scale_stat(base_attack, exponent)


static func scale_stat(base_value: int, exponent: float) -> int:
	var scaled_value = base_value * exp(exponent)
	if scaled_value >= float(integer_limit):
		return integer_limit
	return ceili(scaled_value)
