tool
extends EditorPlugin

const main_scene := preload("res://addons/FilterManeger/scenes/FIlesystemFilter.tscn")
var main_instance : Control = null

func _enter_tree():
	
	main_instance = main_scene.instance()
	
	var editor := get_editor_interface()
	var treenode := main_instance.get_node("tree_container/ScrollContainer/Tree")
	
	treenode.filesystem = editor.get_resource_filesystem()
	treenode.editor = editor.get_editor_settings()
	treenode.editor_theme = editor.get_base_control().theme
	
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UL,main_instance)


func _exit_tree():
	if main_instance:
		remove_control_from_docks(main_instance)
