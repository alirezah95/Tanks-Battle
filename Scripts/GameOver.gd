extends Panel




func _on_ui_bttns_pressed(extra_arg_0: String) -> void:
	if extra_arg_0 == "rest":
		get_tree().paused = false
		get_tree().reload_current_scene()
	elif extra_arg_0 == "exit":
		get_tree().quit()
	
	return
	
