class_name GameManager
extends Node2D

@export var map: PackedScene
@export var main_menu: PackedScene
@onready var round_timer: Timer = $RoundTimer

@onready var initial_countdown_timer: Timer = $CountdownTimer
@onready var initial_countdown_label: Label = $CanvasLayer/CenterContainer/CountdownLabel

@onready var round_number_label: Label = $CanvasLayer/UI/HBoxContainer/RoundNumberLabel
@onready var current_score: RichTextLabel = $CanvasLayer/UI/HBoxContainer/CurrentScore
@onready var time_left_label: Label = $CanvasLayer/UI/HBoxContainer/TimeLeftLabel

@onready var end_of_round_timer: Timer = $EndOfRoundTimer
@onready
var end_of_round_results: RichTextLabel = $CanvasLayer/CenterContainer/VBoxContainer/RoundResults
@onready var new_game_button: Button = $CanvasLayer/CenterContainer/VBoxContainer/NewGameButton
@onready var rematch_button: Button = $CanvasLayer/CenterContainer/VBoxContainer/RematchButton

#AUDIO
@onready var announcer_countdown_audio: AudioStreamPlayer = $SFX/AnnouncerCountdown
@onready var announcer_tie_audio: AudioStreamPlayer = $SFX/AnnouncerTie
@onready var announcer_red_kills_audio: AudioStreamPlayer = $SFX/AnnouncerRedKills
@onready var announcer_blue_kills_audio: AudioStreamPlayer = $SFX/AnnouncerBlueKills
@onready var announcer_startgame_audio: AudioStreamPlayer = $SFX/AnnouncerStartGame
@onready var announcer_endgame_audio: AudioStreamPlayer = $SFX/AnnouncerEndGame
@onready var announcer_red_wins_audio: AudioStreamPlayer = $SFX/AnnouncerRedWins
@onready var announcer_blue_wins_audio: AudioStreamPlayer = $SFX/AnnouncerBlueWins
@onready var announcer_nobody_wins_audio: AudioStreamPlayer = $SFX/AnnouncerNobodyWins

@export var player_scene: PackedScene

@onready var pause_menu: VBoxContainer = $CanvasLayer/PauseContainer/VBoxContainer

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
	$MainTheme.play()


func _process(delta: float) -> void:
	if waiting_for_map and Globals.selected_map:
		waiting_for_map = false
		setup_game()

	if Input.is_action_pressed("Pause"):
		if !get_tree().paused:
			pause_menu.show()
			get_tree().paused = true
		else:
			pause_menu.hide()
			get_tree().paused = false

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
	initial_countdown_label.show()
	end_of_round_results.hide()
	initial_countdown_timer.start()
	is_counting_down = true
	spawn_players()
	get_tree().call_group("player", "start_countdown")
	get_tree().call_group("laser", "start_countdown")
	count_ghosts()
	if current_round == 1:
		announcer_startgame_audio.play()
	else:
		announcer_countdown_audio.play()


#END ROUND
func end_round():
	if is_round_running:
		is_round_running = false
		if dead_players.size() == 0 or dead_players.size() == 2:
			end_of_round_results.text = "A tie!"
			announcer_tie_audio.play()
		elif 1 in dead_players:
			end_of_round_results.text = "Blue Jays Win!"
			scores["Blue Jays"] += 1
			#announcer_tie_audio.play()
			announcer_blue_kills_audio.play()
		elif 2 in dead_players:
			end_of_round_results.text = "Cardinals Win!"
			scores["Cardinals"] += 1
			announcer_red_kills_audio.play()
		else:
			end_of_round_results.text = "Not even godz knows what happened! I'm confused!"
		# turn previous round's players into ghosts
		current_score.text = (
			"[color=CRIMSON]%s[/color] - [color=ROYAL_BLUE]%s[/color]"
			% [scores["Cardinals"], scores["Blue Jays"]]
		)
		get_tree().call_group("player", "end_round")
		get_tree().call_group("laser", "end_round")
		end_of_round_results.show()
		end_of_round_timer.start()


func end_game():
	round_number_label.hide()
	$MainTheme/AnimationPlayer.play("FadeOutMusic")
	announcer_endgame_audio.play()
	await announcer_endgame_audio.finished
	await get_tree().create_timer(0.5).timeout
	current_score.hide()
	time_left_label.hide()
	end_of_round_results.text = (
		"[wave amp=50.0 freq=5.0 connected=1][rainbow freq=1.0 sat=0.8 val=0.8 speed=1.0]\nAnd that's game![/rainbow][/wave]\nScores:\n[color=CRIMSON]Cardinals: %s[/color]\n[color=ROYAL_BLUE]Blue Jays: %s[/color]"
		% [scores["Cardinals"], scores["Blue Jays"]]
	)
	if scores["Cardinals"] > scores["Blue Jays"]:
		announcer_red_wins_audio.play()
	elif scores["Blue Jays"] > scores["Cardinals"]:
		announcer_blue_wins_audio.play()
	else:
		announcer_nobody_wins_audio.play()
	end_of_round_results.show()
	rematch_button.show()
	new_game_button.show()


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
	current_round += 1
	if current_round > num_of_rounds:
		end_game()
	else:
		start_countdown()


func _on_new_game_button_pressed() -> void:
	#print("newgame loading")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_rematch_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	pause_menu.hide()
