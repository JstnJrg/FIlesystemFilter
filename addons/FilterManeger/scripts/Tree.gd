tool 
extends Tree

onready var option_button = $"../../OptionButton"
onready var panel = $"../../../editor_container/Panel"
onready var popup = $"../../../PopUP/Popup"
onready var rename_popup_node = $"../../../PopUP/rename"
onready var next_name = $"../../../PopUP/rename/VBoxContainer/next_name"
onready var timer_update_all = $"../../../Timer_update_all"
onready var dirs_tree = $"../../../editor_container/Panel/VBoxContainer/ScrollContainer/DirsTree"

#classes
var DataResearcher_ := DataResearcher.new()
var filesystem : EditorFileSystem = null
var editor : EditorSettings = null
var editor_theme : Theme = null

func _ready():
	update_theme()
	signlas()

func signlas():
	dirs_tree.connect("dir_changed",self,"scan_changed")
	dirs_tree.emit_signal("updated_theme",editor_theme,editor)

func update_theme():
	popup.theme = editor_theme
	next_name.theme = editor_theme
	rename_popup_node.theme = editor_theme
	panel.theme = editor_theme

func update_filesystem():
	filesystem.scan()

func is_root():
	if get_selected() == get_root(): return true
	else : return false

func get_drag_data(position):
	
	drop_mode_flags = DROP_MODE_INBETWEEN | DROP_MODE_ON_ITEM
	
	var preview = Label.new()
	var treeitem := get_selected()
	
	preview.text = treeitem.get_text(0)
	
	return get_selected().get_meta("drag_data") if not (treeitem == get_root()) else ""

func can_drop_data(position, data):
	return data is TreeItem

func drop_data(position, data): #End drag
	print(get_item_at_position(position))

func erease():
	clear()
	DataResearcher_.clear_data()

func update_tree(extension: String):
	
	erease()
	
	var root := create_item()
	var datachildren : Array = DataResearcher_.search(extension,get_current_dir_selected())
	
	root.set_icon_modulate(0,editor.get("interface/theme/accent_color"))
	root.set_icon(0,preload("res://addons/FilterManeger/icons/Folder.png"))
	root.set_text(0,get_current_dir_name()+" (*.%s) "%extension)
	
	for data in datachildren:
		var child := create_item(root)
		child.set_text(0,data.nome)
		child.set_icon(0,data.icon)
		
		var drag_data := {
			"files":[data.path],
			"from":self,
			"type":"files"}
		child.set_meta("path",data.path)
		child.set_meta("drag_data",drag_data)

func rebuild_tree():
	update_tree(DataResearcher_.get_current_extension())

func get_current_dir_selected():
	if dirs_tree.get_selected():
		var path : String = dirs_tree.get_selected().get_meta("path")
		return path
	return "res://"

func get_current_dir_name():
	if dirs_tree.get_selected() :
		var path : String = dirs_tree.get_selected().get_meta("name")
		return path
	return "res://"

func popup():
	popup.rect_position = get_global_mouse_position()
	popup.show_modal()

func popup_rename():
	var data : String = get_selected().get_meta("path")
	
	rename_popup_node.rect_position = get_global_mouse_position()
	rename_popup_node.window_title = "Rename:"+data.get_file()
	next_name.text = data.get_file()
	
	rename_popup_node.show()

func item_selected(index: int):
	var extension : String = option_button.get_item_text(index)
	update_tree(extension)

func text_entered(new_text: String):
	
	if new_text.get_extension():
		
		var extension := new_text.get_extension()
		var extension_data := []
		
		for i in option_button.get_item_count():
			
			var item_extension : String = option_button.get_item_text(i)
			if not extension_data.has(item_extension): extension_data.append(item_extension)
		
		if not extension_data.has(extension):
			option_button.add_icon_item(preload("res://addons/FilterManeger/icons/Search.png"),extension.to_lower())
	
	else : printerr("invalid extension")

func treeitem_options(filepath: String,option_indx: int,nome := ""):
	
	var directory := Directory.new()
	var error := directory.open(filepath.get_base_dir())
	
	
	if  error == OK:
		
		match option_indx:
			1: #Rename
				var new_name := filepath.get_base_dir()+"/"+nome
				var error2 := directory.rename(filepath,new_name)
				
				rename_popup_node.hide()
				
				if error != OK  : printerr(error2)
			
			2: #Delete
				var error3 := directory.remove(filepath)
				if error3 != OK: printerr(error3)
		
		call_deferred("update_filesystem")
	
	else: printerr(error)
	
	timer_update_all.start()

func item_rmb_selected(position):
	popup()

func popup_index_pressed(index: int):
	
	match index:
		1: #Delete
			if is_root():
				printerr("can not delete root")
				return
			var treeitem := get_selected()
			treeitem_options(treeitem.get_meta("path"),2)
		
		2: #Rename
			if is_root():
				printerr("can not rename root")
				return
			popup_rename()

func rename_request_pressed():
	
	var nome : String = next_name.text
	var treeitem := get_selected()
	
	if nome.is_valid_filename():
		treeitem_options(treeitem.get_meta("path"),1,nome)
	
	else : printerr("invalid_filename")

func timer_update_all_timeout():
	call_deferred("rebuild_tree")

func tree_item_selected():
#	update_treeitem_dir()
	pass

func button_cancel_pressed():
	rename_popup_node.hide()

func scan_changed():
	timer_update_all.start()
