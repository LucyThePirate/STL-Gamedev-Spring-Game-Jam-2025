extends Node2D

@export var player_2_texture: Texture2D
@export var player_2_ghost_spawn_texture: Texture2D

var player_parent: Player
var is_visual_flipped: bool = false
var should_be_vanished: bool = false
var vanish_amount: float = 0

var VANISH_SPEED = 0.3

@onready var animation_tree = $AnimationTree
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D


func initialize(player: Player):
	player_parent = player
	# Swap texture to bluejay if player 2
	if player_parent.player_id == 2:
		for child in find_children_in_group(self, "PolygonTexture", true):
			child.texture = player_2_texture
		$GhostSpawn.texture = player_2_ghost_spawn_texture
	# Connect with player's signals for damage/death animation
	player_parent.damaged.connect(_on_player_damaged)
	player_parent.died.connect(_on_player_died)


func set_ghost_spawn_position(new_position: Vector2):
	$GhostSpawn.show()
	$GhostSpawn.global_position = new_position


func set_ghost_spawn_visible(is_visible: bool):
	$GhostSpawn.visible = is_visible
	$GhostSpawnParticles.emitting = is_visible
	$GhostSpawnAppearParticles.emitting = !is_visible
	$Body.visible = !is_visible
	$Wing.visible = !is_visible


func is_ghost_spawn_visible() -> bool:
	return $GhostSpawn.visible


func _process(delta: float) -> void:
	if not player_parent:
		return

	# Flipping animation
	if (
		(player_parent.facing_direction.x > 0 and not is_visual_flipped)
		or (player_parent.facing_direction.x < 0 and is_visual_flipped)
	):
		scale.x *= -1
		is_visual_flipped = !is_visual_flipped

	# Running
	if player_parent.velocity.length() > 0.1:
		var speed = player_parent.velocity.length() / player_parent.SPEED
		animation_tree.set("parameters/RunSpeed/scale", speed)
		animation_tree.set("parameters/Run/add_amount", speed)
	else:
		animation_tree.set("parameters/RunSpeed/scale", 0.0)
		animation_tree.set("parameters/Run/add_amount", 0.0)

	# Control player ghost vanishing
	if should_be_vanished:
		vanish_amount = move_toward(vanish_amount, 1, delta * VANISH_SPEED)
	else:
		vanish_amount = move_toward(vanish_amount, 0, delta * VANISH_SPEED)
	animation_tree.set("parameters/Vanish/blend_amount", vanish_amount)


func _on_player_damaged(health_remaining):
	print("hit! Health left:", health_remaining)
	animation_tree.set("parameters/Damaged/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _on_player_died(player_id):
	print(player_id, "died!")
	animation_tree.set("parameters/Die/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func make_me_spooky():
	for child in find_children_in_group(self, "PolygonTexture", true):
		child.self_modulate = Color8(255, 255, 255, 114)
		audio_stream_player_2d.stop()


func vanish(is_vanished: bool):
	should_be_vanished = is_vanished


func _pause_animations():
	animation_tree.set("parameters/DieTimeScale/scale", 0.0)


# Credit to this function goes to tknockaert from: https://forum.godotengine.org/t/is-there-a-way-to-get-any-offspring-that-belongs-in-a-certain-group-directly/14265/4
static func find_children_in_group(parent: Node, group: String, recursive: bool = false):
	var output: Array[Node] = []
	for child in parent.get_children():
		if child.is_in_group(group):
			output.append(child)
	if recursive:
		for child in parent.get_children():
			var recursive_output = find_children_in_group(child, group, recursive)
			for recursive_child in recursive_output:
				output.append(recursive_child)
	return output
