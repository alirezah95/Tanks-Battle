extends PanelContainer

onready var _scroll_tween: Tween = $ScrollTween
onready var _tanks_scroll: ScrollContainer = \
	$InventoryVBox/MainPanel/MainVBox/HBox_2/ItemsCenter/Tanks/TanksScroll
onready var _left_bttn: TextureButton = \
	$InventoryVBox/MainPanel/MainVBox/HBox_2/ItemsCenter/Tanks/LeftBttn
onready var _right_bttn: TextureButton = \
	$InventoryVBox/MainPanel/MainVBox/HBox_2/ItemsCenter/Tanks/RightBttn
onready var _tanks_hbox: HBoxContainer = \
	$InventoryVBox/MainPanel/MainVBox/HBox_2/ItemsCenter/Tanks/TanksScroll/HBox
onready var _details_label: RichTextLabel = \
	$InventoryVBox/MainPanel/MainVBox/HBox_2/DetailsVBox/DetailsLabel

var _label_width: float
var _label_font: DynamicFont
var _current_tank_indx: int = 0
var _current_tank: InventoryTank = null
var _details_title: PoolStringArray = [
	"health:",
	"accel:",
	"power:",
	"breaks:",
	"steering:",
	"cool down:",
	]
var _accept_button_input: bool = true



func _ready() -> void:
	_label_width = (_details_label.rect_size.x - (_details_label.get_stylebox(
		"normal") as StyleBoxFlat).content_margin_left * 2)
	_label_font = _details_label.get_font("bold_font")
	_update_current_tank()
	
	return
	


func _update_current_tank() -> void:
	_current_tank = _tanks_hbox.get_child(_current_tank_indx)
	
	var details_string: String = ""
	var titles_values: Array = [
		_current_tank.health,
		_current_tank.accel,
		_current_tank.e_power,
		_current_tank.breaks,
		_current_tank.steering,
		_current_tank.cool_down_time
	]
	
	details_string = "[b]"
	var space_size: float = _label_font.get_string_size(" ").x
	for i in range(_details_title.size()):
		var title_text: String = _details_title[i] + str(titles_values[i])
		var title_w: float = _label_font.get_string_size(title_text).x
		var space_number: int = ((_label_width - title_w) / space_size)
		var space_str: String = ""
		for j in range(space_number):
			space_str += " "
		title_text = _details_title[i] + space_str + str(titles_values[i])
		details_string += title_text + "\n"
	
	details_string += "[/b]"
	_details_label.bbcode_text = details_string
	
	if _current_tank_indx == 0:
		_set_button_disabled(_left_bttn, true)
		_set_button_disabled(_right_bttn, false)
	elif _current_tank_indx == _tanks_hbox.get_child_count() - 1:
		_set_button_disabled(_left_bttn, false)
		_set_button_disabled(_right_bttn, true)
	else:
		_set_button_disabled(_left_bttn, false)
		_set_button_disabled(_right_bttn, false)
	
	return
	


func _set_button_disabled(button: TextureButton, disabled: bool) -> void:
	if disabled:
		button.disabled = true
		button.modulate = Color(1.0, 1.0, 1.0, 0.2)
	else:
		button.disabled = false
		button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	return
	


func _on_LeftBttn_pressed() -> void:
	if not _accept_button_input:
		return
	_accept_button_input = false
	_scroll_tween.interpolate_property(_tanks_scroll, "scroll_horizontal",
		_tanks_scroll.scroll_horizontal, _tanks_scroll.scroll_horizontal - 600,
		0.15);
	_scroll_tween.start()
	_current_tank_indx -= 1
	_update_current_tank()
	
	return
	


func _on_RightBttn_pressed() -> void:
	if not _accept_button_input:
		return
	_accept_button_input = false
	_scroll_tween.interpolate_property(_tanks_scroll, "scroll_horizontal",
		_tanks_scroll.scroll_horizontal, _tanks_scroll.scroll_horizontal + 600,
		0.15);
	_scroll_tween.start()
	_current_tank_indx += 1
	_update_current_tank()
	
	return
	


func _on_ScrollTween_tween_all_completed() -> void:
	_accept_button_input = true
	return
	


func _on_SaveBttn_pressed() -> void:
	Global.tank_specifiation = _current_tank.tanks_data[_current_tank.tank_type]
	Global.tank_specifiation.erase("img");
	
	var file: File = File.new()
	file.open("res://Assets/tank_spec.json", File.WRITE)
	file.store_string(to_json(Global.tank_specifiation))
	file.close()
	
	get_tree().change_scene("res://Scenes/Home.tscn")
	
	return
	


func _on_CloseBttn_pressed() -> void:
	get_tree().change_scene("res://Scenes/Home.tscn")
	return
	
