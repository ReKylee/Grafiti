extends MovementAbility3D
class_name GrindAbility3D



@export var grind_speed := 10

@export var rails_shapecast : ShapeCast3D
@export var draw_3d : Draw3D
var player : CharacterController3D

var last_dir : Vector3

var started : bool

func _ready():
	player = get_parent() as CharacterController3D
	

func array_transform(arr : Array, transformation : Transform3D) -> Array:
	var new : Array = []
	for p in arr:
		new.append(transformation * p)
	return new
	
func array_translate(arr : Array, translation : Vector3) -> Array:
	var new : Array = []
	for p in arr:
		new.append(p + translation)
	return new

func align_up(node_basis, normal):
	var result = Basis()
	var scale = node_basis.get_scale() # Only if your node might have a scale other than (1,1,1)

	result.x = normal.cross(node_basis.z)
	result.y = normal
	result.z = node_basis.x.cross(normal)

	result = result.orthonormalized()
	result.x *= scale.x #
	result.y *= scale.y #
	result.z *= scale.z #

	return result

func get_grind_direction() -> Vector3:
	
		var rail = rails_shapecast.get_collider(0).get_parent() as Goshape
		var path_date = rail.get_path_data(0)
		
		var local_pos = rail.to_local(global_position)
		var local_points = array_transform(path_date.curve.get_baked_points(), transform)
		local_points = array_translate(local_points, -local_pos)
		
		var closest_offset = path_date.curve.get_closest_offset(local_pos)
		var closest_sampled = path_date.curve.sample_baked_with_rotation(closest_offset, false, true) as Transform3D
		var closest_up = path_date.get_up(PathUtils.get_closest_point_index(path_date,closest_sampled.origin))
		var closest_sampled_next = path_date.curve.sample_baked(closest_offset + 0.1 * sign(last_dir.x))
		var dir : Vector3
		
		if(!started):
			started = true
			player.global_position = player.to_global(closest_sampled.origin - local_pos)
			player.global_translate(Vector3(0, 1, 0))
		
		#align player to direction
		player.set_froggo_basis(align_up(player.get_froggo_basis(), closest_up))
		
		dir = closest_sampled.origin.direction_to(closest_sampled_next)
		return dir 
		

func apply(velocity : Vector3, speed : float, is_on_floor : bool, direction : Vector3, _delta : float) -> Vector3:
	if(direction and not started):
		last_dir = -direction
	if is_actived():
		#player._direction = last_dir
		velocity = get_grind_direction() * grind_speed
	else:
		started = false
	return velocity
