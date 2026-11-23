extends Button

signal start_button_pressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Start the game.
func _pressed():
	start_button_pressed.emit()
