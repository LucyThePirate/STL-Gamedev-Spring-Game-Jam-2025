class_name GameManager
extends Node2D

@export var map: PackedScene
@onready var round_timer: Timer = $RoundTimer

@onready var initial_countdown_timer: Timer = $CountdownTimer
@onready var initial_countdown_label: Label = $CanvasLayer/CenterContainer/CountdownLabel

@onready var round_number_label: Label = $CanvasLayer/UI/HBoxContainer/RoundNumberLabel
@onready var time_left_label: Label = $CanvasLayer/UI/HBoxContainer/TimeLeftLabel

@onready var end_of_round_timer: Timer = $EndOfRoundTimer
@onready var end_of_round_results: RichTextLabel = $CanvasLayer/CenterContainer/RoundResults

@export var player_scene: PackedScene

var waiting_for_map: bool = true
var round_length: int
var num_of_rounds: int
var current_round: int = 1
var player1_spawn_pos: Vector2
var player2_spawn_pos: Vector2
var ghost_count: Array

var is_counting_down: bool = false
var is_round_running: bool = true

var dead_players := []
var scores := {"Cardinals": 0, "Blue Jays": 0}


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
	round_number_label.text = "Round: " + String.num(current_round, 0)


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


func count_ghosts():
	ghost_count.clear()
	for n in self.get_children():
		if n is Player:
			ghost_count.append(n)
	#print(ghost_count.size())


func spawn_players():
	var player_1 = player_scene.instantiate() as Player
	var player_2 = player_scene.instantiate() as Player
	player_1.name = "P1 R" + str(current_round)
	player_2.name = "P2 R" + str(current_round)
	player_2.player_id = 2
	player_1.died.connect(_on_player_died)
	player_2.died.connect(_on_player_died)
	add_child(player_1)
	add_child(player_2)
	player_1.global_position = player1_spawn_pos
	player_2.global_position = player2_spawn_pos


#SETUP TIMERS
func setup_round_timer():
	round_timer.wait_time = round_length


func start_countdown():
	initial_countdown_timer.start()
	is_counting_down = true
	spawn_players()
	count_ghosts()


#END ROUND
func end_round():
	if is_round_running:
		is_round_running = false
		if dead_players.size() == 0 or dead_players.size() == 2:
			end_of_round_results.text = "A tie!"
		elif 1 in dead_players:
			end_of_round_results.text = "Blue Jays Win!"
			scores["Blue Jays"] += 1
		elif 2 in dead_players:
			end_of_round_results.text = "Cardinals Win!"
			scores["Cardinals"] += 1
		else:
			end_of_round_results.text = "Not even god knows what happened! I'm confused!"
		# turn previous round's players into ghosts
		get_tree().call_group("player", "end_round")
		current_round += 1
		end_of_round_results.show()
		if current_round > num_of_rounds:
			end_game()
		else:
			end_of_round_timer.start()


func end_game():
	round_number_label.hide()
	time_left_label.hide()
	end_of_round_results.text = (
		"[wave amp=50.0 freq=5.0 connected=1][rainbow freq=1.0 sat=0.8 val=0.8 speed=1.0]And that's game![/rainbow][/wave]\nScores:\n[color=CRIMSON]Cardinals: %s[/color]\n[color=ROYAL_BLUE]Blue Jays: %s[/color]"
		% [scores["Cardinals"], scores["Blue Jays"]]
	)
	end_of_round_results.show()


func _on_player_died(player_id):
	round_timer.stop()
	dead_players.append(player_id)
	end_round()


func _on_countdown_timer_timeout() -> void:
	initial_countdown_label.hide()
	end_of_round_results.hide()
	round_timer.start()
	dead_players = []
	is_round_running = true
	get_tree().call_group("player", "start_round")


func _on_round_timer_timeout() -> void:
	end_round()


func _on_end_of_round_timer_timeout() -> void:
	start_countdown()
