extends "res://Scripts/Tank/Tank.gd"

# An enum to show different npc state (chasing player, shoting player, returing
# to initial_position or PATROLing around initial_position) 
enum NPCState{
	PATROLING,
	CHASING_PLAYER,
	SHOTING_PLAYER,
	RETURNING
}
# Holds current NPC state
var npc_current_state: int = NPCState.PATROLING

const BARREL_TURN_SPEED: float = .5 # Per second
# Patrol speed
const PATROL_SPEED: float = 80.0

var barrel_turn_dir: int = +1 # Increasing -> clock wise turn
# Holds npc fields of view which indicates how close the player can get before
# npc shots it. The value is in squared value.
var npc_shot_fov: float = 400 * 400
# Holds npc notice (chase) fov, if player gets in the fov, npc will try to 
# get close to it in order to make a shot (player must be in shot fov for npc to
# shot it)
var npc_chase_fov: float = 550 * 550
# The area radius that the tank can PATROL in.
var npc_patrol_radius: float = 300 * 300
# Holds the patroling rectangle points
var patrol_points: PoolVector2Array = PoolVector2Array();
# Holds patrol direction and angle, so we dont calculate it every frame
var patrol_direction: Vector2
var patrol_look_angle: float
var patrol_is_rotating: bool = false
# Holds which patrol point are we at or going to know
var curr_patrol_point: int = 0
# Npc tanks will store their initial position, in case that if they chase the
# player and the player get out of the chase fov, they return to this position
# if their are not destroyed.
var initial_position: Vector2 = Vector2()



func _ready() -> void:
	patrol_points.resize(4)
	randomize()
	var increasing_angle: int = randi() & 0x1
	randomize()
	var pnt_angle: float = rand_range(0, 1.57)
	for i in range(0, 4):
		patrol_points[i] = position + 270 * Vector2(
			cos(pnt_angle), sin(pnt_angle))
		match(increasing_angle):
			0:
				pnt_angle -= 1.5708
			1:
				pnt_angle += 1.5708
	
	patrol_direction = (patrol_points[0] - position).normalized()
	look_at(patrol_points[curr_patrol_point])
	initial_position = position
	
	return
	


func _process(delta: float) -> void:
	# Regardless of npc state we need distance to player
	var player_dist_squared: float = (
		(position - Global.player.position).length_squared())
	
	if player_dist_squared < npc_shot_fov:
		npc_current_state = NPCState.SHOTING_PLAYER
	elif player_dist_squared < npc_chase_fov:
		npc_current_state = NPCState.CHASING_PLAYER
	elif npc_current_state != NPCState.PATROLING:
		if (position - initial_position).length_squared() > npc_patrol_radius:
			npc_current_state = NPCState.RETURNING
		else:
			npc_current_state = NPCState.PATROLING
	else:
		npc_current_state = NPCState.PATROLING
	
	
	# Updating states
	match npc_current_state:
		NPCState.PATROLING:
			if ((position - patrol_points[curr_patrol_point]).length_squared()
					<= 300):
				curr_patrol_point += 1
				if curr_patrol_point == 4:
					curr_patrol_point = 0
				patrol_direction = (patrol_points[curr_patrol_point] - position
					).normalized()
				patrol_look_angle = patrol_direction.angle()
				
				var look_angle_2pi: float = ((patrol_look_angle - 6.2831) if 
					patrol_look_angle > 0 else (patrol_look_angle + 6.2831))
				
				if rotation > 3.1415:
					rotation -= 6.2831
				elif rotation < -3.1415:
					rotation += 6.2831
				
				# Finding the shortest direction to rotate
				var diff_to_angle: float = abs(rotation - patrol_look_angle)
				var diff_to_2pi_angle: float
				if patrol_look_angle > 0:
					diff_to_2pi_angle = abs(rotation - look_angle_2pi)
				else:
					diff_to_2pi_angle = abs(rotation - look_angle_2pi)
				
				if diff_to_angle <= diff_to_2pi_angle:
					pass # Do nothing
				else:
					patrol_look_angle = look_angle_2pi
				
				patrol_is_rotating = true
			else:
				if patrol_is_rotating:
					if abs(rotation - patrol_look_angle) < 0.05:
						patrol_is_rotating = false
					else:
						rotation = move_toward(rotation, patrol_look_angle,
							delta)
				else:
					position += delta * PATROL_SPEED * patrol_direction
			
			if barrel_turn_dir == +1:
				barrel.rotation += BARREL_TURN_SPEED * delta / 2
				if barrel.rotation > 3.14:
					barrel_turn_dir = -1
			else:
				barrel.rotation -= BARREL_TURN_SPEED * delta / 2
				if barrel.rotation < -3.14:
					barrel_turn_dir = +1
		NPCState.CHASING_PLAYER:
			pass
		NPCState.SHOTING_PLAYER:
			var barrel_angle_to_player: float = barrel.get_angle_to(
			Global.player.global_position)
			barrel.rotation = move_toward(barrel.rotation,
				barrel.rotation + barrel_angle_to_player, delta / 1.3)
			_npc_shot_at_palyer(barrel_angle_to_player)
		NPCState.RETURNING:
			pass
	
	return
	


func _npc_shot_at_palyer(barrel_angle_to_player: float) -> void:
	if (barrel_angle_to_player < 0.4 and barrel_angle_to_player > -0.4
			and not isShotLocked):
		var brrl_angle: float = rotation + barrel.rotation
		barrelDirection = Vector2(cos(brrl_angle), sin(brrl_angle))
		_shot()
	
	return
	
