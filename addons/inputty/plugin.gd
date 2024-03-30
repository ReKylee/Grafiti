@tool
extends EditorPlugin

const AUTOLOAD_NAME = "Inputty"

func _enter_tree():
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/inputty/Inputty.gd")

func _exit_tree():
	remove_autoload_singleton(AUTOLOAD_NAME)
