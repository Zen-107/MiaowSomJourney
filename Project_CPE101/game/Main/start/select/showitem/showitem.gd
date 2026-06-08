extends CanvasLayer

@onready var resume_button = $Panel/Close
@onready var item_name_label = $Panel/Name
@onready var item_description_label = $Panel/Description
@onready var item_texture_rect = $Panel/Image

var item_data = null

func _ready():
	if item_data:
		item_name_label.text = item_data["name"]
		item_description_label.text = item_data["description"]
		item_texture_rect.texture = item_data["texture"]
	else:
		print("Error: item_data is null in _ready")

func set_item_data(data):
	print("set_item_data called with: ", data)
	item_data = data
	item_name_label.text = item_data["name"]
	item_description_label.text = item_data["description"]
	item_texture_rect.texture = item_data["texture"]

func _on_close_pressed():
	print("Close button pressed!")
	get_tree().paused = false
	queue_free()
