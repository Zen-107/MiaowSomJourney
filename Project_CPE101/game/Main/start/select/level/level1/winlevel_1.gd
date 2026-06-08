extends Node2D

@onready var result_label = $ResultLabel  # Label สำหรับแสดงข้อความผลลัพธ์
@onready var path_line = $pathline       # Line2D สำหรับวาดเส้น

var path_positions: Array = []           # ตำแหน่งของเส้นทาง
var path_buttons: Array = []             # ปุ่มที่สำรวจ

func _ready() -> void:
	# ตรวจสอบว่า DataStore มีอยู่ใน Root Tree หรือไม่
	if get_tree().root.has_node("DataStore"):
		var data_store = get_tree().root.get_node("DataStore")
		
		# โหลดตำแหน่งของเส้นทาง
		path_positions = data_store.get_path_positions()
		if path_positions.size() > 0:
			draw_path_with_offset()

		# โหลดปุ่มที่สำรวจ
		path_buttons = data_store.get_path_buttons()
		if path_buttons.size() > 0:
			display_path(path_buttons)

		# คำนวณคะแนน
		calculate_score()

func draw_path_with_offset() -> void:
	if path_line:  # ตรวจสอบว่า path_line ไม่ใช่ null
		path_line.clear_points()  # ล้างจุดที่วาดก่อนหน้า

		if path_positions.size() > 0:
			var min_x = INF
			var min_y = INF
			var max_x = -INF
			var max_y = -INF

			# หา boundary ของ path_positions
			for position in path_positions:
				min_x = min(min_x, position.x)
				min_y = min(min_y, position.y)
				max_x = max(max_x, position.x)
				max_y = max(max_y, position.y)

			# คำนวณ center ของ path_positions
			var path_center = Vector2((max_x + min_x) / 2, (max_y + min_y) / 2)
			var screen_center = get_viewport_rect().size / 2  # ศูนย์กลางของหน้าจอ
			var offset = screen_center - path_center  # Offset เพื่อปรับให้ path อยู่ตรงกลาง

			# วาดเส้นปรับค่าตาม offset
			for position in path_positions:
				var adjusted_position = position + offset
				var local_position = path_line.to_local(adjusted_position)  # แปลงตำแหน่งเป็น Local
				path_line.add_point(local_position)
	else:
		print("Error: path_line is null!")

func display_path(path_buttons: Array) -> void:
	# แสดงเส้นทางที่สำรวจ
	var path_text = "Path: " + " → ".join(path_buttons)
	var score = calculate_score()
	result_label.text = path_text + "\n" + "Score: " + str(score) + " / 100"

func calculate_score() -> int:
	if path_buttons.size() > 0:
		var score = (path_buttons.size() / 6.0) * 100
		return round(score)
	return 0

func _on_home_pressed() -> void:
	print("Pressed Home Button !")
	get_tree().change_scene_to_file("res://game/Main/start/select/selectAlevel.tscn")

func _on_next_pressed() -> void:
	print("Go level2")
	get_tree().change_scene_to_file("res://game/Main/start/select/level/level2/gamelevel_2.tscn")


func _on_restart_pressed() -> void:
	print("Re-game")
	get_tree().change_scene_to_file("res://game/Main/start/select/level/level1/gamelevel_1.tscn")
