extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://game/Main/start/startpage.tscn")
	#print("start")


func _on_howto_pressed() -> void:
	get_tree().change_scene_to_file("res://game/Main/howto/HowtoPlay.tscn")


func _on_story_pressed() -> void:
	#pass
	get_tree().change_scene_to_file("res://game/Main/more/About.tscn")
	#print("story")


func _on_more_pressed() -> void:
	#pass # Replace with function body.
	get_tree().change_scene_to_file("res://game/Main/more/more_menu.tscn")
