extends KinematicBody2D

onready var destroyDelay = $DestroyDelay
onready var expParticle: Particles2D = $ExplosionParticle
onready var barrel: Sprite = $BarrelSprite
onready var tank: Sprite = $TankSprite

# Each tank has a health value and when that health is reached 0, the tank
# should be destroyed.
var health: float = 2000.0



func die() -> void:
	# Emitting an explosion particle
	
	# Making a delay 
	destroyDelay.start()
	
	return
	


func shoot(direction: Vector2) -> void:
	
	return
	


func _on_DestroyDelay_timeout() -> void:
	# Explosion particle is finieshed, queueing tank to free.
	queue_free()
	
	return
	
