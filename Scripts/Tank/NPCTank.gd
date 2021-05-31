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
var npc_shot_fov: float = 450 * 450
# Holds npc notice (chase) fov, if player gets in the fov, npc will try to 
# get close to it in order to make a shot (player must be in shot fov for npc to
# shot it)
var npc_chase_fov: float = 900 * 900
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
# Path to player
var path_to_player: Array
# Holds if the path to player is updated
var is_path_to_player_update: bool = false
# Index of next point in path to player
var path_to_player_point_index: int = 1
# Holds the threshold that the player needs to move in order for the 
# path_to_player array to be updated. (in squared value)
var path_to_player_update_threshold: float = 200 * 200
# Reference to level astar node
var lvl_astar: AStar2D
# Returning path array
var return_path: Array
# Index of next point in return path
var return_path_point_indx: int = 0
# Holds the move direction vector, which is used in both RETURNING and 
# CHASING_PALYER states.
var move_angle: float



func _ready() -> void:
	speed = 125
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
	


func _handle_movement(delta: float) -> void:
	# Regardless of npc state we need distance to player
	var player_dist_squared: float = (
		(position - Global.player.position).length_squared())
	
	if player_dist_squared < npc_shot_fov:
		npc_current_state = NPCState.SHOTING_PLAYER
	elif player_dist_squared < npc_chase_fov:
		npc_current_state = NPCState.CHASING_PLAYER
		if not is_path_to_player_update:
			_update_path_to_player()
	else:
		match npc_current_state:
			NPCState.RETURNING:
				if (position - patrol_points[curr_patrol_point]
						).length_squared() < 300:
					npc_current_state = NPCState.PATROLING
			NPCState.PATROLING:
				pass
			_:
				if ((position - initial_position).length_squared()
						> npc_patrol_radius):
					if return_path.size() == 0:
						_update_return_path()
					npc_current_state = NPCState.RETURNING
				else:
					npc_current_state = NPCState.PATROLING
	
	# Keeping rotation in between -pi and pi, because it's one of the assumption
	# in some of our functions.
	if rotation > 3.1415:
		rotation -= 6.2831
	elif rotation < -3.1415:
		rotation += 6.2831
	
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
				patrol_look_angle = _get_nearest_angle_to_rotate(rotation,
					patrol_look_angle)
				
				patrol_is_rotating = true
			else:
				if patrol_is_rotating:
					if abs(rotation - patrol_look_angle) < 0.05:
						patrol_is_rotating = false
					else:
						rotation = move_toward(rotation, patrol_look_angle,
							delta)
				else:
					move_and_slide(PATROL_SPEED * patrol_direction)
			
			if barrel_turn_dir == +1:
				barrel.rotation += BARREL_TURN_SPEED * delta / 2
				if barrel.rotation > 3.14:
					barrel_turn_dir = -1
			else:
				barrel.rotation -= BARREL_TURN_SPEED * delta / 2
				if barrel.rotation < -3.14:
					barrel_turn_dir = +1
		NPCState.CHASING_PLAYER:
			if return_path.size() > 0:
				return_path.clear()
			
			# If player has moved from the last point in path to player 
			# at least as much as path_to_player_update_threshold then 
			# the path to player needs to be updated.
			if ((path_to_player[path_to_player.size() - 1]
					- Global.player.position).length_squared()
					> path_to_player_update_threshold):
				_update_path_to_player()
			
			if path_to_player.size() >= 2:
				var move_dir: Vector2 = (
					path_to_player[path_to_player_point_index] - position)
				move_angle = _get_nearest_angle_to_rotate(rotation,
					move_dir.angle())
				rotation = move_toward(rotation, move_angle, delta * 2.5)
				move_and_slide(Vector2(1, 0).rotated(rotation) * speed)
				var barrel_angle_to_player: float = barrel.get_angle_to(
					Global.player.global_position)
				barrel.rotation = move_toward(barrel.rotation,
					barrel.rotation + barrel_angle_to_player, delta)
				if move_dir.length_squared() < 100:
					path_to_player_point_index += 1
		NPCState.SHOTING_PLAYER:
			if is_path_to_player_update:
				is_path_to_player_update = false
			
			if return_path.size() > 0:
				return_path.clear()
			var barrel_angle_to_player: float = barrel.get_angle_to(
			Global.player.global_position)
			barrel.rotation = move_toward(barrel.rotation,
				barrel.rotation + barrel_angle_to_player, delta / 1.3)
			_npc_shot_at_palyer(barrel_angle_to_player)
		NPCState.RETURNING:
			if is_path_to_player_update:
				is_path_to_player_update = false
			
			if return_path.size() >= 2:
				move_angle = (return_path[return_path_point_indx] - position
						).angle()
				move_angle = _get_nearest_angle_to_rotate(rotation, move_angle)
				rotation = move_toward(rotation, move_angle, delta * 5)
				barrel.rotation = move_toward(barrel.rotation, 0, delta)
				# Speed ratio is used to decrease tank speed on turns
				var speed_ratio: float = 1
				var diff_angle: float = abs(move_angle - rotation)
				if (diff_angle) > 0.2 or (diff_angle) < -0.2 :
					speed_ratio = .4
				move_and_slide(Vector2(1, 0).rotated(rotation)
					* speed * speed_ratio)
				
				if ((position - return_path[return_path_point_indx]
						).length_squared() < 400):
					return_path_point_indx += 1
					if return_path_point_indx >= return_path.size():
						npc_current_state = NPCState.PATROLING
						return_path.clear()
	
	return
	


func _update_path_to_player() -> void:
	# Getting closest point id to position and player position
	var cls_pos_id: int = Global.level.astar.get_closest_point(position)
	var cls_player_pos_id: int = (
		Global.level.astar.get_closest_point(Global.player.position))
	
	path_to_player.clear()
	path_to_player = Global.level.astar.get_point_path(
		cls_pos_id,
		cls_player_pos_id)
	
	if path_to_player.size() > 1:
		path_to_player_point_index = 1
		is_path_to_player_update = true
	
	return
	


func _update_return_path() -> void:
	print("updating return path")
	# Getting closest point id to position and return position
	var cls_pos_id: int = Global.level.astar.get_closest_point(position)
	var cls_player_pos_id: int = (
		Global.level.astar.get_closest_point(patrol_points[curr_patrol_point]))
	
	return_path = Global.level.astar.get_point_path(
		cls_pos_id,
		cls_player_pos_id)
	
	return
	


func _draw() -> void:
	if return_path.size() > 0:
		for i in range(return_path.size() - 1):
			draw_line(to_local(return_path[i]), to_local(return_path[i + 1]),
			Color.blue, 6)
	else:
		for i in range(path_to_player.size() - 1):
			draw_line(to_local(path_to_player[i]), to_local(path_to_player[i + 1]),
				Color.blue, 6)
	
	return
	


func _npc_shot_at_palyer(barrel_angle_to_player: float) -> void:
	if barrel_angle_to_player < 0.4 and barrel_angle_to_player > -0.4:
		_shot()
	
	return
	


func _estimate_closest_point_to(_pos: Vector2) -> int:
	var closest_tile_pos: Vector2 = Vector2(int(_pos.x) >> 6, int(_pos.y) >> 6)
	closest_tile_pos -= Global.level.grnd_tile.get_used_cells()[0]
	
	return int((int(closest_tile_pos.x) << 6) + closest_tile_pos.y)
	


func _get_nearest_angle_to_rotate(angle: float, target_angle: float) -> float:
	var target_angle_2pi: float = ((target_angle - 6.2831) if target_angle > 0
		else (target_angle + 6.2831))
	
	# finds the shortest direction to rotate
	var diff_to_target_angle: float = abs(angle - target_angle)
	var diff_to_target_angle_2pi: float = abs(angle - target_angle_2pi)
	
	if diff_to_target_angle <= diff_to_target_angle_2pi:
		return target_angle
	else:
		return target_angle_2pi
	
