extends Control

@export_file("*.tscn") var first_level_scene: String = "res://scenes/level_1.tscn"

@onready var play_button: Button = %PlayButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	play_button.grab_focus()

func _on_play_pressed() -> void:
	var error = get_tree().change_scene_to_file(first_level_scene)
	if error != OK:
		print("Error: Failed to load level scene at path: ", first_level_scene)

func _on_quit_pressed() -> void:
	get_tree().quit()
