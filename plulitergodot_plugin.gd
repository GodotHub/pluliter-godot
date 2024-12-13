@tool
extends EditorPlugin

const panel = preload("res://addons/pluliter/editor/pluliter_script_manager.tscn")
var _panel

func _enter_tree() -> void:
	_add_autoloads()
	_panel = panel.instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, _panel)
	print_rich("---------------------------------------------------------------------------------")
	print_rich("-------------- [b][i][color=ALICE_BLUE]Pluliter Godot V1.0[/color][/i][/b] --------------")
	print_rich("---------------------------------------------------------------------------------")

func _exit_tree() -> void:
	_remove_autoloads()
	remove_control_from_docks(_panel)
	_panel.free()

func _add_autoloads():
	add_autoload_singleton("pscripts", "res://addons/pluliter/scripts/pluliter_scripts/pluliterscripts_Interpreter.gd")
func _remove_autoloads():
	remove_autoload_singleton("pscripts")
