extends MovementAbility3D
class_name GrindAbility3D



@export var grind_speed := 2

@export var rails_shapecast : ShapeCast3D
@export var draw_3d : Draw3D
var player : CharacterController3D

var current_rail : Goshape
var current_path_follow : PathFollow3D
var current_path_data : PathData
var grind_direction : float

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
	
	if velocity.length() > 1: 
		grind_speed = clampf(velocity.length() *1.25, 12, 100)
	
	
	if is_actived() and not velocity.y > 1:
		current_path_follow.progress += _delta * grind_speed * grind_direction
		return Vector3.ZERO
	
	
	return velocity
	
func get_nearest_offset() -> float:
	var player_pos = current_rail.to_local(player.global_position) as Vector3
	var nearest_offset = current_rail.curve.get_closest_offset(player_pos)
	return nearest_offset

func get_nearest_point() ->Transform3D:
	var nearest_offset = get_nearest_offset()
	#Global Coords
	var nearest_point = current_rail.curve.sample_baked_with_rotation(nearest_offset, false, true)
	return nearest_point.translated(current_rail.global_position)
	

func set_initial_progress() :
	var nearest_offset = get_nearest_offset()
	var nearest_point = get_nearest_point()
	var facing_dot = nearest_point.basis.z.dot(player.get_global_forward())
	grind_direction = -1 if facing_dot > 0 else 1
	current_path_follow.progress = nearest_offset + grind_direction
	
func _on_actived() -> void:
	current_rail = rails_shapecast.get_collider(0).get_parent()
	current_path_follow = current_rail.path_follow as PathFollow3D
	current_path_data = current_rail.get_path_data(0)
	set_initial_progress()
	current_rail.set_remote_path(player.get_path())
	current_rail.set_remote_forward(180 * (grind_direction + 1)/2)
	
func _on_deactived() -> void:
	current_rail.set_remote_path("")
	

