class_name MoveResult

enum MoveEnum { SUCCESS, FAIL, INTERACT, INTERACT_AND_MOVE }

var result: MoveEnum
var pos: Variant = null


func _init(resEnum: MoveEnum, pos: Variant = null) -> void:
	self.result = resEnum
	self.pos = pos
	assert(pos == null or pos is Vector2i)
