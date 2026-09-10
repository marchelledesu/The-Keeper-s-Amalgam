# goal.gd
extends Area2D

@export_file("*.tscn") var next_scene: String
var player_inside: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if _is_player(body):
		player_inside = true
		print("Press UP to complete the level!")

func _on_body_exited(body: Node2D) -> void:
	if _is_player(body):
		player_inside = false

func _unhandled_input(event: InputEvent) -> void:
	if player_inside and event.is_action_pressed("ui_up"):
		print("LEVEL COMPLETE!")
		if next_scene:
			get_tree().change_scene_to_file(next_scene)
		else:
			get_tree().paused = true # Freezes the game if no next scene is set

func _is_player(body: Node2D) -> bool:
	return body.is_in_group("player") or body.name == "Player" or (body.has_method("get_parent") and body.get_parent().name == "Player")
