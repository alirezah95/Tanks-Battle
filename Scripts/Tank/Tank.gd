extends KinematicBody2D

onready var destroy_delay: Timer = $DestroyDelay
onready var tank_collision: CollisionShape2D = $TankCollision
onready var explosion_part: Particles2D = $ExplosionParticles
onready var barrel_sprt: Sprite = $BarrelSprite
onready var tank_sprt: Sprite = $TankSprite
onready var cool_down_tmr: Timer = $CoolDownTmr
onready var shot_fire_sprt: Sprite = $BarrelSprite/ShotFireSprite
onready var animations: AnimationPlayer = $Animations
onready var tank_front: Position2D = $TankFront
onready var tank_back: Position2D = $TankBack
onready var health_bar: ProgressBar = $HealthBar
onready var tank_tween: Tween = $TankTween

# Each tank has a health value and when that health is reached 0, the tank
# should be destroyed.
export(float) var health: float = 6000.0
# Sets cool down timer wait_time property
export(float, 0.5, 1.2, 0.1) var cool_down_time: float = 1.2

# Maximum available accelaration (maximum engine force)
export(float) var max_accel: float = 800
# Reverse accelaration value
export(float) var reverse_accel: float = -350
# Break deacceleration
export(float) var break_de_accel: float = -200
# Engine deaccelaration ratio
export(float, 0.05, 0.2, 0.01) var engine_accel: float = 0.1
# Friction constant
export(float, -0.2, -0.5, 0.1) var friction: float = -0.3
# Holds drag constant, which is caused by air resistance.
export(float, -0.001, -0.003, 0.001) var drag: float = -0.003
# Holds maximum steering angle a tank can have (in radians)
export(float, 0.20, 0.40, 0.2) var max_steer_ang: float = 0.26
# Steering speed
export(float, 0.005, 0.01, 0.001) var steer_sp: float = 0.5

# Current accelaration vector
var accel: Vector2 = Vector2()
# Current accelaration magnitude
var curr_accel_magn: float = 0.0
# Velocity vector
var velocity: Vector2 = Vector2()
# We are using velocity.length which is the speed value in all of the movement
# control functions, so we save it in speed var to aviod re-calculating
var speed: float = 0.0
# Holds current steering angle
var curr_steer_ang: float = 0.0
# Traction
var curr_traction: float = 0.99
# Holds whether the shotting is lockes
var is_shot_locked: bool = false
# Shows if tank is destroyed (dead)
var is_dead: bool = false
# Delay time to hide health bar
var hide_health_delay: float = 1.5 # In seconds.
# Is health bar shown
var is_health_bar_shown: bool = false



func _ready() -> void:
	_on_ready()
	
	add_to_group("tank")
	shot_fire_sprt.modulate = Color.transparent
	shot_fire_sprt.offset = Vector2(shot_fire_sprt.texture.get_size().x / 2, 0)
	shot_fire_sprt.position = (Vector2(barrel_sprt.texture.get_size().x / 2, 0)
		+ barrel_sprt.offset - Vector2(4, 0))
	
	cool_down_tmr.wait_time = cool_down_time
	
	health_bar.min_value = 0
	health_bar.max_value = health
	health_bar.value = health
	health_bar.modulate = Color.transparent
	
	return
	


func _on_ready() -> void:
	pass
	


func _physics_process(delta: float) -> void:
	if is_health_bar_shown:
		hide_health_delay -= delta
		if hide_health_delay < 0.0:
			tank_tween.interpolate_property(health_bar, "modulate:a",
				modulate.a, 0, 0.4)
			tank_tween.start()
			is_health_bar_shown = false
	
	accel = Vector2()
	speed = velocity.length()
	_control(delta)
	_handle_friction(delta)
	_handle_drift(delta)
	_handle_steering(delta)
	
	velocity += accel * delta
	move_and_slide(velocity)
	
	return
	


func _unhandled_input(event: InputEvent) -> void:
	OS
	


# This function controls the tank direction, force and breaks. It will be
# overridden in derived classes.
func _control(delta: float) -> void:
	pass


# Following funtion handles friction (roll resistance and drag resistance).
# It is the same of all derived classes
func _handle_friction(delta: float) -> void:
	# Stop if it's already slow
	if speed < 10 and abs(curr_accel_magn) < 1:
		velocity = Vector2(0, 0)
		speed = 0
		return
	
	var roll_resis: Vector2 = velocity * friction
	var drag_resis: Vector2 = velocity * speed * drag
	
	accel += roll_resis + drag_resis
	
	return
	


# This function handles car steering.
func _handle_steering(delta: float) -> void:
	var rear_wheel = tank_back.global_position + velocity * delta
	var front_wheel = (tank_front.global_position + 
			velocity.rotated(curr_steer_ang) * delta)
	var new_heading = (front_wheel - rear_wheel).normalized()
	set_rotation(new_heading.angle())
	
	var target_vel = new_heading * speed
	var is_moving_forward: bool = true if new_heading.dot(velocity) > 0 else false
	if is_moving_forward:
		velocity = velocity.linear_interpolate(target_vel, curr_traction)
	else:
		velocity = -target_vel
	
	return
	


func _handle_drift(delta: float) -> void:
	if (speed > 400 and abs((abs(curr_steer_ang) - max_steer_ang)) < 0.001):
		curr_traction = lerp(curr_traction, 0.001, 0.5)
	else:
		curr_traction = lerp(curr_traction, 0.99, 0.01)
	
	return
	


func set_rotation(value: float) -> void:
	.set_rotation(value)
	health_bar.set_rotation(-value)
	
	return
	


func apply_impact(damage: float) -> void:
	health -= damage
	health_bar.value = health
	
	hide_health_delay = 1.5
	if not is_health_bar_shown:
		is_health_bar_shown = true
		tank_tween.interpolate_property(health_bar, "modulate:a", modulate.a,
			1, 0.4)
		tank_tween.start()
	
	if health <= 0:
		call_deferred("die")
	
	return
	


func die() -> void:
	set_physics_process(false)
	tank_collision.disabled = true
	
	# Emitting an explosion particle
	explosion_part.emitting = true
	# Making a delay 
	destroy_delay.start()
	
	return
	


func _shot() -> void:
	if is_shot_locked:
		return
	
	is_shot_locked = true
	cool_down_tmr.start()
	
	get_tree().current_scene.call_deferred("add_child", _instance_shot_object())
	shot_fire_sprt.modulate = Color.white
	animations.call_deferred("play", "ShotFire")
	
	return
	


func _instance_shot_object() -> Shot:
	# Instancing a shot object
	var new_shot: Shot = Global.shot_scn.instance()
	new_shot.setDirection(barrel_sprt.global_transform.x)
	new_shot.global_position = shot_fire_sprt.global_position
	new_shot.z_index = z_index - 1
	
	return new_shot
	


func _on_DestroyDelay_timeout() -> void:
	# Explosion particle is finieshed, queueing tank to free.
	queue_free()
	
	return
	


func _on_ShotLockTimer_timeout() -> void:
	is_shot_locked = false
	
	return
	

