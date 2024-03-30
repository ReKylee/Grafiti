extends TextureRect

@export var action_name:StringName = ""
@export var device:DeviceIndex = -2


enum DeviceIndex {ACTIVE=-2, KEYBOARD_AND_MOUSE =-1, JOY0 = 0, JOY1 = 1, JOY2 = 2, JOY3 = 3, JOY4 = 4, JOY5 = 5, JOY6 = 6, JOY7 = 7, JOY8 = 8, JOY9 = 9}

var curr_action_name:StringName = ""
var curr_device:int = -2
var curr_active_device:int = -999

func _ready():
	connect("visibility_changed", visibility_check)
	visibility_check()
	
	Inputty.input_binding_changed.connect(update_prompt_texture)

func _exit_tree():
	Inputty.input_binding_changed.disconnect(update_prompt_texture)

func visibility_check():
	if is_visible_in_tree():
		set_process(true)
	else:
		set_process(false)

func update_prompt_texture():
	curr_action_name = action_name
	curr_device = device
	curr_active_device = Inputty.activeDevice
	texture = Inputty.get_action_icon(action_name, device)

func _process(delta):
	
	if curr_action_name==action_name and curr_device==device:
		if curr_device==-2 and curr_active_device != Inputty.activeDevice:
			pass#the active device has changed and we want to show it
		else:
			return
	update_prompt_texture()
