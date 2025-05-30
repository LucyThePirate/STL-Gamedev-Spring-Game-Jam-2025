extends Control

@export var ls_buttons: Resource
@export var prototype_map: PackedScene
@export var game_manager: PackedScene

@onready var main_menu: Control = $MainMenu
@onready var level_select: Control = $LevelSelect
@onready var controls: Control = $Controls
@onready var options: Control = $Options
@onready var credits: Control = $Credits
@onready
var level_1_button: TextureButton = $LevelSelect/CenterContainer/HBoxContainer/GridContainer/Level1/Level1Button
@onready
var round_length_selector: OptionButton = $LevelSelect/CenterContainer/HBoxContainer/RoundLength/RoundLengthSelector

var selected_map
var selected_round_length: int = 60
var selected_num_of_rounds: int = 3


func _process(delta: float) -> void:
	handle_level_selection()


func _ready() -> void:
	main_menu.show()
	level_select.hide()
	controls.hide()
	options.hide()
	credits.hide()
	level_1_button.set_meta("level_path", prototype_map)
	round_length_selector.set_item_metadata(0, 5)
	round_length_selector.set_item_metadata(1, 10)
	round_length_selector.set_item_metadata(2, 30)
	round_length_selector.set_item_metadata(3, 60)
	round_length_selector.set_item_metadata(4, 300)
	#level 2 meta
	#level 3 meta


#NEW GAME
func _on_new_game_button_pressed() -> void:
	main_menu.hide()
	level_select.show()


func _on_level_select_back_button_pressed() -> void:
	level_select.hide()
	main_menu.show()


func handle_level_selection():
	selected_map = ls_buttons.get_pressed_button()


func _on_start_button_pressed() -> void:
	if selected_map:
		Globals.selected_map = selected_map.get_meta("level_path")
		Globals.selected_round_length = selected_round_length
		Globals.selected_num_of_rounds = selected_num_of_rounds
		get_tree().change_scene_to_packed(game_manager)
	else:
		pass


#CONTROLS
func _on_controls_button_pressed() -> void:
	controls.show()
	main_menu.hide()


func _on_controls_back_button_pressed() -> void:
	controls.hide()
	main_menu.show()


#QUIT
func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_round_length_selector_item_selected(index: int) -> void:
	selected_round_length = round_length_selector.get_item_metadata(index)


func _on_spin_box_value_changed(value: float) -> void:
	selected_num_of_rounds = value


func _on_credits_button_pressed() -> void:
	credits.show()
	main_menu.hide()


func _on_credits_back_button_pressed() -> void:
	credits.hide()
	main_menu.show()


func _on_options_back_button_pressed() -> void:
	options.hide()
	main_menu.show()


func _on_options_button_pressed() -> void:
	options.show()
	main_menu.hide()
