extends Control

@export var ls_buttons: Resource
@export var first_level: PackedScene

@onready var main_menu: Control = $MainMenu
@onready var level_select: Control = $LevelSelect
@onready var controls: Control = $Controls
@onready
var level_1_button: TextureButton = $LevelSelect/CenterContainer/HBoxContainer/GridContainer/Level1/Level1Button

var selected_level


func _process(delta: float) -> void:
	handle_level_selection()


func _ready() -> void:
	main_menu.show()
	level_select.hide()
	controls.hide()
	level_1_button.set_meta("level_path", first_level)
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
	selected_level = ls_buttons.get_pressed_button()


func _on_start_button_pressed() -> void:
	if selected_level:
		get_tree().change_scene_to_packed(selected_level.get_meta("level_path"))
	else:
		pass


#CONTROLS
func _on_controls_button_pressed() -> void:
	controls.show()
	main_menu.hide()


func _on_controls_back_button_pressed() -> void:
	print("Anything?")
	controls.hide()
	main_menu.show()


#QUIT
func _on_quit_button_pressed() -> void:
	get_tree().quit()
