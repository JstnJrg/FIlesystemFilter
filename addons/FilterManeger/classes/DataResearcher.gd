tool
class_name DataResearcher extends Resource

#main path
const ICONS_PATH := "res://addons/FilterManeger/icons/"

#Paths icons
const FILE_EXTENSION :={
	["gd"]: preload("res://addons/FilterManeger/icons/GDScript.png"),
	["ogg","wav","mp3"]: preload("res://addons/FilterManeger/icons/AudioStreamSample.png"),
	["gdshader","shader"]: preload("res://addons/FilterManeger/icons/Shader.png"),
	["ttf"]: preload("res://addons/FilterManeger/icons/DynamicFontData.png"),
	["tres"]: preload("res://addons/FilterManeger/icons/Object.png"),
	["tscn","scn"]: preload("res://addons/FilterManeger/icons/PackedScene.png"),
	["default"]: preload("res://addons/FilterManeger/icons/File.png")
}

const IMG_EXTENSION := ["png","jpg","svg"]

var current_extension : String = "png"

var data := []
var data_dirs := []

func search(extension: String,path:="res://") -> Array:
	
	var directory := Directory.new()
	current_extension = extension
	
	if directory.open(path) == OK:
		
		directory.list_dir_begin(true,true)
		var filename_ := directory.get_next()
		
		while filename_ != "":
			
			if directory.current_is_dir():
				var subdirectory := path+filename_+"/"
				
				if subdirectory != ICONS_PATH:
					data_dirs.append(subdirectory)
					search(extension,subdirectory)
			
			elif filename_.get_extension() == extension :
				
				var subdirectory := path+filename_
				var datasearch : Resource = SerchData.new(filename_,subdirectory,get_icon(filename_.get_extension().to_lower(),subdirectory))
				
				data.append(datasearch)
			
			filename_ = directory.get_next()

		
		directory.list_dir_end()
	
	else: printerr("something went wrong when searching for the ",path)
	
	return data.duplicate()

func get_icon(extensin: String,path:String):
	
	for extesion_array in FILE_EXTENSION:
		if extesion_array.has(extensin): return FILE_EXTENSION[extesion_array]
	
	if IMG_EXTENSION.has(extensin): return get_img_icon(path)
	
	else : 
		var default_key : Array = FILE_EXTENSION.keys()[-1]
		return FILE_EXTENSION[default_key]

func get_img_icon(path: String):
	var texture : Texture = load(path)
	var imgdata := texture.get_data()
	var imgtxt := ImageTexture.new()
	imgdata.resize(12,12,Image.INTERPOLATE_CUBIC)
	imgtxt.create_from_image(imgdata)
	
	return imgtxt

func clear_data():
	data.clear()
	data_dirs.clear()

func get_current_extension():
	return current_extension

class SerchData:
	extends Resource
	
	var path := ""
	var nome := ""
	var icon : Texture
	
	func _init(name_,path_,icon_):
		nome = name_
		path = path_
		icon = icon_
		
	
	func _soma():
		pass
