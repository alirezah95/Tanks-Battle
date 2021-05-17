extends "res://Scripts/Tank/Tank.gd"

const BARREL_TURN_SPEED: float = .5 # Per second
var barrel_turn_dir: int = +1 # Increasing -> clock wise turn
# Holds npc fields of view which indicates how close the player can get before
# npc notices it. The value is in squared value.
var npc_fov: float = 400 * 400


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if (position - Global.player.position).length_squared() < npc_fov:
		# Player is in fov
		var angle_to_player_positive: float = (
			(Global.player.global_position - global_position).angle())
		var angle_to_player_negative: float = (
			angle_to_player_positive - Global.PI_2)
		if (abs(rotation - angle_to_player_negative) 
				< abs(rotation - angle_to_player_positive)):
			rotation = move_toward(rotation,
				angle_to_player_negative, delta)
		else:
			rotation = move_toward(rotation,
				angle_to_player_positive, delta)
	else:
		# Player is out of fov. In this case npc barrel keeps turning with a 
		# constant speed.
		if barrel_turn_dir == +1:
			barrel.rotation += BARREL_TURN_SPEED * delta
			if barrel.rotation > 3.14:
				barrel_turn_dir = -1
		else:
			barrel.rotation -= BARREL_TURN_SPEED * delta
			if barrel.rotation < -3.14:
				barrel_turn_dir = +1
	
	return
	
