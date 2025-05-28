extends Camera2D

@export var object1:NodePath
@export var object2:NodePath
var player1
var player2

func _ready():
	player1 = get_node(object1)
	player2 = get_node(object2)

func _process(delta) -> void:
	self.global_position = (player1.global_position + player2.global_position) * 0.5

	var zoom_factor1 = abs(player2.global_position.x-player1.global_position.x)/(1152-100)
	var zoom_factor2 = abs(player2.global_position.y-player1.global_position.y)/(648-100)
	var zoom_factor = max(min((2 - zoom_factor1), (2 - zoom_factor2)), 1)
	#print(zoom_factor)

	self.zoom = Vector2(zoom_factor, zoom_factor)
