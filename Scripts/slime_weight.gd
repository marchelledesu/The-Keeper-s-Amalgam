extends SoftBody2D

@export var despawn_time: float = 10.0
@export var bounce_factor: float = 0.35
@export var stop_threshold: float = 80.0

var velocity: Vector2 = Vector2.ZERO
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_flying: bool = false

@onready var ray_cast: RayCast2D = $RayCast2D
var base_scale: Vector2 = Vector2.ONE

func _ready() -> void:
	base_scale = scale
	var timer = get_tree().create_timer(despawn_time)
	timer.timeout.connect(queue_free)

func throw(impulse: Vector2) -> void:
	velocity = impulse
	is_flying = true

func _physics_process(delta: float) -> void:
	if not is_flying:
		return

	velocity.y += gravity * delta
	
	var motion = velocity * delta
	if ray_cast:
		var extension = velocity.normalized() * 6.0
		var cast_vector = motion + extension
		
		ray_cast.target_position = ray_cast.to_local(ray_cast.global_position + cast_vector)
		ray_cast.force_raycast_update()
		
		if ray_cast.is_colliding():
			var normal = ray_cast.get_collision_normal()
			
			if velocity.dot(normal) < 0:
				if velocity.length() < stop_threshold or (normal.y < -0.7 and abs(velocity.y) < 150.0):
					global_position = ray_cast.get_collision_point() + (normal * 2.0)
					land()
					return
				else:
					velocity = velocity.bounce(normal) * bounce_factor
					global_position = ray_cast.get_collision_point() + (normal * 4.0)
					_trigger_squish()
					return

	global_position += motion

	if velocity.length() > 10:
		rotation = velocity.angle()
		var stretch = clamp(velocity.length() / 800.0, 0.0, 0.25)
		scale = base_scale + Vector2(stretch, -stretch)

func _trigger_squish() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", base_scale + Vector2(0.35, -0.25), 0.05)
	tween.tween_property(self, "scale", base_scale, 0.15)

func land() -> void:
	is_flying = false
	rotation = 0.0
	scale = base_scale
