extends Button

signal quit_button_pressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Start the game.
func _pressed():
	quit_button_pressed.emit()
