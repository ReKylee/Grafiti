extends Node

signal graffiti_initiated(size)
signal graffiti_ended(size, id)

var GrafsFolder = "res://Resources/Graffitis/"

func get_graf_path_by_id(id):
	
	return GrafsFolder + str(id) + ".tres"
