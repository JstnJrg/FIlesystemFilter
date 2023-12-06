tool
extends Tree

onready var dir_options = $"../../../../../PopUP/DirOptions"
onready var dir_color_picker = $"../../../../../PopUP/DirColorPicker"

const DIR_ICON := preload("res://addons/FilterManeger/icons/Folder.png")
const INITIAL_EXTENSION := "txt"

var DataResearcher_ := DataResearcher.new()
var editor_theme : Theme = null
var editor_settings : EditorSettings = null
var dir_data := {}

signal updated_data(data)
signal dir_changed
signal updated_theme(theme_,editor)

func _init():
	connect("updated_theme",self,"updated_theme")

func _ready():
	initial()
	emit_signal("dir_changed")

func initial():
	DataResearcher_.search(INITIAL_EXTENSION)
	var data : Array = DataResearcher_.data_dirs.duplicate()
	update_data(data)

func build_tree():
	
	if dir_data.empty(): 
		printerr("there is no dir data")
		return
	
	var root := create_item()
	root.set_text(0,"res://")
	
	root.set_meta("path","res://")
	root.set_meta("name","res://")
	root.set_icon(0,DIR_ICON)
	root.set_icon_modulate(0,editor_settings.get("interface/theme/accent_color"))
	
	for data in dir_data:
		var treeitem := create_item(root)
		treeitem.set_text(0,data)
		treeitem.set_meta("name",data)
		treeitem.set_meta("path",dir_data[data])
		treeitem.set_icon(0,DIR_ICON)
		treeitem.set_icon_modulate(0,editor_settings.get("interface/theme/accent_color"))

func clear_treeitem():
	clear()
	dir_data.clear()

func show_option_popup():
	dir_options.rect_position = get_global_mouse_position()
	dir_options.show()

func update_data(dirs_data : Array):
	
	clear_treeitem()
	
	for data in  dirs_data:
		var path : String = data
		var dir_name : String = path.split("/",false)[-1]
		if dir_name == ".import": continue
		dir_data[dir_name] = path
	
	call_deferred("build_tree")

func show_colorpicker():
	dir_color_picker.rect_position = get_global_mouse_position()+Vector2(60,-300)
	dir_color_picker.show()

func DirsTree_item_selected():
	emit_signal("dir_changed")

func DirsTree_item_rmb_selected(position):
	show_option_popup()

func updated_theme(theme_:Theme, editor: EditorSettings):
	editor_theme = theme_
	editor_settings = editor

func Timer_initial_update_timeout():
	dir_options.theme = editor_theme
	dir_color_picker.theme = editor_theme

func DirOptions_index_pressed(index: int):
	match index:
		1:  #Change color
			show_colorpicker()
		
		2: #Copypath
			var treeitem := get_selected()
			if treeitem: OS.clipboard = treeitem.get_meta("path")

func DirColorPicker_color_changed(color: Color):
	var treeitem := get_selected()
	if treeitem:
		
		var color2 := color
		var color3 := color
		
		color2.a = 0.1
		
		treeitem.set_custom_bg_color(0,color2,false)
		treeitem.set_icon_modulate(0,color3)
