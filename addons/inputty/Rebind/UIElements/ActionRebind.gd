extends Control
class_name ActionRebind

@export var actionName :StringName= ""
@export var actionDisplay := ""

@export var actionInputPrefab:PackedScene

var inputUIs:Array[Control]=[]

var customAction:InputtyAction

func _ready():
	$ActionLabel.text = actionDisplay
	
	for i in customAction.inputs.size():
		addInput(i)
	
	resizeControl()

func resizeControl():
	custom_minimum_size.y = max(50,50*customAction.inputs.size())
	update_minimum_size()

var rebindIndex = -1;
func addOrRemove(i:int):
	if i==customAction.inputs.size()-1:
		addNewInput()
	else:
		removeInput(i)
	
	resizeControl()

func removeInput(i:int):
	customAction.inputs.remove_at(i)
	inputUIs[inputUIs.size()-1].queue_free()
	inputUIs.resize(inputUIs.size()-1)
	refreshAllInputDisplays()

func addNewInput():
	customAction.inputs.append(null)
	addInput(customAction.inputs.size()-1)
	refreshAllInputDisplays()

func addInput(i:int):
	var newInputUI:Control = actionInputPrefab.instantiate()
	add_child(newInputUI)
	newInputUI.get_child(0).connect("pressed",beginRebindInput.bind(i))
	newInputUI.get_child(1).connect("pressed",addOrRemove.bind(i))
	inputUIs.append(newInputUI)
	
	ApplyTextAndIcon(i)

func beginRebindInput(i:int):
	rebindIndex = i
	Inputty._inputRemap.cancelRebind()
	Inputty._inputRemap.beginRebind(self)
	inputUIs[i].get_child(0).icon = null
	inputUIs[i].get_child(0).text = "Awaiting input..."
	inputUIs[i].get_child(0).release_focus()

func Rebind(new:InputEvent)->void:
	customAction.inputs[rebindIndex] = new
	cancelRebind(true)

func cancelRebind(reclaimFocus:bool=false):
	if rebindIndex==-1:
		return
	ApplyTextAndIcon(rebindIndex)
	if reclaimFocus:
		await get_tree().create_timer(0.06).timeout
		inputUIs[rebindIndex].get_child(0).grab_focus()
	rebindIndex = -1

func ApplyTextAndIcon(i:int):
	inputUIs[i].position.y = 50*i
	
	if customAction.inputs[i] == null:
		#no input set up here
		inputUIs[i].get_child(0).icon = null
		inputUIs[i].get_child(0).text = ""
		return
	
	var joyInput = (customAction.inputs[i] is InputEventJoypadButton or customAction.inputs[i] is InputEventJoypadMotion)
	
	var inputName:String = Inputty._getEventName(customAction.inputs[i])
	
	
	inputUIs[i].get_child(0).text = inputName
	
	
	if joyInput:
		var theIcon = Inputty._getEventIcon(customAction.inputs[i], Inputty.activeJoy)
		if theIcon!=null:
			inputUIs[i].get_child(0).text = ""
		else:
			#theIcon = Inputty.defaultControllerIcon
			theIcon = Inputty._resources.defaultControllerIcon
		inputUIs[i].get_child(0).icon = theIcon
	else:
		var theIcon = Inputty._getEventIcon(customAction.inputs[i], -1)
		if theIcon!=null:
			inputUIs[i].get_child(0).text = ""
		inputUIs[i].get_child(0).icon = theIcon
	
	
	if i<customAction.inputs.size()-1:
		inputUIs[i].get_child(1).text = "X"
		inputUIs[i].get_child(1).add_theme_color_override("font_color",Color.RED)
	else:
		inputUIs[i].get_child(1).text = "+"
		inputUIs[i].get_child(1).add_theme_color_override("font_color",Color.GREEN)

func refreshAllInputDisplays():
	for i in customAction.inputs.size():
		ApplyTextAndIcon(i)


