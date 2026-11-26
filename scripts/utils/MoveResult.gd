class_name MoveResult

enum MoveEnum { SUCCESS, FAIL, INTERACT, INTERACT_AND_MOVE }

var result: MoveEnum
var pos: Variant = null
var occupant: Node3D = null

func _init(resEnum: MoveEnum, resPos: Variant = null, resOccupant: Node3D = null) -> void:
	self.result = resEnum
	self.pos = resPos
	self.occupant = resOccupant
	assert(pos == null or pos is Vector2i)
