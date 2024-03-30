extends InputtyProperty
class_name InputtyPropertyFloat

@export var value:float = 1.0
@export var minVal:float = 0.0
@export var maxVal:float = 2.0

func copyFrom(other:InputtyPropertyFloat):
	name = other.name
	value = other.value
	minVal = other.minVal
	maxVal = other.maxVal
