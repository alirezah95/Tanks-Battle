extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func _on_PlayButton_pressed() -> void:
	get_tree().change_scene("res://Scenes/Level.tscn")
	return
	


func _on_InventoryButton_pressed() -> void:
	get_tree().change_scene("res://Scenes/Inventory/InventorySystem.tscn")
	
	return
	
