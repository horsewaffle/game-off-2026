class_name Fightable
extends RefCounted

var health: int
var attack: int
var defence: int
var mult: float

signal health_updated(new_health: int)
signal dead

func _init(
	resHealth: int,
	resAttack: int,
	resDefence: int,
	resMult: float
	) -> void:
	self.health = resHealth
	self.attack = resAttack
	self.defence = resDefence
	self.mult = resMult

func death_check() -> bool:
	return self.health <= 0

func receive_damage(amount: int):
	# Basic implementation of defence metric, subject to change.
	# This will subtract the defence from the incoming attack,
	# but the damage blocked is capped at half of the incoming attack damage
	var processed_amount = amount - min(self.defence, amount / 2)
	print("received ", processed_amount, " damage")
	
	self.health -= min(self.health, processed_amount)
	print(self.health, " remaining")
	
	health_updated.emit(self.health)
	if death_check():
		dead.emit()

	
