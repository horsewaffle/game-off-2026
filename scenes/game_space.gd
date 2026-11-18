extends Node3D

@onready var board = $Board
@onready var player = $PlayerCharacter
@onready var enemy = $Enemy

var attack_calculator = AttackCalculator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var player_registered: bool = board.register_entity(player)
	
	if not player_registered:
		push_error("Failed to register PlayerCharacter with Board")
	
	var enemy_registered: bool = board.register_entity(enemy)
	
	if not enemy_registered:
		push_error("Failed to register Enemy with Board")
		
	# ADAM I connected the signal through gamespace for damage application maybe?
	# feel free to not do this if you had a different idea
	attack_calculator.calculation_complete.connect(_on_calculation_complete)
	
	attack_calculator.calculate(25, [])
	
func _on_calculation_complete(damage: int) -> void:
	print("final attack damage = ", damage)
	
	enemy.xp_awarded.connect(player.gain_xp)
