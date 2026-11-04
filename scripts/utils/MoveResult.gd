class_name MoveResult

enum MoveEnum { SUCCESS, FAIL, INTERACT, INTERACT_AND_MOVE }

var result: MoveEnum
var pos: Vector2

func _init(resEnum: MoveEnum, pos: Vector2) -> void:
	self.result = resEnum
	self.pos = pos
