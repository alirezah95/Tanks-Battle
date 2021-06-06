extends "res://Scripts/Tank/Tank.gd"

class_name PlayerTank

onready var camera: Camera2D = $PlayerCamera
onready var healthBar: ProgressBar = $Control/HBox/HealthBar

# Shows if player tank is fallen into see
var is_fallen_into_see: bool = false



func _ready() -> void:
	Global.player = self
	health = 10000
	
	healthBar.min_value = 0
	healthBar.max_value = health
	healthBar.value = health
	
	return
	


func _control(delta: float) -> void:
	if is_fallen_into_see:
		return
	
	# Using up, down keys to move the tank
	var input_accel: float = (Input.get_action_strength("ui_up") - 
		Input.get_action_strength("ui_down"))
	
	var input_steer: float = (Input.get_action_strength("ui_right") -
		Input.get_action_strength("ui_left"))
	
	var breaks_pressed: bool = Input.is_action_pressed("break")
	
	if breaks_pressed:
		curr_accel_magn = -50
	elif input_accel == 1:
		curr_accel_magn = lerp(curr_accel_magn, max_accel, engine_de_accel)
		accel = transform.x * curr_accel_magn
	elif input_accel == -1:
		curr_accel_magn = lerp(curr_accel_magn, reverse_accel, engine_de_accel)
		accel = transform.x * reverse_accel
	else:
		# Just decrease current accel_magn value, friction will decrease accel_magn vector
		# length
		curr_accel_magn = lerp(curr_accel_magn, 0, 0.01)
	
	if input_steer == 0:
		curr_steer_ang = lerp_angle(curr_steer_ang, 0.0, 0.1)
	elif input_steer == 1:
		curr_steer_ang = lerp_angle(curr_steer_ang, max_steer_ang, steer_sp)
	else:
		curr_steer_ang = lerp_angle(curr_steer_ang, -max_steer_ang, steer_sp)
	
	# Using mouse cursor position the tank barrel direction is set.
	shot_direction = Vector2.ZERO.direction_to(get_local_mouse_position())
	barrel.rotation = shot_direction.angle()
	
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
	

