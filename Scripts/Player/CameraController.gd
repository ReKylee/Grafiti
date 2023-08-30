extends SpringArm3D

const MOUSE_SENSITIVITY = 0.2
const JOYSTICK_SENSITIVITY = 0.5

func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.x += event.relative.y * MOUSE_SENSITIVITY
		rotation_degrees.y -= event.relative.x * MOUSE_SENSITIVITY
		rotation_degrees.x = clamp(rotation_degrees.x, -45, 45)

