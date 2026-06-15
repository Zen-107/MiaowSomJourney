extends Node2D

@onready var result_label: Label = $ResultLabel
@onready var path_line: Line2D = $pathline

var path_positions: Array[Vector2] = []
var path_buttons: Array[String] = []
var unique_nodes: Array[String] = []

const TOTAL_NODES_IN_LEVEL: int = 6

func _ready() -> void:
	if get_tree().root.has_node("DataStore"):
		var data_store = get_tree().root.get_node("DataStore")
		
		# ✅ แปลง Array ธรรมดา → Typed Array
		var raw_positions: Array = data_store.get_path_positions()
		path_positions.clear()
		for pos in raw_positions:
			path_positions.append(pos)
		
		var raw_buttons: Array = data_store.get_path_buttons()
		path_buttons.clear()
		for btn in raw_buttons:
			path_buttons.append(str(btn))
		
		unique_nodes = get_unique_nodes(path_buttons)
		
		if path_positions.size() > 0:
			draw_path_with_offset()
		
		if unique_nodes.size() > 0:
			display_path(unique_nodes)

func get_unique_nodes(buttons: Array[String]) -> Array[String]:
	var unique: Array[String] = []
	for btn_name in buttons:
		if not unique.has(btn_name):
			unique.append(btn_name)
	return unique

func draw_path_with_offset() -> void:
	if not path_line:
		print("Error: path_line is null!")
		return
	
	path_line.clear_points()
	
	if path_positions.size() == 0:
		return
	
	var min_x: float = INF
	var min_y: float = INF
	var max_x: float = -INF
	var max_y: float = -INF
	
	for position in path_positions:
		min_x = min(min_x, position.x)
		min_y = min(min_y, position.y)
		max_x = max(max_x, position.x)
		max_y = max(max_y, position.y)
	
	var path_center: Vector2 = Vector2((max_x + min_x) / 2, (max_y + min_y) / 2)
	var screen_center: Vector2 = get_viewport_rect().size / 2
	var offset: Vector2 = screen_center - path_center
	
	for position in path_positions:
		var adjusted_position: Vector2 = position + offset
		var local_position: Vector2 = path_line.to_local(adjusted_position)
		path_line.add_point(local_position)

func display_path(unique_buttons: Array[String]) -> void:
	var path_text: String = "Path: " + " → ".join(unique_buttons)
	var score: int = calculate_score()
	result_label.text = path_text + "\n" + "Score: " + str(score) + " / 100"

func calculate_score() -> int:
	if unique_nodes.size() == 0:
		return 0
	
	var score: float = (float(unique_nodes.size()) / float(TOTAL_NODES_IN_LEVEL)) * 100.0
	return round(score)

func _on_home_pressed() -> void:
	print("Pressed Home Button!")
	get_tree().change_scene_to_file("res://game/Main/start/select/selectAlevel.tscn")

func _on_next_pressed() -> void:
	print("Go level2")
	get_tree().change_scene_to_file("res://game/Main/start/select/level/level2/gamelevel_2.tscn")

func _on_restart_pressed() -> void:
	print("Re-game")
	get_tree().change_scene_to_file("res://game/Main/start/select/level/level1/gamelevel_1.tscn")
