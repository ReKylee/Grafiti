extends MovementAbility3D
class_name GrindAbility3D



@export var grind_speed := 2

@export var rails_shapecast : ShapeCast3D
@export var draw_3d : Draw3D
var player : CharacterController3D

var current_rail : Goshape
var current_path_follow : PathFollow3D
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
	draw_3d.draw_line([Vector3.ZERO, player.get_forward_direction()])
	if is_actived():
		
		
		current_path_follow.progress += _delta * grind_speed * grind_direction
		return Vector3.ZERO
	
	return velocity


func set_initial_progress() -> Transform3D:
	var player_pos = current_rail.to_local(player.global_position) as Vector3
	var nearest_offset = current_rail.curve.get_closest_offset(player_pos)
	var nearest_point = current_rail.curve.sample_baked_with_rotation(nearest_offset)
	grind_direction = -nearest_point.basis.z.dot(player.get_forward_direction()) 
	current_path_follow.progress = nearest_offset + grind_direction
	return nearest_point
	
func _on_actived() -> void:
	current_rail = rails_shapecast.get_collider(0).get_parent()
	current_path_follow = current_rail.path_follow as PathFollow3D
	var nearest = set_initial_progress() as Transform3D
	current_path_follow.correct_posture(current_rail.follow_remote_transform.global_transform, PathFollow3D.ROTATION_ORIENTED)
	current_rail.set_remote_path(player.get_path())
	
	
	
	
func _on_deactived() -> void:
	current_rail.set_remote_path("")



