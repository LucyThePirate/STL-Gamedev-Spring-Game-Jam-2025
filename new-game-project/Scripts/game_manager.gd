class_name GameManager
extends Node2D

@export var map: PackedScene
@onready var round_timer: Timer = $RoundTimer

@onready var initial_countdown_timer: Timer = $CountdownTimer
@onready var initial_countdown_label: Label = $CanvasLayer/CenterContainer/CountdownLabel

@onready var round_number_label: Label = $UI/HBoxContainer/RoundNumberLabel
@onready var time_left_label: Label = $UI/HBoxContainer/TimeLeftLabel

@onready var player_1: Player = $"Player 1"
@onready var player_2: Player = $"Player 2"

@onready var replayer: Node2D = $Replayer


var waiting_for_map: bool = true
var round_length: int
var num_of_rounds: int
var current_round: int
var player1_spawn_pos: Vector2
var player2_spawn_pos: Vector2

var is_counting_down: bool = false
var is_round_running: bool = true
		

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	start_countdown()
	print(round_length)


func _process(delta: float) -> void:
	if waiting_for_map and Globals.selected_map:
		waiting_for_map = false
		setup_game()

	initial_countdown_label.text = String.num(initial_countdown_timer.time_left, 0)
	time_left_label.text = "Time remaining: " + String.num(round_timer.time_left, 0)
	round_number_label.text = "Round: " + String.num(num_of_rounds, 0)


#LOAD IN ASSETS


func setup_game():
	map = Globals.selected_map
	num_of_rounds = Globals.selected_num_of_rounds
	round_length = Globals.selected_round_length

	setup_round_timer()
	call_deferred("load_map")


func load_map():
	var current_map = map.instantiate()
	get_tree().current_scene.add_child(current_map)
	player1_spawn_pos = current_map.get_node("Player1Spawn").global_position
	player2_spawn_pos = current_map.get_node("Player2Spawn").global_position
	spawn_players()


func spawn_players():
	player_1.global_position = player1_spawn_pos
	player_2.global_position = player2_spawn_pos


#SETUP TIMERS
func setup_round_timer():
	round_timer.wait_time = round_length


func start_countdown():
	initial_countdown_timer.start()
	is_counting_down = true
	

	


#END ROUND


func end_round():
	#stop recording and playback
	replayer.recording = false
	replayer.record()
	replayer.play()


func end_game():
	pass


func _on_countdown_timer_timeout() -> void:
	initial_countdown_label.hide()
	round_timer.start()
	is_round_running = true
		#begin recording
	replayer.recording = true
	replayer.record()

func _on_round_timer_timeout() -> void:
	end_round()
