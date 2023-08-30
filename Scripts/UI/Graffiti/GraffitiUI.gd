extends Control
class_name GraffitiUI

@export var Size : String = "L"
var graffiti_id : String = ""

@onready var Line = $Cursor/Line2D as Line2D
@onready var Center = $Cursor as Control
var PointsArray : Array


func _ready():
	set_process(false)
	PointsArray = get_children()
	for point in PointsArray:
		point.connect("mouse_entered", select_point.bind(point))
		point.connect("mouse_exited", deselect_point.bind(point))
		
		
	GameEvents.connect("graffiti_initiated", start_tracing)
	GameEvents.connect("graffiti_ended", end_tracing)

func _process(delta):

	Line.set_point_position(Line.get_point_count()-1, Line.get_local_mouse_position())

func start_tracing(_size):
	if _size != Size:
		return 
	set_process(true)
	show()
	graffiti_id = ""
	Line.clear_points()
	Line.add_point(Vector2.ZERO)
	Line.add_point(Vector2.ZERO)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func end_tracing(Size, id):
	set_process(false)
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func select_point(point : Control):
	if(point.name == "Cursor"):
		if(graffiti_id.length() >= PointsArray.size()-1):
			Line.add_point(Vector2.ZERO, Line.get_point_count()-1)
			#set_process(false)
			GameEvents.graffiti_ended.emit(Size, graffiti_id)
		return
	if(point.name not in graffiti_id):
		graffiti_id += point.name
		var new_pos = point.get_global_rect().get_center() - Center.get_global_rect().get_center()
		Line.add_point(new_pos*0.95, Line.get_point_count()-1)

func deselect_point(point : Control):
	pass
