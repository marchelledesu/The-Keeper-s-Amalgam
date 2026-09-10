# player.gd (Attach to CharacterBody2D player)
extends CharacterBody2D

@export_category("Movement")
@export var speed: float = 300.0
@export var jump_velocity: float = -400.0

@export_category("Slime Throwing")
const SLIME_SCENE = preload("res://scenes/slime_weight.tscn")
@export var throw_force: float = 600.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite: Sprite2D = $Sprite2D
@onready var throw_point: Marker2D = $ThrowPoint
@onready var trajectory_line: Line2D = $TrajectoryLine

func _ready() -> void:
	if trajectory_line:
		trajectory_line.visible = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * speed
		sprite.scale.x = sign(direction)
		throw_point.position.x = abs(throw_point.position.x) * sign(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
	
	if Input.is_action_pressed("throw_slime"):
		if trajectory_line:
			trajectory_line.visible = true
			update_trajectory()
	else:
		if trajectory_line:
			trajectory_line.visible = false

func update_trajectory() -> void:
	if not trajectory_line:
		return

	var points: Array[Vector2] = []
	var sim_pos = throw_point.global_position
	
	var mouse_pos = get_global_mouse_position()
	var throw_direction = (mouse_pos - global_position).normalized()
	var sim_velocity = throw_direction * throw_force
	
	var sim_gravity = gravity
	var time_step = 0.05
	var max_steps = 15
	
	for i in range(max_steps):
		points.append(trajectory_line.to_local(sim_pos))
		
		sim_velocity.y += sim_gravity * time_step
		sim_pos += sim_velocity * time_step
		
		if sim_pos.y > global_position.y + 200:
			break
			
	trajectory_line.points = points

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("throw_slime"):
		throw_slime()

func throw_slime() -> void:
	if trajectory_line:
		trajectory_line.visible = false
		
	var slime = SLIME_SCENE.instantiate()
	get_parent().add_child(slime)
	
	slime.global_position = throw_point.global_position
	
	var mouse_pos = get_global_mouse_position()
	var throw_direction = (mouse_pos - global_position).normalized()
	
	if slime.has_method("throw"):
		slime.throw(throw_direction * throw_force)
