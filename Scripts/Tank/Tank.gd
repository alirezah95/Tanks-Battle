extends KinematicBody2D

onready var destroyDelay = $DestroyDelay
onready var expParticle: Particles2D = $ExplosionParticle
onready var barrel: Sprite = $BarrelSprite
onready var tank: Sprite = $TankSprite
onready var shotLockTmr: Timer = $ShotLockTimer

# Each tank has a health value and when that health is reached 0, the tank
# should be destroyed.
var health: float = 2000.0
# Holds whether the shotting is lockes
var isShotLocked: bool = false
# Barrel direction
var barrelDirection: Vector2 = Vector2(0, -1)



func _ready() -> void:
	add_to_group("tank")
	
	return
	


func applyImpact(damage: float) -> void:
	health -= damage
	print(name + ": damage recieved: health: ", health)
	if health <= 0:
		call_deferred("die")
	
	return
	


func die() -> void:
	# Emitting an explosion particle
	
	# Making a delay 
	destroyDelay.start()
	
	return
	


func _shot() -> void:
	isShotLocked = true
	shotLockTmr.start()
	
	# Instancing a shot object
	var newShot: Shot = Global.shotScn.instance()
	newShot.setDirection(barrelDirection)
	newShot.position = position
	newShot.z_index = z_index - 1
	get_tree().current_scene.call_deferred("add_child", newShot)
	
	return
	


func _on_DestroyDelay_timeout() -> void:
	# Explosion particle is finieshed, queueing tank to free.
	queue_free()
	
	return
	


func _on_ShotLockTimer_timeout() -> void:
	isShotLocked = false
	
	return
	
