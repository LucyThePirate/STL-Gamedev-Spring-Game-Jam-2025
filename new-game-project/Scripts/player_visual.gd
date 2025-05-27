extends Node2D

@export var player_2_texture: Texture2D

var player_parent: Player
var is_visual_flipped: bool = false

@onready var animation_tree = $AnimationTree


func initialize(player: Player):
	player_parent = player
	if player_parent.player_id == 2:
		for child in find_children_in_group(self, "PolygonTexture", true):
			child.texture = player_2_texture


func _ready() -> void:
	pass


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
