extends Control

@export var ls_buttons: Resource
@export var map_lab: PackedScene
@export var map_hospital: PackedScene
@export var map_elevator: PackedScene
@export var map_factory: PackedScene
@export var map_raffles: PackedScene
@export var map_residential: PackedScene
@export var map_helipad: PackedScene
@export var game_manager: PackedScene

@onready var main_menu: Control = $MainMenu
@onready var level_select: Control = $LevelSelect
@onready var controls: Control = $Controls
@onready var options: Control = $Options
@onready var credits: Control = $Credits
@onready var title_graphic: Sprite2D = $TitleGraphics/Title
@onready
var map_lab_button: TextureButton = $LevelSelect/CenterContainer/HBoxContainer/VBoxContainer2/GridContainer/Level1/MapLabButton

@onready
var map_hospital_button: TextureButton = $LevelSelect/CenterContainer/HBoxContainer/VBoxContainer2/GridContainer/Level2/MapHospitalButton

@onready
var map_elevator_button: TextureButton = $LevelSelect/CenterContainer/HBoxContainer/VBoxContainer2/GridContainer/Level3/MapElevatorButton

@onready
var map_raffles_button: TextureButton = $LevelSelect/CenterContainer/HBoxContainer/VBoxContainer2/GridContainer/Level5/MapRafflesButton

@onready
var map_factory_button: TextureButton = $LevelSelect/CenterContainer/HBoxContainer/VBoxContainer2/GridContainer/Level4/MapFactoryButton

@onready
var map_residential_button: TextureButton = $LevelSelect/CenterContainer/HBoxContainer/VBoxContainer2/GridContainer/Level6/MapResidentialButton

@onready
var map_helipad_button: TextureButton = $LevelSelect/CenterContainer/HBoxContainer/VBoxContainer2/GridContainer/Level7/MapHelipadButton

@onready
var round_length_selector: OptionButton = $LevelSelect/CenterContainer/HBoxContainer/RoundLength/RoundLengthSelector

@onready
var announcer_goodbye: AudioStreamPlayer = $MainMenu/CenterContainer/EntranceButtons/QuitButton/AnnouncerGoodbye
@onready var announcer_welcome: AudioStreamPlayer = $AnnouncerWelcome

var selected_map
var selected_round_length: int = 30
var selected_num_of_rounds: int = 9


func _process(delta: float) -> void:
	handle_level_selection()


func _ready() -> void:
	announcer_welcome.play()
	main_menu.show()
	level_select.hide()
	controls.hide()
	options.hide()
	credits.hide()
	map_lab_button.set_meta("level_path", map_lab)
	map_hospital_button.set_meta("level_path", map_hospital)
	map_elevator_button.set_meta("level_path", map_elevator)
	map_factory_button.set_meta("level_path", map_factory)
	map_raffles_button.set_meta("level_path", map_raffles)
	map_residential_button.set_meta("level_path", map_residential)
	map_helipad_button.set_meta("level_path", map_helipad)

	round_length_selector.set_item_metadata(0, 5)
	round_length_selector.set_item_metadata(1, 10)
	round_length_selector.set_item_metadata(2, 30)
	round_length_selector.set_item_metadata(3, 60)
	round_length_selector.set_item_metadata(4, 300)
	#level 2 meta
	#level 3 meta


#NEW GAME
func _on_new_game_button_pressed() -> void:
	$UiLevelSelectStart01.play()
	main_menu.hide()
	title_graphic.hide()
	level_select.show()
	$LevelSelectMusic.play()
	$TitleMusic.stop()


func _on_level_select_back_button_pressed() -> void:
	level_select.hide()
	main_menu.show()
	title_graphic.show()
	$LevelSelectMusic.stop()
	$TitleMusic.play()
	$UiLevelSelectBack01.play()


func handle_level_selection():
	if selected_map != ls_buttons.get_pressed_button():
		$LevelSelect/CenterContainer/HBoxContainer/RoundLength/RoundLengthSelector/UIGeneric.play()
		selected_map = ls_buttons.get_pressed_button()


func _on_start_button_pressed() -> void:
	if selected_map:
		$UiMainMenuStart01.play()
		await get_tree().create_timer(1).timeout
		Globals.selected_map = selected_map.get_meta("level_path")
		Globals.selected_round_length = selected_round_length
		Globals.selected_num_of_rounds = selected_num_of_rounds
		get_tree().change_scene_to_packed(game_manager)
	else:
		$LevelSelect/CenterContainer/HBoxContainer/VBoxContainer/StartButton/error.play()


#CONTROLS
func _on_controls_button_pressed() -> void:
	controls.show()
	main_menu.hide()
	title_graphic.hide()
	$UiLevelSelectStart01.play()


func _on_controls_back_button_pressed() -> void:
	controls.hide()
	main_menu.show()
	title_graphic.show()
	$UiLevelSelectBack01.play()


#QUIT
func _on_quit_button_pressed() -> void:
	$UiLevelSelectStart01.play()
	announcer_welcome.stop()
	announcer_goodbye.play()
	await announcer_goodbye.finished
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()


func _on_round_length_selector_item_selected(index: int) -> void:
	selected_round_length = round_length_selector.get_item_metadata(index)
	$LevelSelect/CenterContainer/HBoxContainer/RoundLength/RoundLengthSelector/UIGeneric.play()


func _on_spin_box_value_changed(value: float) -> void:
	if value > selected_num_of_rounds:
		(
			$LevelSelect/CenterContainer/HBoxContainer/RoundAmount/SpinBox/UiLevelSelectTickerUp01
			. play()
		)
	else:
		(
			$LevelSelect/CenterContainer/HBoxContainer/RoundAmount/SpinBox/UiLevelSelectTickerDown01
			. play()
		)
	selected_num_of_rounds = value


func _on_credits_button_pressed() -> void:
	credits.show()
	main_menu.hide()
	title_graphic.hide()
	$UiLevelSelectStart01.play()


func _on_credits_back_button_pressed() -> void:
	credits.hide()
	main_menu.show()
	title_graphic.show()
	$UiLevelSelectBack01.play()


func _on_options_back_button_pressed() -> void:
	options.hide()
	main_menu.show()
	title_graphic.show()
	$UiLevelSelectBack01.play()


func _on_options_button_pressed() -> void:
	options.show()
	main_menu.hide()
	title_graphic.hide()
	$UiLevelSelectStart01.play()


func _on_master_volume_value_changed(value: float) -> void:
	var bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus, value)


func _on_ambience_volume_value_changed(value: float) -> void:
	var bus = AudioServer.get_bus_index("Ambience")
	AudioServer.set_bus_volume_db(bus, value)
	bus = AudioServer.get_bus_index("Reverb")
	AudioServer.set_bus_volume_db(bus, value)


func _on_sfx_value_changed(value: float) -> void:
	var bus = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus, value)
	$Options/CenterContainer/VBoxContainer/HBoxContainer2/SFXTest.play()


func _on_music_volume_value_changed(value: float) -> void:
	var bus = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus, value)


func _on_announcer_volume_value_changed(value: float) -> void:
	var bus = AudioServer.get_bus_index("Announcer")
	AudioServer.set_bus_volume_db(bus, value)
	$Options/CenterContainer/VBoxContainer/HBoxContainer4/AnnouncerTest.play()
