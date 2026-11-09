class_name Fightable
extends RefCounted

var health: int
var attack: int
var defence: int
var mult: float

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
