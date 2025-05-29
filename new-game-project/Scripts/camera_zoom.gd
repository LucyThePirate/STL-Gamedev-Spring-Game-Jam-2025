extends Camera2D

@export var gameManager: Node
var managerScript: Script
var player1
var player2
var player_count: Array


func _ready():
	#player1 = get_node(object1)
	#player2 = get_node(object2)
	player_count = gameManager.ghost_count
	print(player_count)


func _process(delta) -> void:
	player_count = gameManager.ghost_count
	#print(player_count)
	if player_count.size() > 0:
		#self.global_position = (player1.global_position + player2.global_position) * 0.5
		var position_count: Vector2
		var lowestX = 0
		var highestX = 0
		var lowestY = 0
		var highestY = 0
		for n in player_count:
			position_count += n.global_position
			var nx = n.global_position.x
			var ny = n.global_position.y
			if nx <= lowestX:
				lowestX = nx
			elif nx >= highestX:
				highestX = nx
			if ny <= lowestY:
				lowestY = ny
			elif ny >= highestY:
				highestY = ny
		self.global_position = position_count / player_count.size()

		#var zoom_factor1 = abs(player2.global_position.x-player1.global_position.x)/(1152-100)
		var zoom_factor1 = abs(lowestX - highestX) / (1152 - 100)
		#var zoom_factor2 = abs(player2.global_position.y-player1.global_position.y)/(648-100)
		var zoom_factor2 = abs(lowestY - highestY) / (648 - 100)

		var zoom_factor = max(min(2 - zoom_factor1, 2 - zoom_factor2), 1)
		#print(zoom_factor)
		self.zoom = Vector2(zoom_factor, zoom_factor)
