extends Control

func _ready() -> void:
	pass

func _on_resume_pressed() -> void:
	print("Resume button pressed")
	get_tree().change_scene_to_file("res://game/Main/start/select/level/level1/gamelevel_1.tscn")
	#resume()

func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://game/Main/start/select/selectAlevel.tscn")

# Button: Restart Current Scene
func _on_restart_pressed() -> void:
	print("Restart button pressed")
