extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_level_1_pressed() -> void:
	#pass # Replace with function body.
	get_tree().change_scene_to_file("res://game/Main/start/select/level/level1/gamelevel_1.tscn")

func _on_level_2_pressed() -> void:
	#pass # Replace with function body.
	get_tree().change_scene_to_file("res://game/Main/start/select/level/level2/gamelevel_2.tscn")

func _on_level_3_pressed() -> void:
	#pass # Replace with function body.
	get_tree().change_scene_to_file("res://game/Main/start/select/level/level3/gamelevel_3.tscn")

func _on_back_pressed() -> void:
	#pass # Replace with function body.
	get_tree().change_scene_to_file("res://game/Main/start/startpage.tscn")
