extends Node3D
class_name FrogAnimationController

@onready var anim_tree: AnimationTree = $AnimationTree 

var direction : Vector3 
var _velocity : Vector3 
var jumped : bool
var grinding : bool
func get_rot(delta):
	var d = .7
	var circumference = d * PI
	var rot = (_velocity.length() / circumference) * 2 * PI * delta
	return rot


func _physics_process(delta):
	if jumped:
		rotation.z -= get_rot(delta)
	if grinding:
		direction = Vector3.ZERO
	anim_tree["parameters/IdleRunBlend/blend_amount"] = lerp(anim_tree["parameters/IdleRunBlend/blend_amount"], direction.length(), 7 * delta )
	
func _on_player_jumped():
	var tween = create_tween()
	tween.tween_property(anim_tree, "parameters/SkateRunJumpBlend/blend_amount", 1, .1).set_ease(Tween.EASE_IN)
	jumped = true

func _on_player_landed():
	var tween = create_tween()
	tween.tween_property(anim_tree, "parameters/SkateRunJumpBlend/blend_amount", 0, .1).set_ease(Tween.EASE_OUT)
	jumped = false
	rotation.z = 0


func _on_grind_actived():
	var tween = create_tween()
	tween.tween_property(anim_tree, "parameters/SkateRunJumpBlend/blend_amount", -1, .1).set_ease(Tween.EASE_IN)
	grinding = true
	jumped = false


func _on_grind_deactived():
	grinding = false
	


