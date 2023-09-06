extends MovementAbility3D
class_name GrindAbility3D


signal grind_started

@export var grind_speed := 10

@export var rails_shapecast : ShapeCast3D
@export var draw_3d : Draw3D
var player : CharacterController3D

var started : bool

func _ready():
	player = get_parent()
	

func array_transform(arr : Array, transformation : Transform3D) -> Array:
	var new : Array = []
	for p in arr:
		new.append(transformation * p)
	return new
	
func array_translate(arr : Array, translation : Vector3) -> Array:
	var new : Array
	for p in arr:
		new.append(p + translation)
	return new

## Change vertical velocity of [CharacterController3D]
func apply(velocity : Vector3, speed : float, is_on_floor : bool, direction : Vector3, _delta : float) -> Vector3:
	
	if is_actived() and rails_shapecast.is_colliding():
		
		var rail = rails_shapecast.get_collider(0).get_parent() as Goshape
		var path_date = rail.get_path_data(0)
		
		var local_pos = rail.to_local(global_position)
		var local_points = array_transform(path_date.curve.get_baked_points(), transform)
		local_points = array_translate(local_points, -local_pos)
		var dir : Vector3
		
		var closest_offset = path_date.curve.get_closest_offset(local_pos)
		var closest_sampled = path_date.curve.sample_baked_with_rotation(closest_offset, false, true) as Transform3D
		var closest_sampled_next = path_date.curve.sample_baked(closest_offset + 0.1)
		#var up = path_date.curve.sample_baked_up_vector(closest_offset, true)
		
		if(!started):
			print(closest_sampled)
			player.global_position = player.to_global(closest_sampled.origin - local_pos)
			player.global_translate(Vector3(0, 1, 0))
			player.global_transform.basis = closest_sampled.basis
			#player.up_direction = up
			started = true
			return velocity
		
		dir = closest_sampled.origin.direction_to(closest_sampled_next)
		draw_3d.draw_line(local_points, Color.RED)
		draw_3d.draw_line([closest_sampled, closest_sampled_next], Color.GREEN)
		draw_3d.draw_line([Vector3.ZERO, dir], Color.BLUE)
		draw_3d.draw_line([Vector3.ZERO, velocity], Color.GREEN)
		velocity = dir * grind_speed
	else:
		started = false
	return velocity
