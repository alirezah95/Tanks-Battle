extends TextureRect

class_name InventoryTank

var tanks_data: Dictionary = {
	1: {
		"h": 8000, "a": 700, "p": 0.06, "br": 180, "st": 0.50, "cd": 1.0,
		"img": preload("res://Assets/Gfx/Inventory_system/tank_blue_outline.png"),
		"bd": "Gfx/tankBody_blue_outline.png",
		"muz": "tankBlue_barrel2_outline.png" },
	2: {
		"h": 8600, "a": 770, "p": 0.07, "br": 185, "st": 0.51, "cd": 0.8,
		"img": preload("res://Assets/Gfx/Inventory_system/tank_green_outline.png"),
		"bd": "tankBody_green_outline.png",
		"muz": "tankGreen_barrel2_outline.png" },
	3: {
		"h": 9100, "a": 740, "p": 0.09, "br": 200, "st": 0.56, "cd": 1.0,
		"img": preload("res://Assets/Gfx/Inventory_system/tank_red_outline.png"),
		"bd": "tankBody_red_outline.png",
		"muz": "tankRed_barrel2_outline.png" },
	4: {
		"h": 9500, "a": 800, "p": 0.08, "br": 250, "st": 0.52, "cd": 0.65,
		"img": preload("res://Assets/Gfx/Inventory_system/tank_dark_outline.png"),
		"bd": "tankBody_dark_outline.png",
		"muz": "tankRed_barrel2_outline.png" },
	5: {
		"h": 8000, "a": 700, "p": 0.11, "br": 180, "st": 0.50, "cd": 0.5,
		"img": preload("res://Assets/Gfx/Inventory_system/tank_big_red_outline.png"),
		"bd": "tankBody_bigRed_outline.png",
		"muz": "specialBarrel6_outline.png" },
	6: {
		"h": 8800, "a": 850, "p": 0.15, "br": 260, "st": 0.60, "cd": 0.5,
		"img": preload("res://Assets/Gfx/Inventory_system/tank_dark_large_outline.png"),
		"bd": "tankBody_darkLarge_outline.png",
		"muz": "tankDark_barrel3_outline.png" },
	7: {
		"h": 10000, "a": 880, "p": 0.14, "br": 280, "st": 0.60, "cd": 0.45,
		"img": preload("res://Assets/Gfx/Inventory_system/tank_huge_outline.png"),
		"bd": "tankBody_huge_outline.png",
		"muz": "specialBarrel5_outline.png" }
}

export(int, 1, 7, 1) var tank_type: int = 1

var health: float
var accel: float
var e_power: float
var breaks: float
var steering: float
var cool_down_time: float



func _ready() -> void:
	texture = tanks_data[tank_type].img
	
	health = tanks_data[tank_type].h
	accel = tanks_data[tank_type].a
	e_power = tanks_data[tank_type].p
	breaks = tanks_data[tank_type].br
	steering = tanks_data[tank_type].st
	cool_down_time = tanks_data[tank_type].cd
	
	return
	
