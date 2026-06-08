extends CanvasLayer

func _ready():
	var button = get_node("back")
	if button != null:
		button.connect("pressed", Callable(self, "hint_closed"))
	else:
		print("Button 'Back' not found")
func hint_closed():
	emit_signal("hint_closed")
	queue_free()
