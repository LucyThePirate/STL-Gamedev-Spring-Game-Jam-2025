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
		var lowestX = 1000.0
		var highestX = -1000.0
		var lowestY = 1000.0
		var highestY = -1000.0
		for n in player_count:
			if not is_instance_valid(n):
				continue
			position_count += n.global_position
			var nx = n.global_position.x
			var ny = n.global_position.y
			if nx <= lowestX:
				lowestX = nx
			if nx >= highestX:
				highestX = nx
			if ny <= lowestY:
				lowestY = ny
			if ny >= highestY:
				highestY = ny
		self.global_position.x = (lowestX + highestX) / 2
		self.global_position.y = (lowestY + highestY) / 2
		
		#print("Cam: ()" + str(self.global_position.x) + ", " + str(self.global_position.y) + ")")

		#var zoom_factor1 = abs(player2.global_position.x-player1.global_position.x)/(1152-100)
		var zoom_factor1 = abs(lowestX - highestX) / (1152 - 100)
		#var zoom_factor2 = abs(player2.global_position.y-player1.global_position.y)/(648-100)
		var zoom_factor2 = abs(lowestY - highestY) / (648 - 100)

		var zoom_factor = max(min(2 - zoom_factor1, 2 - zoom_factor2), 0.5)
		#print(zoom_factor)
		self.zoom = Vector2(zoom_factor, zoom_factor)
