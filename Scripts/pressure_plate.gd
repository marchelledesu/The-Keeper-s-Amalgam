# pressure_plate.gd
extends Area2D

signal activated
signal deactivated

@onready var static_body: StaticBody2D = $StaticBody2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D # Fixed path to point directly to the sprite
@onready var detection_shape: CollisionShape2D = $CollisionShape2D

var is_pressed: bool = false
var current_tween: Tween

@export var press_offset: Vector2 = Vector2(0, 4) # How far down the physical platform sinks
@export var anim_duration: float = 0.12

@onready var unpressed_pos: Vector2 = static_body.position if static_body else Vector2.ZERO
@onready var pressed_pos: Vector2 = unpressed_pos + press_offset

func _ready() -> void:
	print(">>> PressurePlate script is officially running!")

func _physics_process(_delta: float) -> void:
	var slimes = get_tree().get_nodes_in_group("slime")
	if slimes.is_empty():
		slimes = get_tree().get_nodes_in_group("Slime")
	
	if slimes.is_empty():
		for node in get_tree().current_scene.find_children("*slime*", "", true, false):
			if not slimes.has(node):
				slimes.append(node)
	
	var slime_touching: bool = false
	
	if not slimes.is_empty():
		for slime in slimes:
			if not is_instance_valid(slime):
				continue
			
			if overlaps_body(slime):
				slime_touching = true
				break
			
			if slime.has_method("get_children"):
				for child in slime.get_children():
					if child is Node2D and detection_shape:
						if _is_point_inside_plate_shape(child.global_position):
							slime_touching = true
							break
		
	if slime_touching and not is_pressed:
		_set_pressed_state(true)
	elif not slime_touching and is_pressed:
		_set_pressed_state(false)

func _is_point_inside_plate_shape(global_pt: Vector2) -> bool:
	if not detection_shape or not detection_shape.shape:
		return false
	
	var local_pt = detection_shape.to_local(global_pt)
	var shape = detection_shape.shape
	
	if shape is RectangleShape2D:
		var extents = shape.size / 2.0
		return abs(local_pt.x) <= extents.x and abs(local_pt.y) <= extents.y
	elif shape is CircleShape2D:
		return local_pt.length() <= shape.radius
		
	return global_position.distance_to(global_pt) <= 30.0

func _set_pressed_state(new_state: bool) -> void:
	if is_pressed == new_state:
		return
		
	is_pressed = new_state
	
	if current_tween and current_tween.is_running():
		current_tween.kill()
		
	current_tween = create_tween().set_parallel(true)
	
	if is_pressed:
		print("ACTIVATION CONFIRMED: Pressure plate is ACTIVATED!")
		if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("pressed"):
			sprite.play("pressed")
			
		if static_body:
			current_tween.tween_property(static_body, "position", pressed_pos, anim_duration)\
				.set_trans(Tween.TRANS_BACK)\
				.set_ease(Tween.EASE_OUT)
			
		emit_signal("activated")
	else:
		print("ACTIVATION CONFIRMED: Pressure plate is DEACTIVATED!")
		if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("unpressed"):
			sprite.play("unpressed")
		elif sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("default"):
			sprite.play("default")
			
		if static_body:
			current_tween.tween_property(static_body, "position", unpressed_pos, anim_duration)\
				.set_trans(Tween.TRANS_SPRING)\
				.set_ease(Tween.EASE_OUT)
			
		emit_signal("deactivated")
