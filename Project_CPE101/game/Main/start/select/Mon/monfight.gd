extends CanvasLayer

@onready var mon_1 = $Panel/mon1
@onready var mon_2 = $Panel/mon2

var mon_data = {}

func _ready() -> void:
	if mon_data:
		mon_1.texture = mon_data["mon1"]
		mon_2.texture = mon_data["mon2"]
	else:
		print("Error: mon_data is null in _ready")

func set_item_data(data: Dictionary) -> void:
	mon_data = data
	mon_1.texture = mon_data["mon1"]
	mon_2.texture = mon_data["mon2"]

func _on_close_pressed():
	print("Close button pressed!")
	get_tree().paused = false
	queue_free()
