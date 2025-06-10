extends RayCast2D
@onready var laser_hit_audio: AudioStreamPlayer2D = $SFX/LaserHit
@onready var laser_fire_audio: AudioStreamPlayer2D = $SFX/LaserFire
@onready var ghost_laser_fire_audio: AudioStreamPlayer2D = $SFX/GhostLaserFire

@export var player_team_id = 1
@export var damage: int = 25
@export var can_hit_own_team := false

var direction: Vector2
var player_parent: Player
var max_length := 1000
var is_dangerous = true
var time_laser_was_shot: float
const TELEGRAPH_TIME := 1.5
const MAX_ROUNDS_ACTIVE = 9
var current_round = 0


func _ready():
	laser_fire_audio.play()


func _physics_process(delta: float) -> void:
	if is_colliding():
		$LaserTexture.size.x = (get_collision_point() - global_position).length()
		if not is_dangerous:
			return
		var collider = get_collider()
		#target_position = get_collision_point()
		_on_body_entered(collider)
	else:
		$LaserTexture.size.x = max_length


func fire(new_player_parent: Player, fire_position: Vector2, time_shot: float):
	time_laser_was_shot = time_shot
	player_parent = new_player_parent
	player_team_id = player_parent.player_id
	add_exception(player_parent)
	if player_parent.player_id == 2:
		$LaserTexture.material.set("shader_parameter/outline_color", Color(29, 140, 255))
	global_position = fire_position
	target_position = player_parent.facing_direction * max_length
	$LaserTexture.rotation = player_parent.facing_direction.angle()


func set_laser_dangerous(set_danger = false):
	is_dangerous = set_danger


func _on_despawn_timer_timeout() -> void:
	#queue_free()
	is_dangerous = false
	hide()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):  #or ghost
		if body.has_method("get_hit"):
			if can_hit_own_team or (!can_hit_own_team and body.player_id != player_team_id):
				body.get_hit(damage)
				laser_hit_audio.play()
				set_laser_dangerous(false)


func _on_respawn_timer_timeout() -> void:
	ghost_laser_fire_audio.play()
	$DespawnTimer.start()
	$AnimationPlayer.play("fade")
	is_dangerous = true


func start_countdown():
	is_dangerous = false
	$RespawnTimer.start(time_laser_was_shot)
	$TelegraphTimer.start(time_laser_was_shot - TELEGRAPH_TIME)


func end_round():
	$RespawnTimer.stop()
	$TelegraphTimer.stop()
	$AnimationPlayer.play("fade")
	current_round += 1
	if current_round > MAX_ROUNDS_ACTIVE:
		queue_free()


func _on_telegraph_timer_timeout() -> void:
	show()
	if player_parent.player_id == 1:
		$AnimationPlayer.play("telegraph_red")
	else:
		$AnimationPlayer.play("telegraph_blue")
