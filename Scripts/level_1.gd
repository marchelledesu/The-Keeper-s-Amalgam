# level_1.gd
extends Node2D

@export var level_complete_scene: PackedScene = preload("res://Scenes/level_complete_menu.tscn")

@onready var goal_area: Area2D = $Goal

var player_in_goal: bool = false
var level_complete_menu: CanvasLayer = null

func _ready() -> void:
	if goal_area:
		goal_area.body_entered.connect(_on_goal_area_body_entered)
		goal_area.body_exited.connect(_on_goal_area_body_exited)
		print("Goal area 'goal' connected successfully.")
	else:
		print("ERROR: Node named 'goal' not found! Make sure your goal Area2D is named exactly 'goal' in the scene tree.")
	
	if level_complete_scene:
		level_complete_menu = level_complete_scene.instantiate() as CanvasLayer
		if level_complete_menu:
			add_child(level_complete_menu)
			print("Level complete menu instanced successfully.")

func _on_goal_area_body_entered(body: Node2D) -> void:
	if body.name.to_lower() == "player":
		player_in_goal = true
		print("Player entered 'goal'. Press UP.")

func _on_goal_area_body_exited(body: Node2D) -> void:
	if body.name.to_lower() == "player":
		player_in_goal = false
		print("Player left 'goal'.")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		print("GLOBAL INPUT: ui_up pressed! Player in goal: ", player_in_goal)
		if player_in_goal:
			if level_complete_menu and level_complete_menu.has_method("show_complete_screen"):
				print("Triggering level complete screen!")
				level_complete_menu.show_complete_screen()
			else:
				print("ERROR: level_complete_menu reference is missing or lacks show_complete_screen().")
