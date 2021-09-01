extends "res://Scripts/Tank/Tank.gd"

# An enum to show different npc state (chasing player, shoting player, returing
# to initial_position or patroling around initial_position) 
enum NPCState{
	PATROLING,
	CHASING_PLAYER,
	SHOTING_PLAYER,
	RETURNING
}
# Holds current NPC state
var curr_npc_state: int = NPCState.PATROLING

const BARREL_TURN_SPEED: float = .5 # Per second

var barrel_turn_dir: int = +1 # Increasing -> clock wise turn
# Holds npc fields of view which indicates how close the player can get before
# npc shots it. The value is in squared value.
var npc_shot_fov: float = 400 * 400
# Holds npc notice (chase) fov, if player gets in the fov, npc will try to 
# get close to it in order to make a shot (player must be in shot fov for npc to
# shot it)
var npc_chase_fov: float = 900 * 900
# The area radius that the tank can PATROL in.
var npc_patrol_radius: float = 300 * 300
# Holds the patroling rectangle points
var patrol_points: PoolVector2Array = PoolVector2Array();
# Holds which patrol point are we at or going to know
var patrol_point_index: int = -1
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
var path_to_player_update_threshold: float = 192 * 192
# Holds player last position which is used to check if path to player needs to
# be updated
var player_last_position: Vector2
# Returning path array
var return_path: Array
# Index of next point in return path
var return_path_point_indx: int = 0

# Enum to show tank movements states
enum MoveState {
	STOP,
	START,
	STRAIGHT_MOVE,
	SLOW_DOWN,
	TURN
}
var curr_move_state: int = MoveState.STOP
# Holds angel to destination to avoid unneccessary calculation of angle 
var target_diff_angle: float
var need_steering: bool = false
# Holds target point that is used to calculate target_diff_angle
var target_point: Vector2 = Vector2()
# Shows what direction should we turn
var turn_direction: int = 0 # 1 for turn right, -1 for turn left
# Target position update threshold, (in squared value)
var slow_down_threshold: float
# Holds how much time should break be applied.
var break_timer_max: float
var break_timer: float
# Squared distance to target point
var target_dist_sq: float
# Different max acceleration used in different npc states
var patrol_max_accel: float
var return_max_accel: float
# Holds current maximum accel
var current_max_accel: float
# Holds reduced maximum accelration which is used in case of steering (turning)
var turn_max_accel: float = max_accel / 2



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
	
	_update_patrol_path()
	initial_position = position
	
	slow_down_threshold = pow(tank_front.position.x - tank_back.position.x,
		2)
	# We set break to be applied until tip of the tank reaches the target
	# position, approximately
	break_timer_max = sqrt(slow_down_threshold) / 800
	break_timer = break_timer_max
	
	return
	


func _on_ready() -> void:
	explosion_part.emitting = false
	max_steer_ang /= 2
	
	patrol_max_accel = max_accel / 1.8
	return_max_accel = max_accel / 1.6
	
	max_accel /= 1.3
	
	return
	


func _control(delta: float) -> void:
	# Regardless of npc state we need distance to player
	var player_dist_squared: float = (
		(position - Global.player.position).length_squared())
	
	if player_dist_squared < npc_shot_fov:
		curr_npc_state = NPCState.SHOTING_PLAYER
	elif player_dist_squared < npc_chase_fov:
		curr_npc_state = NPCState.CHASING_PLAYER
		if not is_path_to_player_update:
			_update_path_to_player()
	else:
		match curr_npc_state:
			NPCState.RETURNING:
				pass
			NPCState.PATROLING:
				pass
			_:
				if ((position - initial_position).length_squared()
						> npc_patrol_radius):
					if return_path.size() == 0:
						_update_return_path()
					curr_npc_state = NPCState.RETURNING
				else:
					_update_patrol_path()
					curr_npc_state = NPCState.PATROLING
	
	
	# Take action based on current state
	match curr_npc_state:
		NPCState.PATROLING:
			if target_dist_sq < slow_down_threshold:
				_update_patrol_path()
			
			if barrel_turn_dir == +1:
				barrel_sprt.rotation += BARREL_TURN_SPEED * delta / 2
				if barrel_sprt.rotation > 3.14:
					barrel_turn_dir = -1
			else:
				barrel_sprt.rotation -= BARREL_TURN_SPEED * delta / 2
				if barrel_sprt.rotation < -3.14:
					barrel_turn_dir = +1
			
			target_point = patrol_points[patrol_point_index]
			target_dist_sq = (position - target_point).length_squared()
			_update_target()
			# Calling _move function
			current_max_accel = patrol_max_accel
			_move(delta)
		NPCState.CHASING_PLAYER:
			if return_path.size() > 0:
				return_path.clear()
			
			# If player has moved from the last point in path to player 
			# at least as much as path_to_player_update_threshold then 
			# the path to player needs to be updated.
			if ((player_last_position - Global.player.position).length_squared()
					> path_to_player_update_threshold):
				_update_path_to_player()
			
			if path_to_player.size() >= 2:
				# Setting target point
				target_point = path_to_player[path_to_player_point_index]
				target_dist_sq = (position - target_point).length_squared()
				_update_target()
			
				var barrel_angle_to_player: float = barrel_sprt.get_angle_to(
					Global.player.global_position)
				barrel_sprt.rotation = move_toward(barrel_sprt.rotation,
					barrel_sprt.rotation + barrel_angle_to_player, delta)
					
				if target_dist_sq < slow_down_threshold:
					path_to_player_point_index += 1
				# Calling _move function
				current_max_accel = max_accel
				_move(delta)
		NPCState.SHOTING_PLAYER:
			if is_path_to_player_update:
				is_path_to_player_update = false
			if return_path.size() > 0:
				return_path.clear()
			
			curr_move_state = MoveState.STOP
			var barrel_angle_to_player: float = barrel_sprt.get_angle_to(
			Global.player.global_position)
			barrel_sprt.rotation = move_toward(barrel_sprt.rotation,
				barrel_sprt.rotation + barrel_angle_to_player, delta)
			_npc_shot_at_palyer(barrel_angle_to_player)
		NPCState.RETURNING:
			if is_path_to_player_update:
				is_path_to_player_update = false
			
			if return_path.size() >= 2:
				# Setting target point
				target_point = return_path[return_path_point_indx]
				_update_target()
				
				barrel_sprt.rotation = move_toward(barrel_sprt.rotation, 0, delta)
				target_dist_sq = (position - target_point).length_squared()
				
				# Calling _move function
				current_max_accel = return_max_accel
				_move(delta)
				
				if target_dist_sq < slow_down_threshold:
					return_path_point_indx += 1
					if return_path_point_indx >= return_path.size():
						curr_npc_state = NPCState.PATROLING
						_update_patrol_path()
						return_path.clear()
						update()
	
	update()
	
	return
	


func _move(delta: float) -> void:
	if curr_npc_state == NPCState.SHOTING_PLAYER:
		# No movement is required
		return
	
	match curr_move_state:
		MoveState.STOP:
			curr_move_state = MoveState.START
			need_steering = true
		MoveState.START:
			curr_accel_magn = lerp(curr_accel_magn, current_max_accel,
				engine_accel)
			accel = transform.x * curr_accel_magn
			if need_steering:
				_calculate_steering()
			else:
				curr_move_state = MoveState.STRAIGHT_MOVE
		MoveState.STRAIGHT_MOVE:
			curr_accel_magn = lerp(curr_accel_magn, current_max_accel,
				engine_accel)
			accel = transform.x * curr_accel_magn
			if (abs(target_diff_angle) > 0.5 
					or target_dist_sq < slow_down_threshold):
				curr_move_state = MoveState.TURN
				need_steering = true
		MoveState.TURN:
			curr_accel_magn = lerp(curr_accel_magn, turn_max_accel,
				engine_accel)
			accel = transform.x * curr_accel_magn
			if need_steering:
				_calculate_steering()
			else:
				curr_move_state = MoveState.STRAIGHT_MOVE
	
	return
	


func _update_target() -> void:
	# Updating target_diff_angle
	target_diff_angle = transform.x.angle_to((target_point - position))
	
	return
	


func _calculate_steering() -> void:
	if target_diff_angle > 0:
		need_steering = true
		curr_steer_ang = lerp_angle(curr_steer_ang, max_steer_ang, steer_sp)
	elif target_diff_angle < 0:
		need_steering = true
		curr_steer_ang = lerp_angle(curr_steer_ang, -max_steer_ang, steer_sp)
	
	return
	


func _handle_drift(delta: float) -> void:
	if speed > 150 and abs(curr_steer_ang) > 0.01:
		curr_traction = lerp(curr_traction, 0.01, 0.5)
	else:
		curr_traction = lerp(curr_traction, 0.99, 0.01)
	
	return
	


func _handle_steering(delta: float) -> void:
	if curr_move_state == MoveState.STOP:
		return
	
	if abs(target_diff_angle) <= abs(curr_steer_ang):
		need_steering = false
		curr_steer_ang = 0
		set_rotation(rotation + target_diff_angle)
	else:
		set_rotation(rotation + curr_steer_ang)
	
	var target_vel: Vector2 = transform.x * speed
	velocity = velocity.linear_interpolate(target_vel, curr_traction)
	
	return
	


func _update_patrol_path() -> void:
	patrol_point_index += 1
	if patrol_point_index == 4:
		patrol_point_index = 0
	
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
	
	player_last_position = Global.player.position
	
	return
	


func _update_return_path() -> void:
	print("updating return path")
	# Getting closest point id to position and return position
	var cls_pos_id: int = Global.level.astar.get_closest_point(position)
	var cls_player_pos_id: int = (
		Global.level.astar.get_closest_point(patrol_points[patrol_point_index]))
	
	return_path = Global.level.astar.get_point_path(
		cls_pos_id,
		cls_player_pos_id)
	
	return_path_point_indx = 1
	
	return
	


func _draw() -> void:
	draw_circle(to_local(target_point), 15, Color.red)
	match curr_npc_state:
		NPCState.RETURNING:
			for i in range(return_path.size() - 1):
				draw_line(to_local(return_path[i]),
					to_local(return_path[i + 1]), Color.blue, 6)
		NPCState.CHASING_PLAYER:
			for i in range(path_to_player.size() - 1):
				draw_line(to_local(path_to_player[i]),
					to_local(path_to_player[i + 1]), Color.blue, 6)

	return



func _npc_shot_at_palyer(barrel_angle_to_player: float) -> void:
	if barrel_angle_to_player < 0.4 and barrel_angle_to_player > -0.4:
		_shot()
	
	return
	


func _estimate_closest_point_to(_pos: Vector2) -> int:
	var closest_tile_pos: Vector2 = Vector2(int(_pos.x) >> 6, int(_pos.y) >> 6)
	closest_tile_pos -= Global.level.grnd_tile.get_used_cells()[0]
	
	return int((int(closest_tile_pos.x) << 6) + closest_tile_pos.y)
	

