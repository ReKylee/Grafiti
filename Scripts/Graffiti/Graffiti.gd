@tool
extends Area3D
class_name Graffiti

var Sizes : Dictionary = {
	"M": Vector3(1.5, 3, 3),
	"L": Vector3(1.5, 4.5, 5.5),
	"XL": Vector3(1.5, 6, 12)}

@onready var collision_shape = $CollisionShape3D as CollisionShape3D
@onready var area_pcam = $PhantomCamera3D as PhantomCamera3D
@onready var graffiti_timer = $GraffitiTimer as Timer
@onready var player_position = $PlayerPosition as Marker3D
@onready var graffiti_sprite = $GraffitiSprite as Sprite3D

@export var Size : String = "L" : 
	set(value):
		if value != Size:
			Size = value.to_upper()
			if value.to_upper() in Sizes:
				$CollisionShape3D.shape.size = Sizes[Size.to_upper()]
		


func _ready():
	GameEvents.connect("graffiti_ended", end_graffiti)
	graffiti_timer.connect("timeout", timeout)


func start_graffiti(player):
	graffiti_timer.start()
	area_pcam.set_priority(20)
	GameEvents.graffiti_initiated.emit(Size)

func end_graffiti(Size, id):
	graffiti_timer.stop()
	area_pcam.set_priority(0)
	
	var graf_path = GameEvents.get_graf_path_by_id(id)
	
	if ResourceLoader.exists(graf_path):
		var art = load(graf_path)
		graffiti_sprite.texture = art.art
	else:
		graffiti_sprite.texture = null
		
	
func timeout():
	GameEvents.graffiti_ended.emit(Size, "")
