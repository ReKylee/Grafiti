extends CharacterBody3D
class_name CharacterController3D

## Emitted when the character controller performs a step, called at the end of 
## the move() 
## function when a move accumulator for a step has ended.
signal stepped

## Emitted when touching the ground after being airborne, called in the 
## move() function.
signal landed

## Emitted when a jump is processed, is called when [JumpAbility3D] is active.
signal jumped

## Emitted when a sprint started, is called when [SprintAbility3D] is active.
signal sprinted

signal grind_start
signal grind_end


@export_group("Movement")

## Controller Gravity Multiplier
## The higher the number, the faster the controller will fall to the ground and 
## your jump will be shorter.
@export var gravity_multiplier := 3.0

## Controller base speed
## Note: this speed is used as a basis for abilities to multiply their 
## respective values, changing it will have consequences on [b]all abilities[/b]
## that use velocity.
@export var speed := 10

## Time for the character to reach full speed
@export var acceleration := 8

## Time for the character to stop walking
@export var deceleration := 10

## Sets control in the air
@export var air_control := 0.3


@export_group("Sprint")

## Speed to be multiplied when active the ability
@export var sprint_speed_multiplier := 1.6


@export_group("Footsteps")

## Maximum counter value to be computed one step
@export var step_lengthen := 0.7

## Value to be added to compute a step, each frame that the character is walking this value 
## is added to a counter
@export var step_interval := 6.0


@export_group("Crouch")

## Collider height when crouch actived
@export var height_in_crouch := 1.0

## Speed multiplier when crouch is actived
@export var crouch_speed_multiplier := 0.7


@export_group("Jump")

## Jump/Impulse height
@export var jump_height := 10

@export_group("Abilities")
## List of movement skills to be used in processing this class.
@export var abilities_path: Array[NodePath]

## List of movement skills to be used in processing this class.
var _abilities: Array[MovementAbility3D]
 
## Result direction of inputs sent to [b]move()[/b].
var _direction := Vector3()

## Current counter used to calculate next step.
var _step_cycle : float = 0

## Maximum value for _step_cycle to compute a step.
var _next_step : float = 0

## Character controller horizontal speed.
var _horizontal_velocity : Vector3

## Base transform node to direct player movement
var _direction_base_node : Node3D

## Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
@onready var gravity: float = (ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_multiplier)

## Collision of character controller.
@onready var collision: CollisionShape3D = get_node(NodePath("PlayerColShape"))

## Above head collision checker, used for crouching and jumping.
@onready var head_check: RayCast3D = get_node(NodePath("Head Check"))

#Used for grinding on rails
@onready var rail_cast: ShapeCast3D = get_node(NodePath("RailsCast"))

## Basic movement ability.
@onready var walk_ability: WalkAbility3D = get_node(NodePath("WalkAbility3D"))

## Ability that adds extra speed when actived.
@onready var sprint_ability: SprintAbility3D = get_node(NodePath("SprintAbility3D"))

## Simple ability that adds a vertical impulse when actived (Jump).
@onready var jump_ability: JumpAbility3D = get_node(NodePath("JumpAbility3D"))

#Ability that sets your velocity according to a path3d
@onready var grind_ability: GrindAbility3D = get_node(NodePath("GrindAbility3D"))

## Stores normal speed
@onready var _normal_speed: int = speed

## True if in the last frame it was on the ground
var _last_is_on_floor := false

## Default controller height, affects collider
var _default_height : float


## Loads all character controller skills and sets necessary variables
func setup():
	_abilities = _load_nodes(abilities_path)
	_default_height = collision.shape.height
	_connect_signals()
	_start_variables()


## Moves the character controller.
## parameters are inputs that are sent to be handled by all abilities.
func move(_delta: float, input_axis := Vector2.ZERO, input_jump := false, input_sprint := false ) -> void:
	var direction = _direction_input(input_axis, _direction_base_node)

	
	_check_landed()
	if not jump_ability.is_actived() and not is_on_floor():
		velocity.y -= gravity * _delta
		grind_ability.set_active(not input_jump and rail_cast.is_colliding())
	
	jump_ability.set_active(can_jump(input_jump))
	 
	sprint_ability.set_active(not grind_ability.is_actived() and input_sprint and is_on_floor() and  input_axis.x >= 0.5)
	walk_ability.set_active(not grind_ability.is_actived())
	var multiplier = 1.0
	for ability in _abilities:
		multiplier *= ability.get_speed_modifier()
	speed = _normal_speed * multiplier
	
	for ability in _abilities:
		velocity = ability.apply(velocity, speed, is_on_floor(), direction, _delta)
	
	move_and_slide()
	_horizontal_velocity = Vector3(velocity.x, 0.0, velocity.z)
	_check_step(_delta)

func can_jump(input_jump) -> bool:
	return (
		input_jump 
		and (is_on_floor() or rail_cast.is_colliding()) 
		and not head_check.is_colliding())

## Returns true if the character controller is sprinting
func is_sprinting() -> bool:
	return sprint_ability.is_actived()

## Returns the speed of character controller
func get_speed() -> float:
	return speed

func _reset_step():
	_next_step = _step_cycle + step_interval

func _load_nodes(nodePaths: Array) -> Array[MovementAbility3D]:
	var nodes : Array[MovementAbility3D]
	for nodePath in nodePaths:
		var node := get_node(nodePath)
		if node != null:
			var ability = node as MovementAbility3D
			nodes.append(ability)
	return nodes


func _connect_signals():
	sprint_ability.actived.connect(_on_sprinted.bind())
	jump_ability.actived.connect(_on_jumped.bind())
	grind_ability.actived.connect(_on_grind_start.bind())
	grind_ability.deactived.connect(_on_grind_end.bind())

func _start_variables():
	walk_ability.acceleration = acceleration
	walk_ability.deceleration = deceleration
	walk_ability.air_control = air_control
	sprint_ability.speed_multiplier = sprint_speed_multiplier
	jump_ability.height = jump_height
	grind_ability.rails_shapecast = rail_cast
	grind_ability.player = self



func _check_landed():
	if is_on_floor() and not _last_is_on_floor:
		emit_signal("landed")
		_reset_step()
	_last_is_on_floor = is_on_floor()
	
	
func _check_step(_delta):
	if _is_step(_horizontal_velocity.length(), is_on_floor(), _delta):
		_step(is_on_floor())


func _direction_input(input : Vector2, aim_node : Node3D) -> Vector3:
	_direction = Vector3()
	var aim = aim_node.get_global_transform().basis
	if input.x >= 0.5:
		_direction -= aim.z
	if input.x <= -0.5:
		_direction += aim.z
	if input.y <= -0.5:
		_direction -= aim.x
	if input.y >= 0.5:
		_direction += aim.x
	
	return _direction.normalized()


func _step(is_on_floor:bool) -> bool:
	_reset_step()
	if(is_on_floor):
		emit_signal("stepped")
		return true
	return false


func _is_step(velocity:float, is_on_floor:bool, _delta:float) -> bool:
	if(abs(velocity) < 0.1):
		return false
	_step_cycle = _step_cycle + ((velocity + step_lengthen) * _delta)
	if(_step_cycle <= _next_step):
		return false
	return true

func _on_sprinted():
	emit_signal("sprinted")

func _on_jumped():
	emit_signal("jumped")

func _on_grind_start():
	emit_signal("grind_start")

func _on_grind_end():
	emit_signal("grind_end")
