extends MovementAbility3D
class_name GrindAbility3D

## Simple ability that adds a vertical impulse when actived (Jump)

## Jump/Impulse height
@export var grind_speed := 10

@export var rails_shapecast : ShapeCast3D


## Change vertical velocity of [CharacterController3D]
func apply(velocity : Vector3, speed : float, is_on_floor : bool, direction : Vector3, _delta : float) -> Vector3:
	if is_actived():
		pass
	return velocity
