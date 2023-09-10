extends MovementAbility3D
class_name GrindAbility3D



@export var grind_speed := 10

@export var rails_shapecast : ShapeCast3D
@export var draw_3d : Draw3D
var player : CharacterController3D

var grind_direction : Vector3
var starting_position : Vector3



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

func get_grind_direction(player_direction) -> Vector3:
	
		var rail = rails_shapecast.get_collider(0).get_parent() as Goshape
		var path_date = rail.get_path_data(0)
		var point_count = path_date.point_count
		
		
		var local_pos = rail.to_local(global_position)
		
		var closest_offset = path_date.curve.get_closest_offset(local_pos)
		var closest_sampled = path_date.curve.sample_baked(closest_offset, false)
		var closest_sampled_next = path_date.curve.sample_baked(closest_offset + 0.1 * sign(player_direction.x+0.1))
		
		var closest_up = path_date.get_up(PathUtils.get_closest_point_index(path_date, local_pos))
		var dir : Vector3
		
		starting_position = player.to_global(closest_sampled - local_pos)
		
		
		dir = closest_sampled.direction_to(closest_sampled_next)
		if(dir):
			var new = Basis(dir, closest_up, dir.cross(closest_up)).orthonormalized()
			player.set_froggo_basis(new)
			
		return dir 
		

func apply(velocity : Vector3, speed : float, is_on_floor : bool, direction : Vector3, _delta : float) -> Vector3:
	
	if is_actived():
		grind_direction = get_grind_direction(grind_direction)
		if(grind_direction):
			velocity = grind_direction * grind_speed
	return velocity


func _on_actived():
	if(starting_position): 
		player.global_position = starting_position
		player.global_translate(Vector3(0, 1, 0))
		grind_direction = get_grind_direction(-player._direction)

func _on_deactived():
	grind_direction = Vector3.ZERO
	starting_position = Vector3.ZERO
