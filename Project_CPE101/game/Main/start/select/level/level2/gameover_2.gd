extends Control

func _ready() -> void:
	$Label.text = "Game Over"

func _on_retry_pressed():
	var main_scene = load("res://game/Main/start/select/level/level2/gamelevel_2.tscn").instantiate()
	get_tree().root.add_child(main_scene)
	queue_free()

func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://game/Main/start/select/selectAlevel.tscn")
	await get_tree().create_timer(0.1).timeout
	queue_free()
