extends Node2D

# Array of all objects being recorded
@export var recorded_objects : Array[Node2D]
@onready var delay: Timer = $Delay

var frames = 0
var recording_data = {}
var recording = false

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
		recording_data[frames][cur_obj.name] = { "position" : cur_obj.global_position}
	frames += 1
	
	delay.start()
	
func play():
	for f in frames:
		#var tween = create_tween()
		for ro in recorded_objects: #NOT calling the size of the the array, but the objects themselves
			if f == 0:
				ro.global_position = recording_data[f][ro.name]["position"]
				print(recording_data)
			else: #if not initial frame, transition smoothly to intended position
				var tween = create_tween()
				tween.tween_property(ro, "global_position", recording_data[f][ro.name]["position"], 0.1)
		await get_tree().create_timer(0.1).timeout #let tween finish before moving on to next frame
			
	frames = 0
	#THIS RESETS THE RECORDING DATA - need some way to save it for our game
	recording_data = {}
	

func _on_delay_timeout() -> void:
	if recording:
		record()
