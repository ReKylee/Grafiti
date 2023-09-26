extends MovementAbility3D
class_name GrindAbility3D



@export var grind_speed := 10

@export var rails_shapecast : ShapeCast3D
@export var draw_3d : Draw3D
var player : CharacterController3D

var grind_direction : int
var starting_transform : Transform3D
var current_rail : Goshape
var current_path_data : PathData

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


func apply(velocity : Vector3, speed : float, is_on_floor : bool, direction : Vector3, _delta : float) -> Vector3:
	draw_3d.draw_line([Vector3.ZERO, player.get_forward_direction()], Color.RED)
	
	if is_actived() and rails_shapecast.is_colliding():
		print(current_rail.path_follow)
		
		current_rail.set_remote_path(player.get_path())
		current_rail.set_follow_progress(current_rail.get_follow_progress()+1 * _delta)
		
		#player's global position in the rail's local space
		var local_pos = current_rail.to_local(global_position)
		#keep track of the current closest point index
		current_path_data.curve.get_baked_points()
		var closest_corner = PathUtils.get_closest_point(current_path_data, local_pos)
		#get the closest point offset
		var closest_offset = current_path_data.curve.get_closest_offset(local_pos)
		#get closest point with rotation
		var closest_point = current_path_data.curve.sample_baked_with_rotation(closest_offset, false, true) as Transform3D
		#point transform
		closest_point.origin = current_rail.to_global(closest_point.origin)
		closest_corner = current_rail.to_global(closest_corner)
		
		#check if the player has reached the closest corner
		if(closest_point.origin.is_equal_approx(closest_corner)):
			print("corner")
		
		#DEBUG
		#player.rail_basis.global_transform = closest_point
		
		#player._direction = closest_point.basis.z * grind_direction
		#velocity = closest_point.basis.z * grind_direction * grind_speed
		
	return velocity


func _on_actived():
	current_rail = rails_shapecast.get_collider(0).get_parent() as Goshape
	current_path_data = current_rail.get_path_data(0)
	grind_direction = sign(player.get_forward_direction().x)
	#player's global position in the rail's local space
	var local_pos = current_rail.to_local(global_position)
	#get the closest point offset
	var closest_offset = current_path_data.curve.get_closest_offset(local_pos)
	#get closest point with rotation
	var closest_point = current_path_data.curve.sample_baked_with_rotation(closest_offset, false, true) as Transform3D
	#point transform
	closest_point.origin = current_rail.to_global(closest_point.origin)
	player.global_transform.origin = closest_point.origin
	player.global_translate(Vector3(0, 1, 0))

func _on_deactived():
	current_rail = null
	current_path_data = null
	grind_direction = 0
	player.global_transform.basis = Transform3D.IDENTITY.basis
	
