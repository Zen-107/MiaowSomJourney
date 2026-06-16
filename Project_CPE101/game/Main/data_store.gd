extends Node

# ข้อมูลเส้นทาง
var path_positions: Array[Vector2] = []
var path_buttons: Array[String] = []
var current_level: int = 1
var total_nodes_in_level: int = 0

# คืนค่าตำแหน่งทั้งหมดของเส้นทางที่ตัวละครเดิน
func get_path_positions() -> Array:
	return path_positions

# คืนค่ารายชื่อปุ่มทั้งหมดที่ตัวละครสำรวจ
func get_path_buttons() -> Array:
	return path_buttons

# เพิ่มตำแหน่งใหม่ใน path_positions หากยังไม่มีตำแหน่งนี้
func add_path_position(position: Vector2) -> void:
	if path_positions.size() == 0 or path_positions[path_positions.size() - 1] != position:
		path_positions.append(position)

# เพิ่มชื่อปุ่มใหม่ใน path_buttons หากยังไม่มีปุ่มนี้
func add_path_button(button_name: String) -> void:
	if path_buttons.size() == 0 or path_buttons[path_buttons.size() - 1] != button_name:
		path_buttons.append(button_name)

# รีเซ็ตข้อมูลทั้งหมด
func reset_data() -> void:
	path_positions.clear()
	path_buttons.clear()
	current_level = 1
	total_nodes_in_level = 0
