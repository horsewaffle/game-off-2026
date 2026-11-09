class_name Entity
extends Node3D

var on_interact: Callable = Callable()
var fightable: Fightable = null
var searchable: Searchable = null
var walkable: bool = false


func _init(
	resOn_interact: Callable = Callable(),
	capFightable: Fightable = null,
	capSearchable: Searchable = null,
	capWalkable: bool = false
	) -> void:
		self.on_interact = resOn_interact
		self.fightable = capFightable
		self.searchable = capSearchable
		self.walkable = capWalkable

func take_turn():
	pass
