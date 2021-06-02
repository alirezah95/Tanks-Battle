extends KinematicBody2D

onready var destroy_delay: Timer = $DestroyDelay
onready var exp_particles: Particles2D = $ExplosionParticle
onready var barrel: Sprite = $BarrelSprite
onready var tank: Sprite = $TankSprite
onready var cool_down_tmr: Timer = $CoolDownTmr
onready var shot_fire_sprt: Sprite = $BarrelSprite/ShotFireSprite
onready var animations: AnimationPlayer = $Animations

# Player tank move current speed
export(float) var speed: float = 0
# Each tank has a health value and when that health is reached 0, the tank
# should be destroyed.
export(float) var health: float = 2000.0
# Sets cool down timer wait_time property
export(float) var cool_down_time: float = 0.8
# Holds whether the shotting is lockes
var is_shot_locked: bool = false
# Barrel direction
var shot_direction: Vector2 = Vector2(0, -1)
# Shows if tank is destroyed (dead)
var is_dead: bool = false



func _ready() -> void:
	add_to_group("tank")
	shot_fire_sprt.modulate = Color.transparent
	shot_fire_sprt.offset = Vector2(shot_fire_sprt.texture.get_size().x / 2, 0)
	shot_fire_sprt.position = Vector2(
		barrel.texture.get_size().x / 2, 0) + barrel.offset - Vector2(4, 0)
	
	return
	


func _on_ready() -> void:
	pass
	


func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	
	return
	


func _handle_movement(delta: float) -> void:
	pass


func apply_impact(damage: float) -> void:
	health -= damage
	print(name + ": damage recieved: health: ", health)
	if health <= 0:
		call_deferred("die")
	
	return
	


func die() -> void:
	set_physics_process(false)
	# Emitting an explosion particle
	
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
	var new_shot: Shot = Global.shotScn.instance()
	shot_direction = Vector2(cos(barrel.global_rotation),
		sin(barrel.global_rotation))
	new_shot.setDirection(shot_direction)
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
	
