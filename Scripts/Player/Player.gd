extends CharacterController3D

@export var camera_springarm : SpringArm3D
@export var rail_basis : Node3D
@onready var graffiti_area = $InteractionArea as Area3D
@onready var draw_3d = $Draw3D as Draw3D
@onready var froggo: FrogAnimationController = $Froggo

var has_jumped : bool

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$CameraRemote.remote_path = camera_springarm.get_path()
	setup()
	_direction_base_node = camera_springarm
	GameEvents.graffiti_ended.connect(graffiti_ended)
	rail_basis.top_level = true

func get_local_forward() -> Vector3:
	return -basis.z
	
func get_global_forward() -> Vector3:
	return -global_basis.z



func _physics_process(delta):
	draw_3d.clear()
	var input_axis = Input.get_vector("move_backward", "move_forward", "move_left", "move_right")
	var input_jump = Input.is_action_just_pressed("move_jump")
	var input_sprint = Input.is_action_pressed("move_sprint")
	
	if not grind_ability.is_actived():
		froggo.direction = _direction
		froggo._velocity = velocity
		
		if _direction:
			global_rotation.y = lerp_angle(global_rotation.y, Vector3.FORWARD.signed_angle_to(velocity, Vector3.UP), 12 * delta)
	
	

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



