extends Label


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	var npc: KinematicBody2D = get_parent().get_node("NPCTank")
	text = "Player: " + str(Global.player.rotation) + "\n" +\
			"NPC: " + str(npc.rotation) + "\n" +\
			"Angle: " + str(
				(npc.global_position - Global.player.global_position).angle() + PI)
	
	return
	
