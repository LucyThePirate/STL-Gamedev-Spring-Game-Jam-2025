extends CharacterBody2D

@export var player_id = 1

@onready var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")
@onready var bullet_spawn_pos: Marker2D = $BulletSpawnPosition
@onready var shot_timer: Timer = $ShotTimer

const SPEED = 300.0
const ACCEL = 2.0

var input: Vector2
var move_direction: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.RIGHT
var is_shooting: bool = false
var is_shot_cooling: bool = false


func _physics_process(delta: float) -> void:
	if !is_shooting and move_direction != Vector2.ZERO:
		facing_direction = move_direction.normalized()

		rotation = facing_direction.angle()

	if Input.is_action_pressed("Shoot P%s" % [player_id]):
		if !is_shooting:
			is_shooting = true
		shoot()
	else:
		is_shooting = false


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


func _process(delta: float) -> void:
	var playerInput = get_input()

	velocity = lerp(velocity, playerInput * SPEED, delta * ACCEL)

	move_and_slide()


func shoot():
	if not is_shot_cooling:
		is_shot_cooling = true
		shot_timer.start()
		var bullet = bullet_scene.instantiate()
		bullet.global_position = bullet_spawn_pos.global_position
		bullet.setup(facing_direction)
		get_tree().current_scene.add_child(bullet)


func _on_shot_timer_timeout() -> void:
	is_shot_cooling = false
