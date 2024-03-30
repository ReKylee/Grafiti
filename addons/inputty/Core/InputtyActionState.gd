extends Resource
class_name InputtyActionState

#which device is this state monitoring (-2=All, -1=Keys+Mouse, 0+=joys)
var device:int = -2

#is the action pressed when asked
var pressed:bool = false

#the strength of the action when asked
var strength:float = 0.0
#the raw strength (no deadzone) of the action when asked
var raw_strength:float = 0.0

#the frame the action was last just pressed
var just_pressed_idle:int = -99
#the physics tick the action was last just pressed
var just_pressed_physics:int = -99
#the frame the action was last just released
var just_released_idle:int = -99
#the physics tick the action was last just released
var just_released_physics:int = -99

#the time that the action began being pressed (used for repeating input)
var pressed_time:int = -1


var action:InputtyAction


var joyAxes:Array[int] = []
var joyAxesStrengths:Array[float] = []
func updateAxis(axis:int, axis_str:float):
	var i = joyAxes.find(axis)
	if i==-1:
		joyAxes.append(axis)
		joyAxesStrengths.append(axis_str)
		return
	joyAxesStrengths[i] = axis_str
	
var joyButtons:Array[int] = []
var joyButtonsPressed:Array[bool] = []
var mouseButtons:Array[int] = []
var mouseButtonsPressed:Array[bool] = []
var keys:Array[int] = []
var keysPressed:Array[bool] = []
var keysPhys:Array[int] = []
var keysPhysPressed:Array[bool] = []
var keysUni:Array[int] = []
var keysUniPressed:Array[bool] = []
func updateButton(buttons:Array[int], presseds:Array[bool], button:int, on:bool):
	var i = buttons.find(button)
	if i==-1:
		buttons.append(button)
		presseds.append(on)
		return
	presseds[i]=on
	updateState()


func prep():
	
	joyAxes = []
	joyAxesStrengths = []
	joyButtons = []
	joyButtonsPressed = []
	mouseButtons = []
	mouseButtonsPressed = []
	keys = []
	keysPressed = []
	keysPhys = []
	keysPhysPressed = []
	keysUni = []
	keysUniPressed = []


func joyMotion(event:InputEventJoypadMotion, input:InputEventJoypadMotion)->void:
	#a joy motion event effects this state
	var axisVal:float = Input.get_joy_axis(device, event.axis)
	if signf(axisVal)!=signf(input.axis_value):# && absf(axisVal)!=0.0:
		axisVal = 0.0
	axisVal = absf(axisVal)
	
	updateAxis(event.axis, axisVal)
	updateState()

func updateState():
	
	var greatestStr:float = 0.0
	for v in joyAxesStrengths:
		greatestStr = maxf(greatestStr, v)
	if greatestStr<1.0:
		if joyButtonsPressed.find(true)!=-1:
			greatestStr=1.0
		if mouseButtonsPressed.find(true)!=-1:
			greatestStr=1.0
		if keysPressed.find(true)!=-1:
			greatestStr=1.0
		if keysPhysPressed.find(true)!=-1:
			greatestStr=1.0
		if keysUniPressed.find(true)!=-1:
			greatestStr=1.0
	
	updateJusts(greatestStr>=action.deadzone)
	pressed = greatestStr>=action.deadzone
	raw_strength = greatestStr
	strength = Inputty._rescaleFromDeadzone(greatestStr, action.deadzone)
	

func setStrengthsFromPressed()->void:
	if pressed:
		strength = 1.0
		raw_strength = 1.0
	else:
		strength = 0.0
		raw_strength = 0.0

func updateJusts(isPressedNow:bool)->void:
	if !pressed && isPressedNow:
		#just pressed
		just_pressed_idle = Engine.get_frames_drawn()
		just_pressed_physics = Engine.get_physics_frames()
		pressed_time = Time.get_ticks_msec()
	
	if pressed && !isPressedNow:
		#just released
		just_released_idle = Engine.get_frames_drawn()
		just_released_physics = Engine.get_physics_frames()
		pressed_time = -1
