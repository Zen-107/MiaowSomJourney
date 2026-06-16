extends Node2D

@onready var result_label: Label = $ResultLabel
@onready var path_line: Line2D = $pathline

var path_positions: Array[Vector2] = []
var path_buttons: Array[String] = []
var unique_nodes: Array[String] = []

# ตัวแปรสำหรับเก็บข้อมูลด่านปัจจุบัน
var current_level: int = 1
var total_nodes_in_level: int = 6
const MAX_LEVEL: int = 3  # จำนวนด่านทั้งหมดในเกม

func _ready() -> void:
	# ตรวจสอบว่า DataStore มีอยู่ใน Root Tree หรือไม่
	if get_tree().root.has_node("DataStore"):
		var data_store = get_tree().root.get_node("DataStore")
		
		# ✅ ใช้ public variable โดยตรง (ไม่ต้องเรียกฟังก์ชัน)
		current_level = data_store.current_level
		total_nodes_in_level = data_store.total_nodes_in_level
		
		# โหลดตำแหน่งของเส้นทาง (แปลงเป็น Typed Array)
		var raw_positions: Array = data_store.get_path_positions()
		path_positions.clear()
		for pos in raw_positions:
			path_positions.append(pos)
		
		# โหลดปุ่มที่สำรวจ (แปลงเป็น Typed Array)
		var raw_buttons: Array = data_store.get_path_buttons()
		path_buttons.clear()
		for btn in raw_buttons:
			path_buttons.append(str(btn))
		
		# ✅ หาโหนดที่ไม่ซ้ำ (Unique Nodes)
		unique_nodes = get_unique_nodes(path_buttons)
		
		# วาดเส้นและแสดงผลลัพธ์
		if path_positions.size() > 0:
			draw_path_with_offset()
		
		if unique_nodes.size() > 0:
			display_path(unique_nodes)
	else:
		print("Error: DataStore not found!")

# ✅ ฟังก์ชันหาโหนดที่ไม่ซ้ำ (ป้องกันนับซ้ำ)
func get_unique_nodes(buttons: Array[String]) -> Array[String]:
	var unique: Array[String] = []
	for btn_name in buttons:
		if not unique.has(btn_name):
			unique.append(btn_name)
	return unique

# ✅ ฟังก์ชันวาดเส้นโดยปรับ offset ให้อยู่กลางหน้าจอ
func draw_path_with_offset() -> void:
	if not path_line:
		print("Error: path_line is null!")
		return
	
	path_line.clear_points()
	
	if path_positions.size() == 0:
		return
	
	# หา boundary ของ path_positions
	var min_x: float = INF
	var min_y: float = INF
	var max_x: float = -INF
	var max_y: float = -INF
	
	for position in path_positions:
		min_x = min(min_x, position.x)
		min_y = min(min_y, position.y)
		max_x = max(max_x, position.x)
		max_y = max(max_y, position.y)
	
	# คำนวณ center ของ path_positions
	var path_center: Vector2 = Vector2((max_x + min_x) / 2, (max_y + min_y) / 2)
	var screen_center: Vector2 = get_viewport_rect().size / 2
	var offset: Vector2 = screen_center - path_center
	
	# วาดเส้นปรับค่าตาม offset
	for position in path_positions:
		var adjusted_position: Vector2 = position + offset
		var local_position: Vector2 = path_line.to_local(adjusted_position)
		path_line.add_point(local_position)

# ✅ แสดงเส้นทางและคะแนน
func display_path(unique_buttons: Array[String]) -> void:
	var path_text: String = "Path: " + " → ".join(unique_buttons)
	var score: int = calculate_score()
	result_label.text = path_text + "\n" + "Score: " + str(score) + " / 100"

# ✅ คำนวณคะแนนแบบ Dynamic (ใช้ total_nodes_in_level แทน Hardcode)
func calculate_score() -> int:
	if unique_nodes.size() == 0:
		return 0
	
	# ✅ ป้องกันหารด้วยศูนย์
	if total_nodes_in_level == 0:
		return 0
	
	var score: float = (float(unique_nodes.size()) / float(total_nodes_in_level)) * 100.0
	return round(score)

# ✅ ปุ่ม Home - กลับหน้าเลือกด่าน
func _on_home_pressed() -> void:
	print("Pressed Home Button!")
	get_tree().change_scene_to_file("res://game/Main/start/select/selectAlevel.tscn")

# ✅ ปุ่ม Next - ไปด่านถัดไป (Dynamic ตาม current_level)
func _on_next_pressed() -> void:
	var next_level: int = current_level + 1
	
	# ✅ เช็คว่าเป็นด่านสุดท้ายหรือไม่
	if next_level > MAX_LEVEL:
		print("This is the last level!")
		get_tree().change_scene_to_file("res://game/Main/start/select/selectAlevel.tscn")
		return
	
	print("Go to level %d" % next_level)
	var scene_path: String = "res://game/Main/start/select/level/level%d/gamelevel_%d.tscn" % [next_level, next_level]
	get_tree().change_scene_to_file(scene_path)

# ✅ ปุ่ม Restart - เริ่มด่านเดิมใหม่ (Dynamic ตาม current_level)
func _on_restart_pressed() -> void:
	print("Restart level %d" % current_level)
	var scene_path: String = "res://game/Main/start/select/level/level%d/gamelevel_%d.tscn" % [current_level, current_level]
	get_tree().change_scene_to_file(scene_path)
