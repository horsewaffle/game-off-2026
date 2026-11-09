class_name Fightable
extends RefCounted

var health: int
var attack: int

func _init(resHealth: int, resAttack: int) -> void:
	self.health = resHealth
	self.attack = resAttack
