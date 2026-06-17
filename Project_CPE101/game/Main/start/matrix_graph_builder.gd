extends Control

# --- Node References ---
@onready var size_input: SpinBox = $MarginContainer/HBoxContainer/VBoxContainer/SizeInput
@onready var generate_btn: Button = $MarginContainer/HBoxContainer/VBoxContainer/GenerateGridBtn
@onready var clear_btn: Button = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/ClearBtn
@onready var back_btn: Button = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/BackBtn
@onready var matrix_grid: GridContainer = $MarginContainer/HBoxContainer/VBoxContainer/ScrollContainer/MatrixInputGrid
@onready var status_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/StatusLabel
@onready var graph_display: Control = $MarginContainer/HBoxContainer/PanelContainer/GraphDisplay

# --- Variables ---
var matrix_size: int = 4
var adjacency_matrix: Array = []
var node_positions: Array = []

# --- Constants ---
const GRAPH_MARGIN: float = 50.0

func _ready() -> void:
	print("[MatrixBuilder] ========== _ready() START ==========")
	
	# Debug ปุ่มทั้งหมด
	print("[MatrixBuilder] 📍 Checking buttons...")
	print("[MatrixBuilder]   clear_btn: ", clear_btn)
	print("[MatrixBuilder]   clear_btn.visible: ", clear_btn.visible)
	print("[MatrixBuilder]   clear_btn.disabled: ", clear_btn.disabled)
	print("[MatrixBuilder]   back_btn: ", back_btn)
	print("[MatrixBuilder]   back_btn.visible: ", back_btn.visible)
	print("[MatrixBuilder]   back_btn.disabled: ", back_btn.disabled)
	
	# เชื่อม Signal ปุ่มต่างๆ
	print("[MatrixBuilder] 🔗 Connecting signals...")
	generate_btn.pressed.connect(_on_generate_btn_pressed)
	clear_btn.pressed.connect(_on_clear_btn_pressed)
	back_btn.pressed.connect(_on_back_btn_pressed)
	size_input.value_changed.connect(_on_size_changed)
	print("[MatrixBuilder] Signals connected")
	
	# ตรวจสอบ GraphDisplay
	print("[MatrixBuilder] GraphDisplay script: ", graph_display.get_script())
	print("[MatrixBuilder] GraphDisplay size: ", graph_display.size)
	
	# เริ่มต้นสร้างตารางขนาด 4x4
	print("[MatrixBuilder] Creating initial grid (4x4)...")
	_create_input_grid(4)
	
	status_label.text = "พร้อมใช้งาน - กรุณากรอกเมทริกซ์"
	print("[MatrixBuilder] ========== _ready() END ==========")

# 1. ฟังก์ชันสร้างช่องกรอกข้อมูลแบบ Dynamic
func _create_input_grid(size: int) -> void:
	print("[MatrixBuilder] _create_input_grid(size=", size, ")")
	
	for child in matrix_grid.get_children():
		child.queue_free()
	
	matrix_grid.columns = size
	matrix_size = size
	
	for i in range(size * size):
		var input_field := LineEdit.new()
		input_field.custom_minimum_size = Vector2(40, 40)
		input_field.alignment = HORIZONTAL_ALIGNMENT_CENTER
		input_field.max_length = 1
		
		input_field.text_changed.connect(_on_input_changed.bind(input_field))
		
		var row: int = i / size
		var col: int = i % size
		if row == col:
			input_field.text = "0"
			input_field.editable = false
			input_field.modulate = Color(0.5, 0.5, 0.5)
		else:
			input_field.text = ""
			
		matrix_grid.add_child(input_field)
	
	print("[MatrixBuilder] Grid created: ", size, "x", size)

# 2. ฟังก์ชันตรวจสอบและอ่านค่าเมทริกซ์
func _parse_matrix() -> bool:
	print("[MatrixBuilder] _parse_matrix() called")
	adjacency_matrix.clear()
	var inputs: Array = matrix_grid.get_children()
	
	for row in range(matrix_size):
		var current_row: Array = []
		for col in range(matrix_size):
			var index: int = row * matrix_size + col
			var text: String = inputs[index].text
			
			if text != "0" and text != "1":
				print("[MatrixBuilder] ❌ Invalid input at [", row, "][", col, "]")
				status_label.text = "⚠️ กรุณากรอกเฉพาะ 0 หรือ 1 ให้ครบทุกช่อง"
				status_label.modulate = Color.RED
				return false
				
			current_row.append(int(text))
		adjacency_matrix.append(current_row)
	
	print("[MatrixBuilder] Matrix parsed:")
	for i in range(matrix_size):
		print("[MatrixBuilder]   Row ", i, ": ", adjacency_matrix[i])
	
	if not _is_valid_simple_graph():
		return false
		
	status_label.text = "✅ เมทริกซ์ถูกต้อง! แสดงกราฟแล้ว"
	status_label.modulate = Color.GREEN
	print("[MatrixBuilder] ✅ Matrix validation passed")
	return true

func _is_valid_simple_graph() -> bool:
	print("[MatrixBuilder] Checking symmetry...")
	for i in range(matrix_size):
		for j in range(matrix_size):
			if adjacency_matrix[i][j] != adjacency_matrix[j][i]:
				print("[MatrixBuilder] ❌ Not symmetric at [", i, "][", j, "]")
				status_label.text = "⚠️ เมทริกซ์ต้องเป็นสมมาตร (Undirected Graph)"
				status_label.modulate = Color.RED
				return false
	
	print("[MatrixBuilder] ✅ Matrix is symmetric")
	return true

# 3. ฟังก์ชันคำนวณตำแหน่ง Node
func _calculate_node_positions() -> void:
	print("[MatrixBuilder] _calculate_node_positions()")
	node_positions.clear()
	
	var center: Vector2 = graph_display.size / 2.0
	var radius: float = min(graph_display.size.x, graph_display.size.y) / 2.0 - GRAPH_MARGIN
	
	print("[MatrixBuilder]   GraphDisplay size: ", graph_display.size)
	print("[MatrixBuilder]   Center: ", center, ", Radius: ", radius)
	
	if radius <= 0:
		print("[MatrixBuilder] ❌ ERROR: Radius is 0 or negative!")
		status_label.text = "⚠️ พื้นที่แสดงกราฟเล็กเกินไป"
		status_label.modulate = Color.RED
		return
	
	for i in range(matrix_size):
		var angle: float = (2.0 * PI * float(i)) / float(matrix_size) - (PI / 2.0)
		var x: float = center.x + radius * cos(angle)
		var y: float = center.y + radius * sin(angle)
		node_positions.append(Vector2(x, y))
		print("[MatrixBuilder]   Node ", i+1, ": ", node_positions[i])

# 4. ฟังก์ชันวาดกราฟ
func _draw_graph() -> void:
	print("[MatrixBuilder] ========== _draw_graph() START ==========")
	
	if not _parse_matrix():
		print("[MatrixBuilder] ❌ Parse failed, clearing graph")
		graph_display.clear_graph()
		print("[MatrixBuilder] ========== _draw_graph() END (failed) ==========")
		return
		
	_calculate_node_positions()
	
	print("[MatrixBuilder] Calling graph_display.update_graph()...")
	graph_display.update_graph(adjacency_matrix, node_positions, matrix_size)
	
	print("[MatrixBuilder] ========== _draw_graph() END (success) ==========")

# --- Signal Callbacks ---
func _on_generate_btn_pressed() -> void:
	print("[MatrixBuilder] 🔘 Generate button pressed")
	var new_size: int = size_input.value
	print("[MatrixBuilder]   New size: ", new_size)
	_create_input_grid(new_size)
	_draw_graph()

func _on_size_changed(value: float) -> void:
	print("[MatrixBuilder] 🔄 Size changed to: ", value)
	_create_input_grid(int(value))
	_draw_graph()

func _on_input_changed(new_text: String, input_node: LineEdit) -> void:
	print("[MatrixBuilder] ⌨️ Input changed: '", new_text, "'")
	if new_text != "0" and new_text != "1":
		print("[MatrixBuilder]   Invalid input, clearing field")
		input_node.text = ""
	_draw_graph()

func _on_clear_btn_pressed() -> void:
	print("[MatrixBuilder] 🗑️ 🗑️ 🗑️ CLEAR BUTTON PRESSED! 🗑️ 🗑️ 🗑️")
	
	for child in matrix_grid.get_children():
		if child is LineEdit:
			var row: int = matrix_grid.get_children().find(child) / matrix_size
			var col: int = matrix_grid.get_children().find(child) % matrix_size
			if row != col:
				child.text = ""
	
	adjacency_matrix.clear()
	node_positions.clear()
	status_label.text = "🗑️ ล้างข้อมูลแล้ว - กรุณากรอกใหม่"
	status_label.modulate = Color.YELLOW
	
	graph_display.clear_graph()
	print("[MatrixBuilder] Data cleared")

func _on_back_btn_pressed() -> void:
	print("[MatrixBuilder] 🔙BACK BUTTON PRESSED! ")
	print("[MatrixBuilder] Current scene: ", get_tree().current_scene.scene_file_path)
	
	var target_path: String = "res://game/Main/start/startpage.tscn"
	print("[MatrixBuilder] Target path: ", target_path)
	print("[MatrixBuilder] File exists: ", ResourceLoader.exists(target_path))
	
	if ResourceLoader.exists(target_path):
		print("[MatrixBuilder] ✅ File exists, changing scene...")
		get_tree().change_scene_to_file(target_path)
	else:
		print("[MatrixBuilder] ❌ File not found!")
		status_label.text = "❌ ไม่พบไฟล์: " + target_path
		status_label.modulate = Color.RED
