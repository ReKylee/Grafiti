extends Node3D
class_name FrogAnimationController

@onready var anim_tree = $AnimationTree as AnimationTree

var velocity : Vector3
var direction : Vector3 
var on_ground : bool
var jumped : bool


func get_rot(delta):
	var d = .7
	var circumference = d * PI
	var rot = (velocity.length() / circumference) * 2 * PI * delta
	return rot


func _physics_process(delta):
	
	if direction:
		global_rotation.y = lerp_angle(global_rotation.y, Vector3.RIGHT.signed_angle_to(velocity, Vector3.UP), 12 * delta)

	anim_tree["parameters/IdleRunBlend/blend_amount"] = lerp(anim_tree["parameters/IdleRunBlend/blend_amount"], direction.normalized().length(), 7 * delta )
	
	if jumped:
		rotation.z -= get_rot(delta)

func _on_player_jumped():
	var tween = create_tween()
	tween.tween_property(anim_tree, "parameters/ToJumpBlend/blend_amount", 1, .1).set_ease(Tween.EASE_IN)
	jumped = true

func _on_player_landed():
	var tween = create_tween()
	tween.tween_property(anim_tree, "parameters/ToJumpBlend/blend_amount", 0, .1).set_ease(Tween.EASE_OUT)
	rotation.z = 0.0
	jumped = false
