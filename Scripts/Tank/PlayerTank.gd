extends "res://Scripts/Tank/Tank.gd"

class_name PlayerTank

onready var camera: Camera2D = $PlayerCamera
onready var healthBar: ProgressBar = $Control/HBox/HealthBar

# Max speed value, tank speed cant go higher than this value
const MAX_SPEED: float = 400.0
# Maximum and Minimum acceleration
const MAX_ACCEL: float = 7.0
const MIN_ACCEL: float = -MAX_ACCEL
# Breaks force
const BREAKS_FORCE: float = 7.0
# Tank friction value
var friction: float = 0.6
# Forward acceleration value
var acceleration: float
# Player tank move direction
var direction: Vector2
# Shows if player tank is fallen into see
var is_fallen_into_see: bool = false



func _ready() -> void:
	Global.player = self
	health = 10000
	
	healthBar.min_value = 0
	healthBar.max_value = health
	healthBar.value = health
	
	return
	


func _handle_movement(delta: float) -> void:
	if is_fallen_into_see:
		move_and_slide(direction * speed)
		return
	
	# Using up, down keys to move the tank
	var input_accel: float = (Input.get_action_strength("ui_down") - 
			Input.get_action_strength("ui_up"))
	var turnStr: float = (Input.get_action_strength("ui_right") -
			Input.get_action_strength("ui_left"))
	
	var breaks_pressed: bool = Input.is_action_pressed("break")
	
	if input_accel == 0.0:
		acceleration = 0
	else:
		acceleration += input_accel
		if acceleration > MAX_ACCEL:
			acceleration = MAX_ACCEL
		elif acceleration < MIN_ACCEL:
			acceleration = MIN_ACCEL
	
	# Applying forward acceleration to speed
	speed += acceleration
	_apply_friction()
	if breaks_pressed:
		_apply_breaks()
	
	# Apply turn
	if speed < 5.0 && speed > -5.0:
		tank.rotation += turnStr * delta * 0.8
	else:
		tank.rotation += turnStr * delta * 1.6
	
	speed = clamp(speed, -MAX_SPEED, MAX_SPEED)
	
	direction = Vector2(-cos(tank.rotation), -sin(tank.rotation))
	
	# Using mouse cursor position the tank barrel direction is set.
	shot_direction = Vector2.ZERO.direction_to(get_local_mouse_position())
	barrel.rotation = shot_direction.angle()
	
	move_and_slide(direction * speed)
	
	# Check if player is fallen into see
	if (Global.level.grnd_tile.get_cellv(
			Global.level.grnd_tile.world_to_map(position))
			== TileMap.INVALID_CELL):
		is_fallen_into_see = true
		animations.play("FallIntoSee")
	
	return
	


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.is_pressed():
			_shot()
	
	return
	


func _instance_shot_object() -> Shot:
	# Instancing a shot object
	var new_shot: Shot = Global.playerShotScn.instance()
	new_shot.setDirection(shot_direction)
	new_shot.global_position = shot_fire_sprt.global_position
	new_shot.z_index = z_index - 1
	
	return new_shot
	


func _apply_friction() -> void:
	if speed < -5:
		speed += friction
	elif speed > 5:
		speed -= friction
	elif acceleration == 0:
		speed = 0
		
	return
	


func _apply_breaks() -> void:
	# Apply breaks
	if speed < -5:
		speed += BREAKS_FORCE
	elif speed > 5:
		speed -= BREAKS_FORCE
	else:
		speed = 0.0
	
	return
	


func apply_impact(damage: float) -> void:
	.apply_impact(damage)
	
	healthBar.value = health
	
	if healthBar.value <= 3000:
		healthBar.modulate = Color("cf0000")
	
	return
	


func _on_DestroyDelay_timeout() -> void:
	._on_DestroyDelay_timeout()
	
	Global.level.game_over()
	
	return
	


func _on_Animations_animation_finished(anim_name: String) -> void:
	if anim_name == "FallIntoSee":
		destroy_delay.start()
	
	return
	
