extends Node


onready var shot_scn: PackedScene = preload("res://Scenes/Shot/Shot.tscn")
onready var player_shot_scn: PackedScene = (
	preload("res://Scenes/Shot/PlayerShot.tscn"))

var tank_specifiation: Dictionary;

const PI_2: float = PI * 2

var player: PlayerTank = null

var level: Level = null


func _ready() -> void:
	var file: File = File.new()
	file.open("res://Assets/tank_spec.json", File.READ)
	var json: String = file.get_as_text()
	file.close()
	
	tank_specifiation = parse_json(json) as Dictionary
	
	return
	
