extends Node

var reload_count: int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	get_window().grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("DebugExit"):
		print_rich("[rainbow][wave]DEBUG: Debugging sesh complete![/wave][/rainbow]")
		get_tree().quit()
	if Input.is_action_just_pressed("DebugReloadScene"):
		print_rich("[color=LIME]DEBUG: Reloaded (", reload_count, ")")
		reload_count += 1
		get_tree().reload_current_scene()
