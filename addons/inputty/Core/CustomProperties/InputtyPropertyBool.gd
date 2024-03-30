extends InputtyProperty
class_name InputtyPropertyBool


@export var value:bool = false
@export var trueDisplay:String = "On"
@export var falseDisplay:String = "Off"

func copyFrom(other:InputtyPropertyBool):
	name = other.name
	value = other.value
	trueDisplay = other.trueDisplay
	falseDisplay = other.falseDisplay
