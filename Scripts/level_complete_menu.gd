extends CanvasLayer

@export_file("*.tscn") var next_level_scene: String = "res://Scenes/level_2.tscn"
@export_file("*.tscn") var main_menu_scene: String = "res://Scenes/main_menu.tscn"

@onready var next_button: Button = %NextLevelButton
@onready var menu_button: Button = %MenuButton

func _ready() -> void:
	visible = false
	next_button.pressed.connect(_on_next_level_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func show_complete_screen() -> void:
	print("Level Complete Menu displayed successfully!")
	visible = true
	get_tree().paused = true
	next_button.grab_focus()

func _on_next_level_pressed() -> void:
	get_tree().paused = false
	var error = get_tree().change_scene_to_file(next_level_scene)
	if error != OK:
		print("Error: Failed to load next level: ", next_level_scene)

func _on_menu_pressed() -> void:
	get_tree().paused = false
	var error = get_tree().change_scene_to_file(main_menu_scene)
	if error != OK:
		print("Error: Failed to load main menu: ", main_menu_scene)
