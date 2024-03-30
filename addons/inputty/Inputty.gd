extends Node
## An input wrapper to provide extra functionality
##
## Inputty provides several advantages over Godot's base [Input]
## system including per-device action polling, a rebinding scene,
## input prompts and icons, and customisable input properties.[br]
## [br]
## In most cases, you can simply replace [code]Input[/code] with [code]Inputty[/code] in your scripts.[br]
## [br]
## For cases where Inputty lack's Godot's Input functionality,
## you can fall back to using that and still have any custom bindings work.[br]
## [br]
## For more info check: [url=https://codeberg.org/MxSophie/Inputty]Inputty on Codeberg[/url]


## Signal emmited when an input map is applied by [InputRemap] (even if it has had no changes to the current map).
signal input_binding_changed

## Enumeration for distinguishing different input devices.
## Integers can be used instead for cases where there are more than 10 joypads.
enum DeviceIndex {
	ACTIVE_OR_ANY=-2,
	KEYBOARD_AND_MOUSE =-1,
	JOY0 = 0, JOY1 = 1, JOY2 = 2, JOY3 = 3, JOY4 = 4, JOY5 = 5, JOY6 = 6, JOY7 = 7, JOY8 = 8, JOY9 = 9,
}

#The current InputRemap instance
var _inputRemap:InputRemap

## How long after an initial input that [method is_action_just_ticked] will begin repeatedly returning true.
var tickDelayTime:float = 1.0
## How long between each repeated 'true' result when using [method is_action_just_ticked].
var tickRepeatTime:float = 0.3


## The [InputtyMap] currently being used by Inputty.
var inputMap:InputtyMap

# The default input map.
var _inputMapDefault:InputtyMap

# Resources required for Inputty that can be customised in the editor by the developer.
var _resources:InputtyResourceRefs = preload("res://addons/inputty/inputty_resources.tres")

## The [enum DeviceIndex] of the device most recently active
var activeDevice := -1
## The name of the device most recently active
var activeDeviceName := "Keyboard"
## The [enum DeviceIndex] of the joypad device most recently active
var activeJoy := -1
## The name of the joypad device most recently active
var activeJoyName := ""

var _keyboardIcons:InputtyKeyboardDisplaySet = _resources.keyboardIconSet
var _joyIconSets:Array[InputtyDisplaySet]


func _init():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func _ready():
	_inputMapDefault = InputtyMap.new()
	inputMap = InputtyMap.new()
	_inputMapDefault.copyFromMain()
	inputMap.copyFrom(_inputMapDefault)
	
	
	_inputMapDefault.properties += _resources.properties
	inputMap.properties += _resources.properties
	
	inputMap.loadFromFile()
	
	Input.connect("joy_connection_changed", _on_joy_connection_changed)
	_pollJoys()

## Returns the device that just pressed the specified [code]actionName[/code]:[br]
## ~  -99 for none/no input[br]
## ~  -1 for keyboard input[br]
## ~  0+ for joypad input[br][br]
## This function is primarily made for local multiplayer games with a "Press {Button} to Join" screen.
func which_device_just_pressed(actionName:StringName)->int:
	var action:InputtyAction = inputMap.getAction(actionName)
	if !action:
		return -99
	
	if Engine.is_in_physics_frame():
		#physics process check
		for state in action.states:
			if state.just_pressed_physics == Engine.get_physics_frames():
				return state.device
		
	#idle (frame) process check
	for state in action.states:
			if state.just_pressed_idle == Engine.get_frames_drawn():
				return state.device
	
	return -99

## Returns 'true' if the specified [code]actionName[/code] has an input currently pressed.
## [br][br][code]device[/code] is used to specify which [enum DeviceIndex] is polled.
func is_action_pressed(actionName:StringName, device:int=DeviceIndex.ACTIVE_OR_ANY)->bool:
	var action:InputtyAction = inputMap.getAction(actionName)
	if !action:
		return false
	
	return action.getActionState(device).pressed

## Equivalent to [method is_action_just_pressed] which will also repeatedly return
## true after a delay. Adjust the delay and the repeat time by setting [member tickDelayTime] and [member tickRepeatTime]
## [br][br][code]device[/code] is used to specify which [enum DeviceIndex] is polled.
func is_action_just_ticked(actionName:StringName, device:int=DeviceIndex.ACTIVE_OR_ANY)->bool:
	var action:InputtyAction = inputMap.getAction(actionName)
	if !action:
		return false
	
	var deviceState:InputtyActionState = action.getActionState(device)
	
	if Engine.is_in_physics_frame():
		#physics process check
		if deviceState.just_pressed_physics == Engine.get_physics_frames():
			return true
		if _physicsTick>=0.0:
			return false
		return deviceState.pressed and (Time.get_ticks_msec()-deviceState.pressed_time)>tickDelayTime*1000
		
	#idle (frame) process check
	if deviceState.just_pressed_idle == Engine.get_frames_drawn():
		return true
	if _idleTick>=0.0:
		return false
	return deviceState.pressed and (Time.get_ticks_msec()-deviceState.pressed_time)>tickDelayTime*1000

## Returns 'true' if the specified [code]actionName[/code] has been pressed this frame.[br]
## [i]Note that a true result doesn't necessarily mean the action is still being pressed.[/i][br][br]
## Calls to this function work from both idle (frame update) and physics processes.
## [br][br][code]device[/code] is used to specify which [enum DeviceIndex] is polled.
func is_action_just_pressed(actionName:StringName, device:int=-2)->bool:
	var action:InputtyAction = inputMap.getAction(actionName)
	if !action:
		return false
	
	if Engine.is_in_physics_frame():
		#physics process check
		return action.getActionState(device).just_pressed_physics == Engine.get_physics_frames()
		
	#idle (frame) process check
	return action.getActionState(device).just_pressed_idle == Engine.get_frames_drawn()
	
## Returns 'true' if the specified [code]actionName[/code] has been released this frame.[br]
## [i]Note that a true result doesn't necessarily mean the action is not being pressed.[/i][br][br]
## Calls to this function work from both idle (frame update) and physics processes.
## [br][br][code]device[/code] is used to specify which [enum DeviceIndex] is polled.
func is_action_just_released(actionName:StringName, device:int=-2)->bool:
	var action:InputtyAction = inputMap.getAction(actionName)
	if !action:
		return false
		
	if Engine.is_in_physics_frame():
		#physics process check
		return action.getActionState(device).just_released_physics == Engine.get_physics_frames()
		
	#idle (frame) process check
	return action.getActionState(device).just_released_idle == Engine.get_frames_drawn()

## Returns a value between 0 and 1 representing the intensity of the given action.
## [br][br][code]device[/code] is used to specify which [enum DeviceIndex] is polled.
func get_action_strength(actionName:StringName, device:int=-2)->float:
	var action:InputtyAction = inputMap.getAction(actionName)
	if !action:
		return 0.0
	
	return action.getActionState(device).strength

## Returns a value between 0 and 1 representing the raw intensity of the given action,
## ignoring the action's deadzone. In most cases, you should use [method get_action_strength] instead.
## [br][br][code]device[/code] is used to specify which [enum DeviceIndex] is polled.
func get_action_raw_strength(actionName:StringName, device:int=-2)->float:
	var action:InputtyAction = inputMap.getAction(actionName)
	if !action:
		return 0.0
		
	return action.getActionState(device).raw_strength

## Returns the value of the InputtyProperty specified.[br]
## [br]For Enum properties, a dictionary will be returned
## with [code]enumIndex[/code] and [code]enumValue[/code] properties.
func get_property(propertyName:StringName)->Variant:
	var property:InputtyProperty = inputMap.getProperty(propertyName)
	if property==null:
		return null
	
	if property is InputtyPropertyEnum:
		#return [property.valueIndex, property.values[property.valueIndex]]
		return {"enumIndex":property.valueIndex, "enumValue":property.values[property.valueIndex]}
	
	return property.value

# keep track of frames
var _idleTick:float = 0.0
var _physicsTick:float = 0.0
func _process(delta):
	if _idleTick<0.0:
		_idleTick+=tickRepeatTime
	_idleTick-=delta
func _physics_process(delta):
	if _physicsTick<0.0:
		_physicsTick+=tickRepeatTime
	_physicsTick-=delta



func _rescaleFromDeadzone(val:float, deadzone:float)->float:
	if absf(val)<deadzone:
		return 0.0
	var sgn:float = signf(val)
	val = absf(val)
	val = inverse_lerp(deadzone,1.0, val)
	val = minf(val,1.0)
	return val*sgn

## Gets an input vector by specifying four actions for the positive
## and negative X and Y axes.[br]
## [br]
## By default, the deadzone is automatically calculated from the average
## of the action deadzones. However, you can override the deadzone to be
## whatever you want (on the range of 0 to 1).
## [br][br][code]device[/code] is used to specify which [enum DeviceIndex] is polled.
func get_vector(negativeActionX:StringName, positiveActionX:StringName, negativeActionY:StringName, positiveActionY:StringName, deadzone:float = -1.0, device:int=-2)->Vector2:
	var action_negX:InputtyAction = inputMap.getAction(negativeActionX)
	if !action_negX:
		print_debug("Missing action: " + negativeActionX)
		return Vector2.ZERO
	var action_posX:InputtyAction = inputMap.getAction(positiveActionX)
	if !action_posX:
		print_debug("Missing action: " + positiveActionX)
		return Vector2.ZERO
	var action_negY:InputtyAction = inputMap.getAction(negativeActionY)
	if !action_negY:
		print_debug("Missing action: " + negativeActionY)
		return Vector2.ZERO
	var action_posY:InputtyAction = inputMap.getAction(positiveActionY)
	if !action_posY:
		print_debug("Missing action: " + positiveActionY)
		return Vector2.ZERO

	var retVar:Vector2 = Vector2.ZERO
	retVar.x-=action_negX.getActionState(device).raw_strength
	retVar.x+=action_posX.getActionState(device).raw_strength
	retVar.y-=action_negY.getActionState(device).raw_strength
	retVar.y+=action_posY.getActionState(device).raw_strength
	
	var meanDeadzone:float = deadzone
	if meanDeadzone<0:
		meanDeadzone = (action_negX.deadzone+action_posX.deadzone+action_negY.deadzone+action_posY.deadzone)*0.25
	
	return retVar.normalized() * _rescaleFromDeadzone(retVar.length(), meanDeadzone)

## Get axis input by specifying two actions, one negative and one positive.
## [br][br][code]device[/code] is used to specify which [enum DeviceIndex] is polled.
func get_axis(negativeAction:StringName, positiveAction:StringName, deadzone:float=-1.0, device:int=-2)->float:
	var action_neg:InputtyAction = inputMap.getAction(negativeAction)
	if !action_neg:
		print_debug("Missing action: " + negativeAction)
		return 0.0
	var action_pos:InputtyAction = inputMap.getAction(positiveAction)
	if !action_pos:
		print_debug("Missing action: " + positiveAction)
		return 0.0
	

	var retVar:float = 0.0
	retVar-=action_neg.getActionState(device).raw_strength
	retVar+=action_pos.getActionState(device).raw_strength
	
	var meanDeadzone:float = deadzone
	if meanDeadzone<0:
		meanDeadzone = (action_neg.deadzone+action_pos.deadzone)*0.5
	
	return _rescaleFromDeadzone(retVar, meanDeadzone)



func _input(event):
	_pollJoys()
	_checkDevice(event)
	_processActionsForEvent(event)
	if _inputRemap && _inputRemap.rebindingActionUI:
		_inputRemap.rebindCheck(event)
func _unhandled_input(event):
	_pollJoys()
	_checkDevice(event)
	_processActionsForEvent(event)
	if _inputRemap && _inputRemap.rebindingActionUI:
		_inputRemap.rebindCheck(event)

func _processActionsForEvent(event:InputEvent)->void:
	for action in inputMap.actions:
		action.processEvent(event)

func _checkDevice(event)->void:
	var changeActiveJoy:bool=false
	if event is InputEventJoypadButton and event.pressed:
		changeActiveJoy = true
	if event is InputEventJoypadMotion and abs(event.axis_value)>0.5:
		changeActiveJoy = true
	if changeActiveJoy:
		activeJoyName = Input.get_joy_name(event.device)
		activeJoy = event.device
		activeDevice=activeJoy
	if event is InputEventKey or event is InputEventMouseButton:
		activeDevice=-1
		activeDeviceName="Keyboard"
	

func _on_joy_connection_changed(device_id, connected):
	_pollJoys()
	if connected:
		#device was connected
		activeJoy = device_id
		activeJoyName = Input.get_joy_name(device_id)
		return
	
	#device was disconnected
	activeJoy=-1
	activeJoyName = ""

var _joyCount:int = 0
var _joys:Array[int] = []
func _pollJoys()->void:
	_joys = Input.get_connected_joypads()
	_joyCount = _joys.size()
	
	_joyIconSets.resize(_joyCount)
	for i in _joyCount:
		_joyIconSets[i] = _pickIconSet(_joys[i], Input.get_joy_name(_joys[i]))


func _pickIconSet(device:int, n:String=""):
	if !Input.is_joy_known(device):
		return null
	
	if _resources.controllerIconSets.size()==0:
		print_debug("NO INPUT ICON SETS LOADED")
		return null
	
	if n=="":
		n = Input.get_joy_name(device)
	
	for icons in _resources.controllerIconSets:
		if icons.nameMatches(n):
			return icons
	return _resources.controllerIconSets[0]

## Returns a Texture2D icon corresponding to the first input of the specified action.[br]
## [br]
## Textures retrieved this way can be inserted into RichText BBCode as[br]
## [code]"[img]"+ inputty.get_action_icon("myAction").resource_path +"[/img]"[/code][br]
## [br]
## In most cases, it is probably simpler to attach a [InputtyPromptTextureRect] script on a TextureRect in your UI.
## [br][br][code]device[/code] is used to specify which [enum DeviceIndex] is polled.
func get_action_icon(actionName:StringName, device:int=-2)->Texture2D:
	
	var action:InputtyAction = inputMap.getAction(actionName)
	if !action:
		return null
	
	if device==-2:
		#icon for recent active device
		device = activeDevice
		
	if device==-1:
		#icon for keyboard
		for input in action.inputs:
			if input is InputEventKey or input is InputEventMouseButton:
				return _keyboardIcons.GetIconForEvent(input)
		return null
	
	#icon for gamepad
	if _joyIconSets.size()>device:
		for input in action.inputs:
			if input is InputEventJoypadButton or input is InputEventJoypadMotion:
				return _joyIconSets[device].GetIconForEvent(input)
	
	return null

## Returns a text prompt corresponding to the first input of the specified action.
## [br][br][code]device[/code] is used to specify which [enum DeviceIndex] is polled.
func get_action_prompt(actionName:StringName, device:int=-2)->String:
	
	var action:InputtyAction = inputMap.getAction(actionName)
	if !action:
		return "?"
	
	if device==-2:
		#icon for recent active device
		device = activeDevice
		
	if device==-1:
		#prompt for keyboard
		for input in action.inputs:
			if input is InputEventKey or input is InputEventMouseButton:
				return _keyboardIcons.GetNameForEvent(input)
		return "?"
	
	#prompt for gamepad
	if _joyIconSets.size()>device:
		for input in action.inputs:
			if input is InputEventJoypadButton or input is InputEventJoypadMotion:
				return _joyIconSets[device].GetNameForEvent(input)
	
	return "?"

func _getEventIcon(event:InputEvent, device:int=-2)->Texture2D:
	if device==-2:
		#icon for recent active device
		device = activeDevice
		if !(event is InputEventJoypadButton or event is InputEventJoypadMotion):
			#event is not for a joy so just use key icons
			device = -1
		
	if device==-1:
		#icon for keyboard
		return _keyboardIcons.GetIconForEvent(event)
	
	#icon for gamepad
	if _joyIconSets.size()<=device:
		return null
	return _joyIconSets[device].GetIconForEvent(event)
	

func _getEventName(event:InputEvent, device:int=-2)->String:
	if device==-2:
		#name for recent active device
		device = activeDevice
		if !(event is InputEventJoypadButton or event is InputEventJoypadMotion):
			#event is not for a joy so just use key name
			device = -1
		
	if device==-1:
		#name for keyboard
		return _keyboardIcons.GetNameForEvent(event)
	
	#name for gamepad
	if _joyIconSets.size()<=device:
		return ""
		
	return _joyIconSets[device].GetNameForEvent(event)
	
func _shortDisplayString(event:InputEvent)->String:
	if event is InputEventMouseButton:
		if event.button_index==1:
			return "LMB"
		elif event.button_index==2:
			return "RMB"
		elif event.button_index==3:
			return "MMB"
	
	if event is InputEventJoypadButton:
		return "B" + str(event.button_index)
		
	if event is InputEventJoypadMotion:
		var retStr:String = "A" + str(event.axis)
		if event.axis_value<0:
			retStr+="-"
		if event.axis_value>0:
			retStr+="+"
		return retStr
		
	return event.as_text()
