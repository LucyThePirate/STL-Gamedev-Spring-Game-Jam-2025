extends Node2D

# Array of all objects being recorded
@export var recorded_objects: Array[Node2D]
@onready var delay: Timer = $Delay
@onready var game_manager: Control = $GameManager

var frames = 0
var recording_data = {}
var recording = false
var stopping = false


func record():
	if !recording:
		delay.stop()
		return

	#recording data is a dictionary that contains the different frames
	#each frame is ITSELF a dictionary, whose key is the object name and whose value is ANOTHER dictionary
	#containing the data about that specific object

	for ro in recorded_objects.size():
		if ro == 0:
			recording_data[frames] = {}
		var cur_obj = recorded_objects[ro]
		recording_data[frames][cur_obj.name] = {
			"position": cur_obj.global_position,
			"rotation": cur_obj.get_facing_direction(),
			"velocity": cur_obj.velocity,
			"is_shooting": cur_obj.is_shooting
			#"health": cur_obj.health
		}
	frames += 1

	delay.start()


func get_start_position() -> Vector2:
	return recording_data[0][recorded_objects[0].name]["position"]


func play():
	stopping = false
	for f in frames:
		#var tween = create_tween()

		for ro in recorded_objects:  #NOT calling the size of the the array, but the objects themselves
			ro.is_shooting = false
			ro.velocity = Vector2.ZERO
			if f == 0:
				ro.vanish(false)
				ro.global_position = recording_data[f][ro.name]["position"]
				ro.set_facing_direction(recording_data[f][ro.name]["rotation"])
				ro.velocity = recording_data[f][ro.name]["velocity"]
				ro.is_shooting = recording_data[f][ro.name]["is_shooting"]
				#ro.health = recording_data[f][ro.name]["health"]
				#print(recording_data)
			else:  #if not initial frame, transition smoothly to intended position
				var tween = create_tween()
				tween.tween_property(
					ro, "global_position", recording_data[f][ro.name]["position"], 0.1
				)
				#ro.global_position = recording_data[f][ro.name]["position"]

				ro.set_facing_direction(recording_data[f][ro.name]["rotation"])
				ro.velocity = recording_data[f][ro.name]["velocity"]
				ro.is_shooting = recording_data[f][ro.name]["is_shooting"]
				#ro.health = recording_data[f][ro.name]["health"]
				#ro.velocity = ro.global_position - recording_data[f][ro.name]["position"]
		await get_tree().create_timer(0.1).timeout  #let tween finish before moving on to next frame
		#get_node(.)
		if stopping:
			stopping = false
			break
	for ro in recorded_objects:
		# Turn off shooting/movement at end of recording
		ro.is_shooting = false
		ro.velocity = Vector2.ZERO
		ro.vanish(true)
	#frames = 0
	#THIS RESETS THE RECORDING DATA - need some way to save it for our game
	#recording_data = {}


func _on_delay_timeout() -> void:
	if recording:
		record()
