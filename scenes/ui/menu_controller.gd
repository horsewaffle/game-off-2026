extends Control

var fade: bool = false
var fade_percent: float = 0
var fade_context: Callable

@onready
var start_button: Button = $Background/ContentContainerContainer/ContentContainer/StartButton

@onready
var quit_button: Button = $Background/ContentContainerContainer/ContentContainer/QuitButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.start_button_pressed.connect(_on_start_button_pressed)
	quit_button.quit_button_pressed.connect(_on_quit_button_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if fade and fade_percent < 1:
		fade_percent += delta
		set_modulate(lerp(get_modulate(), Color(0.0, 0.0, 0.0, 1.0), fade_percent))
	elif !fade and fade_percent > 0:
		fade_percent -= delta
		set_modulate(lerp(get_modulate(), Color(0.0, 0.0, 0.0, 1.0), fade_percent))
		
	if fade and fade_percent >= 1:
		fade_context.call()
	
func _on_start_button_pressed():
	fade = true
	fade_context = start_game_scene
	
func start_game_scene():
	get_tree().change_scene_to_packed(load("res://scenes/game_space.tscn"))
	
func _on_quit_button_pressed():
	get_tree().quit()
