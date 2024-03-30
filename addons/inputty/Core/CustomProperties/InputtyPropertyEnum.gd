extends InputtyProperty
class_name InputtyPropertyEnum

@export var valueIndex:int = 0
@export var values:Array[String]

func copyFrom(other:InputtyPropertyEnum):
	name = other.name
	valueIndex = other.valueIndex
	values = []
	for v in other.values:
		values.append(v)
