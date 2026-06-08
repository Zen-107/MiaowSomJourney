extends Node2D

@onready var character = $TextureRect/maincha
@onready var hp_label = $HPlabel
@onready var popup_label = $Popuplabel
@onready var normal_character_texture = preload("res://resource/characters/maincha/แมว.png")
@onready var armor_character_texture = preload("res://resource/characters/maincha/แมว+เกราะ.PNG")
@onready var sword_character_texture = preload("res://resource/characters/maincha/แมว+ดาบขึ้.PNG")
@onready var hint_scene = load("res://game/Main/start/select/level/level1/hint_1.tscn")
var hint_node: Node
var path_positions: Array = []
var path_buttons: Array = []


var button_a
var button_b
var button_c
var button_d
var button_e
var button_f

var last_pressed_button: Button = null
var visited_buttons: Dictionary = {
	"A":false,
	"B": false,
	"C": false,
	"D": false,
	"E": false,
	"F": false
}
var monster_damaged: Dictionary = {
	"B": false,
	"D": false
}
var is_returning_to_a: bool = false
var has_armor: bool = false
var has_sword: bool = false
var hp: int = 3
var item_scene: PackedScene = ResourceLoader.load("res://game/Main/start/select/showitem/showitem.tscn")
var monster_scene: PackedScene = ResourceLoader.load("res://game/Main/start/select/Mon/monfight.tscn")

var items = [
	{
		"name": "น้ำวิเศษ",
		"description": "เครื่องดื่มหวานปนขมทำให้อยากดื่มเรื่อยๆสามารถเพิ่มเลือด 1 HP ",
		"texture": preload("res://resource/item/ยา2.PNG")
	},
	{
		"name": "เกราะแดง",
		"description": "เกราะสีแดงที่งดงาม สามารถป้องกันได้ 1 HP ",
		"texture": preload("res://resource/item/เกราะแดง.PNG")
	},
	{
		"name": "ดาบขี้เรืองแสง",
		"description": "ดาบที่ไม่คมแต่แสงนั้น!!! แสบตามาก แต่เรามีแว่นกันแดด เมื่อหยิบดาบขึ้นมอนสเตอร์ทุกตัวต่างต้องหลับตาเพราะแสงของมัน ทำให้คุณเดินผ่านมันไปได้อย่างราบรื่น",
		"texture": preload("res://resource/item/ดาบขี้เรืองแสง.PNG")
	}
]
var mons =[
	{
		"mon1" : preload("res://resource/characters/monsters/กากเบี้ยว.PNG"),
		"mon2" : preload("res://resource/characters/monsters/กากเบี้ยว.PNG")
	},
	{
		"mon1" : preload("res://resource/characters/monsters/กากเบี้ยว.PNG"),
		"mon2" : preload("res://resource/characters/monsters/กีกี้คนสวย.PNG")
	},
	{
		"mon1" : preload("res://resource/characters/monsters/กีกี้คนสวย.PNG"),
		"mon2" : preload("res://resource/characters/monsters/นุ่ยนุ้ยนาย.PNG")
	}
]


func _ready() -> void:
	button_a = $TextureRect/A
	button_b = $TextureRect/B
	button_c = $TextureRect/C
	button_d = $TextureRect/D
	button_e = $TextureRect/E
	button_f = $TextureRect/F
	
	button_a.connect("pressed", Callable(self, "_on_a_pressed"))
	button_b.connect("pressed", Callable(self, "_on_b_pressed"))
	button_c.connect("pressed", Callable(self, "_on_c_pressed"))
	button_d.connect("pressed", Callable(self, "_on_d_pressed"))
	button_e.connect("pressed", Callable(self, "_on_e_pressed"))
	button_f.connect("pressed", Callable(self, "_on_f_pressed"))
	
	disable_all_buttons()
	enable_buttons([button_a])
	update_hp_display()

	# สร้าง DataStore ใน Root Tree หากยังไม่มี
	#if not get_tree().root.has_node("DataStore"):
		#var data_store = Node.new()
		#data_store.name = "DataStore"
		#data_store.set_script(preload("res://game/Main/data_store.gd"))
		#get_tree().root.add_child(data_store)
		#print("DataStore created and added to Root!")
	#else:
		#print("DataStore already exists!")
		
func disable_all_buttons() -> void:
	var buttons = [button_a, button_b, button_c, button_d, button_e, button_f]
	for btn in buttons:
		btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.modulate = Color(0.5, 0.5, 0.5)
	
func enable_all_buttons() -> void:
	var buttons = [button_a, button_b, button_c, button_d, button_e, button_f]
	for btn in buttons:
		btn.mouse_filter = Control.MOUSE_FILTER_PASS
		btn.modulate = Color(1, 1, 1)

func enable_buttons(buttons: Array) -> void:
	disable_all_buttons()
	for btn in buttons:
		btn.mouse_filter = Control.MOUSE_FILTER_PASS
		btn.modulate = Color(1, 1, 1)

func move_to_button(button: Button, next_buttons: Array) -> void:
	character.position = button.position
	character.visible = true
	character.z_index = button_a.z_index + 1 
	enable_buttons(next_buttons)
	update_path_and_position(button)

func update_path_and_position(button: Button) -> void:
	if path_positions.size() == 0 or path_positions[path_positions.size() - 1] != button.position:
		path_positions.append(button.position)
		path_buttons.append(button.name)
		print("Path updated:", path_positions)
		print("Path buttons updated:", path_buttons)


func decrease_hp(amount: int) -> void:
	if amount > 0 and use_armor():
		return  # Armor blocked the damage, exit early
	hp = clamp(hp - amount, 0, 3)
	if hp <= 0:
		trigger_game_over()
	update_hp_display()
# Helper function for armor logic
func use_armor() -> bool:
	if has_armor:
		has_armor = false
		character.texture = normal_character_texture
		print("Armor used to block damage.")
		return true
	return false

func update_hp_display() -> void:
	hp_label.text = "%d" % hp

func encounter_monster(button_name: String, mon_index: int) -> void:
	# ตรวจสอบว่ามอนสเตอร์ในปุ่มนั้นถูกสู้ชนะไปแล้วหรือยัง
	if monster_damaged.get(button_name, false):
		display_popup_message("มอนสเตอร์ตัวนี้เคยพ่ายแพ้ไปแล้ว!")
		return

	# โหลดฉาก Monfight
	if monster_scene:
		var monster_instance = monster_scene.instantiate()
		get_tree().root.add_child(monster_instance)
		
		# ส่งข้อมูลมอนสเตอร์ไปยังฉาก Monfight
		if mons.size() > mon_index:
			monster_instance.call_deferred("set_item_data", mons[mon_index])

		# เชื่อมต่อ signal 'fight_ended' เพื่อจัดการหลังการต่อสู้
		if monster_instance.has_signal("fight_ended"):
			monster_instance.connect("fight_ended", Callable(self, "defeat_monster").bind(button_name))
		else:
			print("Error: Monfight scene ไม่มีสัญญาณ 'fight_ended'!")

		# มาร์คว่ามอนสเตอร์ในปุ่มนี้ถูกเจอแล้ว (ตั้งแต่เริ่มต่อสู้)
		monster_damaged[button_name] = true
	else:
		print("Error: ไม่สามารถโหลดฉาก Monfight ได้!")

# ฟังก์ชันจัดการเมื่อมอนสเตอร์ถูกจัดการเสร็จ
func defeat_monster(button_name: String) -> void:
	# มาร์คว่ามอนสเตอร์ในตำแหน่งนี้ถูกปราบแล้ว
	monster_damaged[button_name] = true
	display_popup_message("คุณได้ปราบมอนสเตอร์ในปุ่ม %s แล้ว!" % button_name)


func display_popup_message(message: String) -> void:
	popup_label.text = message
	popup_label.visible = true
	await get_tree().create_timer(2).timeout
	popup_label.visible = false

# ตรวจสอบว่ามอนสเตอร์ในปุ่มนั้นถูกสู้ชนะไปแล้วหรือยัง
func handle_monster(button_name: String, damage: int) -> void:
	# ถ้ามอนสเตอร์เคยพ่ายแพ้แล้ว
	if monster_damaged[button_name]:
		display_popup_message("มอนสเตอร์ตัวนี้เคยพ่ายแพ้ไปแล้ว!")
		return

	# ตรวจสอบว่าผู้เล่นมีดาบหรือไม่
	if has_sword:
		print("ใช้ดาบปราบมอนสเตอร์ได้สำเร็จ!")
		character.texture = sword_character_texture
		monster_damaged[button_name] = true  # มาร์คว่ามอนสเตอร์ในตำแหน่งนี้ถูกปราบแล้ว
		display_popup_message("คุณเอาชนะมอนสเตอร์ด้วยดาบ!")
	else:
		# ไม่มีดาบ: โหลดฉากต่อสู้ Monfight
		encounter_monster(button_name, damage)

signal item_data_ready(item_data)
func pause_item(item_index: int):
	if get_tree().paused:
		get_tree().paused = false
	else:
		if item_index >= 0 and item_index < items.size():
			var item_instance = item_scene.instantiate()
			get_tree().root.add_child(item_instance)
			print("Selected Item: ", items[item_index]["name"])
			item_instance.call_deferred("set_item_data", items[item_index])
			get_tree().paused = true


func _on_show_hint():
	if not hint_node:
		hint_node = hint_scene.instantiate()
		add_child(hint_node)

func _on_hide_hint():
	if hint_node:
		hint_node.queue_free()
		hint_node = null

func reload_current_scene():
	var current_scene = get_tree().current_scene
	if current_scene:
		current_scene.queue_free()  # ลบซีนปัจจุบัน
	var scene_path = "res://game/Main/start/select/level/level1/winlevel_1.tscn"
	var new_scene = load(scene_path).instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene

func add_path_position(position: Vector2) -> void:
	if not position in DataStore.path_positions:
		DataStore.path_positions.append(position)
		print("Path updated:", DataStore.path_positions)

func add_path_button(button_name: String) -> void:
	if not button_name in DataStore.path_buttons:
		DataStore.path_buttons.append(button_name)
		print("Path buttons updated:", DataStore.path_buttons)

func _change_scene_to_win() -> void:
	if is_inside_tree():
		var result = get_tree().change_scene_to_file("res://game/Main/start/select/level/level1/winlevel_1.tscn")
		if result != OK:
			print("Error: Failed to change scene. Error code:", result)
	else:
		print("Error: Node is not inside the tree.")

	
#all button user will play!!!
func _on_a_pressed() -> void:
	decrease_hp(0)
	visited_buttons["A"] = true
	var next_buttons = []
	if not visited_buttons["B"]:
		next_buttons.append(button_b)
	if not visited_buttons["C"]:
		next_buttons.append(button_c)
	if not visited_buttons["D"]:
		next_buttons.append(button_d)
	move_to_button(button_a, next_buttons)
	if get_tree().root.has_node("DataStore"):
		var data_store = get_tree().root.get_node("DataStore")
		data_store.add_path_button("A")
		data_store.add_path_position(button_a.position)
		print("Path positions:", data_store.get_path_positions())
		print("Path buttons:", data_store.get_path_buttons())

	
func _on_b_pressed() -> void:
	if monster_damaged["B"]:
		display_popup_message("มอนสเตอร์ในปุ่มนี้เคยพ่ายแพ้แล้ว!")
	else:
		handle_monster("B", 0)  # ต่อสู้กับมอนสเตอร์
		decrease_hp(1)  # ลด HP
		monster_damaged["B"] = true  # มาร์กว่ามอนสเตอร์ตัวนี้ถูกจัดการแล้ว
	visited_buttons["B"] = true
	move_to_button(button_b, [button_a])  # หลังจากต่อสู้จะย้ายไปที่ปุ่มต่อไป
	move_to_button(button_b, [button_a])
	if get_tree().root.has_node("DataStore"):
		var data_store = get_tree().root.get_node("DataStore")
		data_store.add_path_button("B")
		data_store.add_path_position(button_b.position)
		print("Path positions:", data_store.get_path_positions())
		print("Path buttons:", data_store.get_path_buttons())


func _on_c_pressed() -> void:
	decrease_hp(-1)
	visited_buttons["C"] = true
	move_to_button(button_c, [button_e])
	pause_item(0)
	if get_tree().root.has_node("DataStore"):
		var data_store = get_tree().root.get_node("DataStore")
		data_store.add_path_button("C")
		data_store.add_path_position(button_c.position)
		print("Path positions:", data_store.get_path_positions())
		print("Path buttons:", data_store.get_path_buttons())


func _on_d_pressed() -> void:
	if monster_damaged["D"]:
		display_popup_message("มอนสเตอร์ในปุ่มนี้เคยพ่ายแพ้แล้ว!")
	else:
		handle_monster("D", 0)  # ต่อสู้กับมอนสเตอร์
		decrease_hp(1)  # ลด HP
		monster_damaged["D"] = true  # มาร์กว่ามอนสเตอร์ตัวนี้ถูกจัดการแล้ว  # เรียกใช้ handle_monster สำหรับปุ่ม D และใช้มอนสเตอร์ตัวที่ 1
	visited_buttons["D"] = true
	var next_buttons = []
	if not visited_buttons["A"]:  
		next_buttons.append(button_a)
	if not visited_buttons["F"]:  
		next_buttons.append(button_f)
	if visited_buttons["F"]:
		next_buttons.append(button_a)
	move_to_button(button_d, next_buttons)
	if get_tree().root.has_node("DataStore"):
		var data_store = get_tree().root.get_node("DataStore")
		data_store.add_path_button("D")
		data_store.add_path_position(button_d.position)
		print("Path positions:", data_store.get_path_positions())
		print("Path buttons:", data_store.get_path_buttons())

func _on_e_pressed() -> void:
	call_deferred("_change_scene_to_win")  
	if get_tree().root.has_node("DataStore"):
		var data_store = get_tree().root.get_node("DataStore")
		data_store.add_path_button("E")
		data_store.add_path_position(button_e.position)
		print("Path positions:", data_store.get_path_positions())
		print("Path buttons:", data_store.get_path_buttons())

func _on_f_pressed() -> void:
	decrease_hp(-1)
	visited_buttons["F"] = true
	move_to_button(button_f, [button_d])
	pause_item(0)
	if get_tree().root.has_node("DataStore"):
		var data_store = get_tree().root.get_node("DataStore")
		data_store.add_path_button("F")
		data_store.add_path_position(button_f.position)
		print("Path positions:", data_store.get_path_positions())
		print("Path buttons:", data_store.get_path_buttons())



func _on_more_pressed() -> void:
	get_tree().change_scene_to_file("res://game/Main/start/select/level/level1/morelevel_1.tscn")

func trigger_game_over():
	var game_over_scene = ResourceLoader.load("res://game/Main/start/select/level/level1/game_over.tscn")
	if game_over_scene:
		var game_over_instance = game_over_scene.instantiate()
		get_tree().root.add_child(game_over_instance)


func _on_hint_pressed() -> void:
	_on_show_hint()
