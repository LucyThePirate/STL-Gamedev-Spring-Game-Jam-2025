extends CharacterBody2D

class_name Player

signal damaged(health_left)
signal died(player_id)
signal shot
signal taunted

@export var player_id = 1

@export var bullet_scene: PackedScene

#@onready var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")
@onready var bullet_spawn_pos: Marker2D = $Sprite2D/BulletSpawnPosition
@onready var shot_timer: Timer = $ShotTimer
@onready var visual: Node2D = $PlayerVisual
@onready var replayer: Node2D = $Replayer

var max_health = 100.0
var health = max_health

const SPEED = 230.0
const ACCEL = 20.0
enum States { IDLE, ROUND_START, DEAD, GHOST }
var state = States.ROUND_START

var input: Vector2
var move_direction: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.RIGHT
var is_shooting: bool = false
var is_shot_cooling: bool = false

var played_count = 0

var seconds_per_round_before_ghost_starts_moving := 1.5
var max_replays = 9


func _ready() -> void:
	visual.initialize(self)


func _physics_process(delta: float) -> void:
	if state == States.IDLE or state == States.ROUND_START:
		if !is_shooting and move_direction != Vector2.ZERO:
			facing_direction = move_direction.normalized()
			$Sprite2D.rotation = facing_direction.angle()

		if Input.is_action_pressed("Shoot P%s" % [player_id]):
			if !is_shooting:
				is_shooting = true
			shoot()
		else:
			is_shooting = false

		if Input.is_action_just_pressed("Taunt P%s" % [player_id]):
			taunted.emit()

		var playerInput = get_input()
		velocity = lerp(velocity, playerInput * SPEED, delta * ACCEL)
		move_and_slide()
	elif state == States.GHOST:
		if is_shooting:
			shoot()


func get_input():
	input.x = (
		Input.get_action_strength("Move P%s Right" % [player_id])
		- Input.get_action_strength("Move P%s Left" % [player_id])
	)
	input.y = (
		Input.get_action_strength("Move P%s Down" % [player_id])
		- Input.get_action_strength("Move P%s Up" % [player_id])
	)
	move_direction = input.normalized()

	return input.normalized()


func get_facing_direction() -> Vector2:
	return facing_direction


func set_facing_direction(direction: Vector2):
	facing_direction = direction
	$Sprite2D.rotation = direction.angle()


func shoot():
	if not is_shot_cooling and state in [States.IDLE, States.GHOST]:
		if state == States.GHOST and visual.is_ghost_spawn_visible():
			# Round hasn't started yet, don't let ghost player shoot
			return
		is_shot_cooling = true
		shot_timer.start()
		var bullet = bullet_scene.instantiate()
		bullet.fire(self, bullet_spawn_pos.global_position)
		get_tree().current_scene.add_child(bullet)
		shot.emit()


func _on_shot_timer_timeout() -> void:
	is_shot_cooling = false


func get_hit(damage):
	if state in [States.DEAD, States.ROUND_START]:
		return
	health -= damage
	if health > 0:
		damaged.emit(health)
	else:
		state = States.DEAD
		died.emit(player_id)


func start_countdown():
	if state == States.ROUND_START:
		replayer.recording = true
		replayer.record()
	if state == States.GHOST:
		visual.make_me_spooky()
		global_position = replayer.get_start_position()
		visual.set_ghost_spawn_visible(true)
		$GhostStartTimer.start(played_count * seconds_per_round_before_ghost_starts_moving)


func start_round():
	# Called by game_manager when the countdown timer is up
	if state == States.ROUND_START:
		state = States.IDLE
		# begin recording
	if state == States.GHOST:
		played_count += 1
		if max_replays and played_count > max_replays:
			queue_free()
		#print(name, "Has played:", played_count)
		visual.set_ghost_spawn_visible(false)


func end_round():
	#if state == States.DEAD:
	velocity = Vector2.ZERO
	if not is_in_group("ghost"):
		#if state == States.DEAD:
		#visual.make_me_spooky()
		state = States.GHOST
		add_to_group("ghost")
		$CollisionShape2D.set_deferred("disabled", true)
		# stop recording and playback
		replayer.recording = false
		replayer.record()
		is_shooting = false
	else:
		replayer.stopping = true


func vanish(is_vanished: bool):
	visual.vanish(is_vanished)


func _on_ghost_start_timer_timeout() -> void:
	replayer.play()
