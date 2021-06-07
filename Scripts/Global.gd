extends Node


onready var shot_scn: PackedScene = preload("res://Scenes/Shot/Shot.tscn")
onready var player_shot_scn: PackedScene = (
	preload("res://Scenes/Shot/PlayerShot.tscn"))


const PI_2: float = PI * 2

var player: PlayerTank = null

var level: Level = null
