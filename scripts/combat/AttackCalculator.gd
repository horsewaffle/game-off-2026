class_name AttackCalculator
extends RefCounted

signal calculation_complete(damage: int)

func calculate(base_damage: int, cards: Array) -> void:
	var damage: int = clampi(base_damage, 0, 255)
	
	for card in cards:
		damage = clampi(card.activate(damage), 0, 255) # clamping to 8-bit for now
	
	calculation_complete.emit(damage)
