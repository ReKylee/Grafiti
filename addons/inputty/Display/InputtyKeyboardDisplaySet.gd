extends Resource
class_name InputtyKeyboardDisplaySet

@export var name:String = "Input icon set"
@export var keyboardDisplays:Array[InputtyDisplayItem]
@export var mouseDisplays:Array[InputtyDisplayItem]

func GetIconForEvent(e:InputEvent):
	var keyIndex := -1
	var mouseIndex := -1
	if e is InputEventKey:
		keyIndex = e.keycode
		if keyIndex == 0:
			keyIndex = e.physical_keycode
		if keyIndex == 0:
			#keyIndex = e.unicode
			#keyIndex = OS.find_keycode_from_string(char(e.unicode))
			keyIndex = OS.find_keycode_from_string(PackedByteArray([e.unicode]).get_string_from_utf8())
	if e is InputEventMouse:
		mouseIndex = e.button_index
		
	
	if keyIndex!=-1:
		for disp in keyboardDisplays:
			if disp.enumIndex == keyIndex:
				return disp.texture
	if mouseIndex!=-1:
		for disp in mouseDisplays:
			if disp.enumIndex == mouseIndex:
				return disp.texture
	
	return null
	
func GetNameForEvent(e:InputEvent):
	var keyIndex := -1
	var mouseIndex := -1
	if e is InputEventKey:
		keyIndex = e.keycode
	if e is InputEventMouse:
		mouseIndex = e.button_index
		
	
	if keyIndex!=-1:
		for disp in keyboardDisplays:
			if disp.enumIndex == keyIndex:
				return disp.name
	if mouseIndex!=-1:
		for disp in mouseDisplays:
			if disp.enumIndex == mouseIndex:
				return disp.name
	
	return Inputty._shortDisplayString(e)
