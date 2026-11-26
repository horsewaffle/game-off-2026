class_name AttackCalculator
extends RefCounted

static func calculate(base_damage: int, cards: Array) -> int:
	var damage: int = clampi(base_damage, 0, 255)
	
	for card: Card in cards:
		damage = clampi(card.activate(damage), 0, 255) # clamping to 8-bit for now
		print("damage modified to ", damage)
	
	return damage
