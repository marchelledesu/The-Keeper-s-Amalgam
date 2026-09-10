# door.gd
extends AnimatableBody2D

@export var open_offset: Vector2 = Vector2(0, -64) # How far and which direction the door moves (e.g., 64 pixels up)
@export var move_duration: float = 0.4

@onready var closed_position: Vector2 = position
@onready var open_position: Vector2 = position + open_offset

var current_tween: Tween

func open() -> void:
	if current_tween and current_tween.is_running():
		current_tween.kill()
	
	current_tween = create_tween().set_parallel(false)
	current_tween.tween_property(self, "position", open_position, move_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func close() -> void:
	if current_tween and current_tween.is_running():
		current_tween.kill()
	
	current_tween = create_tween().set_parallel(false)
	current_tween.tween_property(self, "position", closed_position, move_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


func _on_pressure_plate_activated() -> void:
	pass # Replace with function body.


func _on_pressure_plate_deactivated() -> void:
	pass # Replace with function body.
