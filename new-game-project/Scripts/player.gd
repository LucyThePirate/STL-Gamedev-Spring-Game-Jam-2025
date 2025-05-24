extends CharacterBody2D

@export var player_id = 1

const SPEED = 300.0
const ACCEL = 2.0

var input: Vector2

func get_input():
	input.x = Input.get_action_strength("Move P%s Right" % [player_id]) - Input.get_action_strength("Move P%s Left" % [player_id])
	input.y = Input.get_action_strength("Move P%s Down" % [player_id]) - Input.get_action_strength("Move P%s Up" % [player_id])
	return input.normalized()

func _process(delta: float) -> void:
	var playerInput = get_input()
	
	velocity = lerp(velocity, playerInput * SPEED, delta * ACCEL)
	
	move_and_slide()
