extends Node2D

class_name Shot

onready var ray = $ShotRay
onready var sprt = $ButlletSprite
onready var visibility = $Visibility
onready var audio = $FireAudio2D

# Shot move speed
var speed: float = 1300.0
# Shot move direction in x and y coordinates.
var direction: Vector2 = Vector2(0, -1)
# The amount of damage this shot applys to target
var damage: float = 400.0
# Shows if shot is collided with sth and therefor is queued to free
var is_queued_to_free: bool = false



func _ready() -> void:
	pass
	


func setDirection(dir: Vector2) -> void:
	direction = dir
	
	rotation = direction.angle()
	
	return
	


func _physics_process(delta: float) -> void:
	position += direction * (speed * delta)
	
	if not visibility.is_on_screen():
		sprt.hide()
		set_physics_process(false)
		queue_free()
	elif ray.is_colliding():
		# Ray cast is collidint with wome bodies
		var collider: Node = ray.get_collider() as Node
		if collider.is_in_group("tank"):
			collider.apply_impact(damage)
		
		sprt.hide()
		set_physics_process(false)
		if audio.playing:
#			visible = false
			ray.enabled = false
			is_queued_to_free = true
		else:
			queue_free()
	
	return
	


func _on_FireAudio2D_finished() -> void:
	if is_queued_to_free:
		queue_free()
	
	return
	
