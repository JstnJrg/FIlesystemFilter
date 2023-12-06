tool 
extends ColorPicker


func _ready():
	set_process_input(true)

func _input(event: InputEvent):
	
	if event is InputEventMouseButton and not event.is_echo():
		if not get_rect2().has_point(event.position):
			hide()

func get_rect2() -> Rect2:
	return Rect2(rect_position,rect_size)

