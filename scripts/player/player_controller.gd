class_name PlayerController
extends Entity

signal enemy_turn_triggered

# Reference back to the Orchestrator for receiving signals
var orchestrator: Orchestrator

var xp: int

# Called by Orchestrator after instantiation, initialises player stats
# and passes reference to Orchestrator
func init_stats():
	# (max health, attack, defence, mult, xp)
	self.fightable = Fightable.new(200, 5, 10, 2.0, 0)


func _input(_event) -> void:
	
	# Logic for actions that are considered a turn - prevent user from getting
	# more than one action per enemy turn by disabling input until all enemies
	# are happy with their turn.
	#
	# ... this is just movement for now.
	if (can_take_action):
		# I wonder what would happen if you pressed two actions at the EXACT
		# same time?
		if Input.is_action_just_pressed("MOVE_UP"):
			request_tile(Vector2i(0, -1))
		if Input.is_action_just_pressed("MOVE_DOWN"):
			request_tile(Vector2i(0, 1))
		if Input.is_action_just_pressed("MOVE_LEFT"):
			request_tile(Vector2i(-1, 0))
		if Input.is_action_just_pressed("MOVE_RIGHT"):
			request_tile(Vector2i(1, 0))

func request_tile(offset_pos: Vector2i):
	
	@warning_ignore("narrowing_conversion")
	var target_pos = Vector2i(position.x, position.z) + offset_pos
	turn_requested.emit(self, target_pos, "move")

func handle_turn_response(result, pos, pos_entity: Entity = null):
	match(result.result):
		MoveResult.MoveEnum.INTERACT_AND_MOVE:
			print("INTERACT_AND_MOVE")
			interact(pos, pos_entity)
			move(pos)
		MoveResult.MoveEnum.INTERACT:
			print("INTERACT")
			interact(pos, pos_entity)
		MoveResult.MoveEnum.FAIL:
			pass
	
func interact(pos: Vector2i, pos_entity: Entity = null):
	print("interact")
	if pos_entity == null:
		pass
		
	if pos_entity.fightable != null:
		attack(pos_entity)
	else:
		var interact_return = pos_entity.on_interact.call()

func attack(entity: Entity):
	if entity.fightable != null:
		entity.fightable.receive_damage(self.fightable.attack)
		print("I dealt ", self.fightable.attack, " to ", entity)

func take_turn():
	if (is_adjacent_to_fightable):
		print("Adjacent to fightable, trigger combat UI")
	can_take_action = true
	
func end_turn():
	can_take_action = false
	await get_tree().create_timer(0.3).timeout
	enemy_turn_triggered.emit()

func gain_xp(amount: int) -> void:
	fightable.xp += amount
	print(amount, "xp added! I now have ", fightable.xp, " xp!")

	
