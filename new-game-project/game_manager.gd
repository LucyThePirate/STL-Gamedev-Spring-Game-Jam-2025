class_name GameManager
extends Node2D

@export var map: PackedScene
@onready var round_timer: Timer = $RoundTimer
@onready var countdown_timer: Timer = $CountdownTimer

var waiting_for_map: bool = true
var round_length: int
var num_of_rounds: int
var current_round: int
var player1_spawn_pos: Vector2
var player2_spawn_pos: Vector2


func _process(delta: float) -> void:
	if waiting_for_map and Globals.selected_map:
		waiting_for_map = false
		setup_game()


func _ready() -> void:
	pass


func setup_game():
	map = Globals.selected_map
	num_of_rounds = Globals.selected_num_of_rounds
	round_length = Globals.selected_round_length
	call_deferred("load_map")


func load_map():
	var current_map = map.instantiate()
	get_tree().current_scene.add_child(current_map)
	print(num_of_rounds)


func start_round():
	pass


func end_round():
	pass


func end_game():
	pass
