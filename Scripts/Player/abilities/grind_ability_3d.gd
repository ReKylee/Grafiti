extends MovementAbility3D
class_name GrindAbility3D



@export var grind_speed := 10

@export var rails_shapecast : ShapeCast3D
@export var draw_3d : Draw3D
var player : CharacterController3D

var grind_direction : int
var starting_position : Vector3
var current_rail : Goshape
var current_path_data : PathData
var current_point_ind : int

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
		#player's global position in the rail's local space
		var local_pos = current_rail.to_local(global_position)
		var path_count = current_path_data.get_point_count()
		#keep track of the current closest point index
		
		var closest_corner_ind = PathUtils.get_closest_point_index(current_path_data, local_pos)
		#get the closest point offset
		var closest_offset = current_path_data.curve.get_closest_offset(local_pos)
		#get closest point with rotaton
		var closest_point = current_path_data.curve.sample_baked_with_rotation(closest_offset, false) as Transform3D
		#point transform
		closest_point.origin = current_rail.to_global(closest_point.origin)
		#initialize starting_position
		starting_position = closest_point.origin
		
		#check if the player has reached the closest corner
		#if(corner)
		
		#DEBUG
		player.rail_basis.global_transform = closest_point
		
		#if(curr):
		#	velocity = curr * grind_speed
	return velocity


func _on_actived():
	current_rail = rails_shapecast.get_collider(0).get_parent() as Goshape
	current_path_data = current_rail.get_path_data(0)
	var local_pos = current_rail.to_local(global_position)
	if(starting_position): 
		current_point_ind = PathUtils.get_closest_point_index(current_path_data, local_pos)
		player.global_position = starting_position
		grind_direction = sign(player.get_forward_direction())
		player.global_translate(Vector3(0, 1, 0))

func _on_deactived():
	current_rail = null
	current_path_data = null
	current_point_int = 0
	grind_direction = 0
	starting_position = Vector3.ZERO
