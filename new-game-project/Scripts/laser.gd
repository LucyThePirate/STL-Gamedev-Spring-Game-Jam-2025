extends RayCast2D
@onready var laser_hit_audio: AudioStreamPlayer2D = $SFX/LaserHit
@onready var laser_fire_audio: AudioStreamPlayer2D = $SFX/LaserFire

@export var player_team_id = 1
@export var damage: int = 5
@export var can_hit_own_team := false

var direction: Vector2
var player_parent: Player
var max_length := 1000
var is_dangerous = true


func _ready():
	laser_fire_audio.play()


func _physics_process(delta: float) -> void:
	if not is_dangerous:
		return
	if is_colliding():
		var collider = get_collider()
		$LaserTexture.size.x = (get_collision_point() - global_position).length()
		#target_position = get_collision_point()
		_on_body_entered(collider)
	else:
		$LaserTexture.size.x = max_length


func fire(new_player_parent: Player, fire_position: Vector2):
	player_parent = new_player_parent
	player_team_id = player_parent.player_id
	add_exception(player_parent)
	if player_parent.player_id == 2:
		$LaserTexture.material.set("shader_parameter/outline_color", Color(29, 140, 255))
	global_position = fire_position
	target_position = player_parent.facing_direction * max_length
	$LaserTexture.rotation = player_parent.facing_direction.angle()


func disable_laser():
	is_dangerous = false


func _on_despawn_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):  #or ghost
		if body.has_method("get_hit"):
			if can_hit_own_team or (!can_hit_own_team and body.player_id != player_team_id):
				body.get_hit(damage)
				laser_hit_audio.play()
