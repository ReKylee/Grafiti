extends Resource
class_name InputtyDisplaySet

@export var name:String = "Input icon set"

@export var imageSet:Array[Texture]
@export var axisImageSet:Array[Texture]

@export var buttonNames:Array[String] = ["A", "B", "X", "Y", "Back", "Home", "Menu", "L Stick", "R Stick", "L1", "R1", "Up", "Down", "Left", "Right", "Share", "Paddle 1", "Paddle 2", "Paddle 3", "Paddle 4", "Touchpad"]
@export var axisNames:Array[String] = ["L Left", "L Right", "L Up", "L Down", "R Left", "R Right", "R Up", "R Down", "", "L2", "", "R2"]

@export var nameMustContain:Array[String]
@export var nameMustNotContain:Array[String]
@export var nameContainsAny:Array[String]

func nameMatches(n:String):
	var theName:String = n.to_lower()
	
	
	if nameMustContain.size()>0:
		for s in nameMustContain:
			if !theName.contains(s):
				return false
	if nameMustNotContain.size()>0:
		for s in nameMustNotContain:
			if theName.contains(s):
				return false
				
	for s in nameContainsAny:
		if theName.contains(s):
			return true
	
	return false
	
func GetIconForEvent(e:InputEvent):
	var buttonIndex := -1
	var axisIndex := -1
	if e is InputEventJoypadButton:
		buttonIndex = e.button_index
	if e is InputEventJoypadMotion:
		axisIndex = e.axis*2
		if e.axis_value>0:
			axisIndex+=1
	
	if buttonIndex!=-1:
		if buttonIndex<imageSet.size():
			return imageSet[buttonIndex]
	if axisIndex!=-1:
		if axisIndex<axisImageSet.size():
			return axisImageSet[axisIndex]
	
	return null
	
func GetNameForEvent(e:InputEvent):
	var buttonIndex := -1
	var axisIndex := -1
	if e is InputEventJoypadButton:
		buttonIndex = e.button_index
	if e is InputEventJoypadMotion:
		axisIndex = e.axis*2
		if e.axis_value>0:
			axisIndex+=1
	
	
	if buttonIndex!=-1:
		if buttonIndex<buttonNames.size() && buttonNames[buttonIndex]!="":
			return buttonNames[buttonIndex]
	if axisIndex!=-1:
		if axisIndex<axisNames.size() && axisNames[axisIndex]!="":
			return axisNames[axisIndex]
	return Inputty._shortDisplayString(e)
