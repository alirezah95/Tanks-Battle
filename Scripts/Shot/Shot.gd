extends Node2D

class_name Shot

onready var ray = $ShotRay
onready var sprt = $ShotSprite
onready var visibility = $Visibility

# Shot move speed
var speed: float = 1200.0
# Shot move direction in x and y coordinates.
var direction: Vector2 = Vector2(0, -1)
# The amount of damage this shot applys to target
var damage: float = 400.0



func _ready() -> void:
	pass


func setDirection(dir: Vector2) -> void:
	direction = dir
	
	rotation = direction.angle() + Global.PI_2
	
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
			collider.applyImpact(damage)
		
		sprt.hide()
		set_physics_process(false)
		queue_free()
	
	return
	
