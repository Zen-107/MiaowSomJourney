extends Control

# ตัวแปรที่จะรับจาก script หลัก
var adjacency_matrix: Array = []
var node_positions: Array = []
var matrix_size: int = 0
var is_drawing: bool = false

const NODE_RADIUS: float = 20.0

func _ready() -> void:
	print("[GraphDrawer] ========== _ready() START ==========")
	print("[GraphDrawer] Node name: ", name)
	print("[GraphDrawer] Node size: ", size)
	print("[GraphDrawer] ========== _ready() END ==========")

func _draw() -> void:
	print("[GraphDrawer] ========== _draw() called ==========")
	print("[GraphDrawer]   is_drawing: ", is_drawing)
	print("[GraphDrawer]   matrix_size: ", matrix_size)
	print("[GraphDrawer]   adjacency_matrix empty: ", adjacency_matrix.is_empty())
	print("[GraphDrawer]   node_positions size: ", node_positions.size())
	
	if not is_drawing or adjacency_matrix.is_empty():
		print("[GraphDrawer] ⏭️ Skipping draw - no data")
		print("[GraphDrawer] ========== _draw() END (skipped) ==========")
		return
	
	print("[GraphDrawer] 🎨 Starting to draw graph...")
	
	# วาดเส้น (Edges)
	var edge_count: int = 0
	print("[GraphDrawer] Drawing edges...")
	for i in range(matrix_size):
		for j in range(i + 1, matrix_size):
			if adjacency_matrix[i][j] == 1:
				var start_pos: Vector2 = node_positions[i]
				var end_pos: Vector2 = node_positions[j]
				draw_line(start_pos, end_pos, Color.WHITE, 3.0)
				edge_count += 1
				print("[GraphDrawer]   Edge: Node ", i+1, " → Node ", j+1)
	
	print("[GraphDrawer] Total edges drawn: ", edge_count)
	
	# วาดจุด (Nodes)
	print("[GraphDrawer] Drawing nodes...")
	for i in range(matrix_size):
		var pos: Vector2 = node_positions[i]
		print("[GraphDrawer]   Node ", i+1, " at: ", pos)
		
		# วาดวงกลมพื้นหลัง
		draw_circle(pos, NODE_RADIUS, Color.BLUE)
		
		# วาดขอบวงกลม
		draw_arc(pos, NODE_RADIUS, 0, 2 * PI, 32, Color.WHITE, 2.0)
		
		# วาดตัวเลขกำกับ Node
		var label_text: String = str(i + 1)
		var font := get_theme_default_font()
		var font_size: int = 16
		var string_size: Vector2 = font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		var text_pos: Vector2 = pos - (string_size / 2.0) + Vector2(0, font_size / 3.0)
		
		draw_string(font, text_pos, label_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color.WHITE)
	
	print("[GraphDrawer] ✅ Drawing complete!")
	print("[GraphDrawer] ========== _draw() END ==========")

# ฟังก์ชันสำหรับอัปเดตข้อมูลและวาดกราฟ
func update_graph(matrix: Array, positions: Array, size: int) -> void:
	print("[GraphDrawer] ========== update_graph() called ==========")
	print("[GraphDrawer]   matrix size: ", matrix.size())
	print("[GraphDrawer]   positions size: ", positions.size())
	print("[GraphDrawer]   node count: ", size)
	
	adjacency_matrix = matrix
	node_positions = positions
	matrix_size = size
	is_drawing = true
	
	print("[GraphDrawer] Data updated, calling queue_redraw()...")
	queue_redraw()
	print("[GraphDrawer] ========== update_graph() END ==========")

# ฟังก์ชันล้างกราฟ
func clear_graph() -> void:
	print("[GraphDrawer] ========== clear_graph() called ==========")
	adjacency_matrix.clear()
	node_positions.clear()
	is_drawing = false
	matrix_size = 0
	queue_redraw()
	print("[GraphDrawer] Graph cleared")
	print("[GraphDrawer] ========== clear_graph() END ==========")
