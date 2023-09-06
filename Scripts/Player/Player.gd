extends CharacterController3D


@onready var camera_marker = $CameraAnchor/CameraPos as Marker3D
@onready var camera_springarm = $CameraAnchor as SpringArm3D
@onready var graffiti_area = $InteractionArea as Area3D
@onready var froggo = $Froggo as FrogAnimationController
@onready var draw_3d = $Draw3D as Draw3D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	setup()
	_direction_base_node = camera_springarm
	GameEvents.graffiti_ended.connect(graffiti_ended)

func set_froggo_basis(b : Basis):
	froggo.global_transform.basis = b
func get_froggo_basis():
	return froggo.global_transform.basis
func _physics_process(delta):
	draw_3d.clear()
	var input_axis = Input.get_vector("move_backward", "move_forward", "move_left", "move_right")
	var input_jump = Input.is_action_just_pressed("move_jump")
	var input_sprint = Input.is_action_pressed("move_sprint")
	froggo.velocity = transform.basis * velocity
	froggo.direction = _direction
	draw_3d.draw_line([Vector3.ZERO, froggo.velocity]) 
	move(delta, input_axis, input_jump, input_sprint)
	check_for_graffiti()

func check_for_graffiti():
	var areas : Array[Area3D] = graffiti_area.get_overlapping_areas()
	#most likely isn't actually the closest but whatever
	var closest_area = areas[0] as Graffiti if not areas.is_empty() else null
	if Input.is_action_pressed("graffiti") and (closest_area is Graffiti):
		closest_area.start_graffiti(self)
		global_position = lerp(global_position, closest_area.player_position.global_position, .2) 

func graffiti_ended(size, id):
	pass

