extends RichTextLabel

@export var actionsToMonitor:Array[String]

func _process(_delta):
	text = ""
	
	#text += "Vanilla Input:"
	#for a in actionsToMonitor:
		#text += "\n" + a + ": "
		#text += str(Input.get_action_strength(a))
	#text += "\n"
	
	text += getInputDataForSlot(-2)
	text += getInputDataForSlot(-1)
	var joys:Array[int] = Input.get_connected_joypads()
	for i in joys:
		text += getInputDataForSlot(i)
	
func getInputDataForSlot(i:int):
	var ret:String = "\nDevice " + str(i) + " : "
	if i==-2:
		ret += "Compound (all/any) device"
	elif i==-1:
		ret += "Keyboard/Mouse"
	else:
		ret += Input.get_joy_name(i)
	
	for a in actionsToMonitor:
		ret += "\n" + a
		var icon:Texture2D = Inputty.get_action_icon(a, i)
		if icon:
			ret+= " ([img=30]" + icon.resource_path + "[/img])"
		else:
			ret+= " (" + Inputty.get_action_prompt(a, i) +")"
		ret += ": " + str(Inputty.get_action_strength(a, i))
		
	ret += "\n"
	
	return ret
