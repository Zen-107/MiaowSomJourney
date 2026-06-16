extends Node2D

# ==============================================================================
# CONSTANTS (ค่าคงที่)
# ==============================================================================
const SCENE_WIN := "res://game/Main/winlevel_X.tscn"
const SCENE_GAME_OVER := "res://game/Main/start/select/level/level1/game_over.tscn"
const SCENE_MONSTER := "res://game/Main/start/select/Mon/monfight.tscn"
const SCENE_ITEM := "res://game/Main/start/select/showitem/showitem.tscn"
const SCENE_HINT := "res://game/Main/start/select/level/level1/hint_1.tscn"

# ==============================================================================
# NODE REFERENCES (การอ้างอิงโหนด)
# ==============================================================================
@onready var character: Sprite2D = $TextureRect/maincha
@onready var hp_label: Label = $HPlabel
@onready var popup_label: Label = $Popuplabel

@onready var button_a: Button = $TextureRect/A
@onready var button_b: Button = $TextureRect/B
@onready var button_c: Button = $TextureRect/C
@onready var button_d: Button = $TextureRect/D
@onready var button_e: Button = $TextureRect/E
@onready var button_f: Button = $TextureRect/F

# ==============================================================================
# RESOURCES (ทรัพยากร)
# ==============================================================================
@onready var normal_character_texture: CompressedTexture2D = preload("res://resource/characters/maincha/แมว.png")
@onready var armor_character_texture: CompressedTexture2D = preload("res://resource/characters/maincha/แมว+เกราะ.PNG")
@onready var sword_character_texture: CompressedTexture2D = preload("res://resource/characters/maincha/แมว+ดาบขึ้.PNG")

var hint_scene: PackedScene = load(SCENE_HINT)
var item_scene: PackedScene = load(SCENE_ITEM)
var monster_scene: PackedScene = load(SCENE_MONSTER)

# ==============================================================================
# GAME STATE (สถานะเกม)
# ==============================================================================
var hp: int = 3
var has_armor: bool = false
var has_sword: bool = false
var hint_node: Node = null

var path_positions: Array[Vector2] = []
var path_buttons: Array[String] = []

var visited_buttons: Dictionary = {
	"A": false, "B": false, "C": false, "D": false, "E": false, "F": false
}
var monster_damaged: Dictionary = {
	"B": false, "D": false
}

# ข้อมูลไอเทมและมอนสเตอร์
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

var mons = [
	{
		"mon1": preload("res://resource/characters/monsters/กากเบี้ยว.PNG"),
		"mon2": preload("res://resource/characters/monsters/กากเบี้ยว.PNG")
	},
	{
		"mon1": preload("res://resource/characters/monsters/กากเบี้ยว.PNG"),
		"mon2": preload("res://resource/characters/monsters/กีกี้คนสวย.PNG")
	},
	{
		"mon1": preload("res://resource/characters/monsters/กีกี้คนสวย.PNG"),
		"mon2": preload("res://resource/characters/monsters/นุ่ยนุ้ยนาย.PNG")
	}
]

# ==============================================================================
# CORE FUNCTIONS (ฟังก์ชันหลัก)
# ==============================================================================
func _ready() -> void:
	# รีเซ็ตข้อมูล DataStore ก่อนเริ่มด่านใหม่ (ป้องกันข้อมูลจากด่านเก่าค้าง)
	var ds = get_tree().root.get_node_or_null("DataStore")
	if ds:
		ds.reset_data()
	else:
		print("Warning: DataStore not found. Make sure it's set as Autoload.")

	# เชื่อมต่อ Signal ของปุ่มทั้งหมด (ใช้แบบ Godot 4 ที่สะอาดกว่า)
	button_a.pressed.connect(_on_a_pressed)
	button_b.pressed.connect(_on_b_pressed)
	button_c.pressed.connect(_on_c_pressed)
	button_d.pressed.connect(_on_d_pressed)
	button_e.pressed.connect(_on_e_pressed)
	button_f.pressed.connect(_on_f_pressed)

	# ตั้งค่าเริ่มต้นของเกม
	disable_all_buttons()
	enable_buttons([button_a])
	update_hp_display()

# ==============================================================================
# HELPER FUNCTIONS (ฟังก์ชันช่วยงาน)
# ==============================================================================
func _get_data_store_node() -> Node:
	return get_tree().root.get_node_or_null("DataStore")

func _record_path(button: Button) -> void:
	var ds = _get_data_store_node()
	if ds:
		ds.add_path_button(button.name)
		ds.add_path_position(button.position)
		print("Path recorded - Button:", button.name, "Position:", button.position)

func disable_all_buttons() -> void:
	for btn: Button in [button_a, button_b, button_c, button_d, button_e, button_f]:
		btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.modulate = Color(0.5, 0.5, 0.5)

func enable_buttons(buttons: Array[Button]) -> void:
	disable_all_buttons()
	for btn: Button in buttons:
		btn.mouse_filter = Control.MOUSE_FILTER_PASS
		btn.modulate = Color(1, 1, 1)

func move_to_button(button: Button, next_buttons: Array[Button]) -> void:
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

# ==============================================================================
# HP & COMBAT SYSTEM (ระบบ HP และการต่อสู้)
# ==============================================================================
func update_hp_display() -> void:
	hp_label.text = "%d" % hp

func heal_hp(amount: int) -> void:
	hp = clamp(hp + amount, 0, 3)
	update_hp_display()

func decrease_hp(amount: int) -> void:
	if amount > 0 and use_armor():
		return  # เกราะป้องกันความเสียหายสำเร็จ
	hp = clamp(hp - amount, 0, 3)
	update_hp_display()
	if hp <= 0:
		trigger_game_over()

func use_armor() -> bool:
	if has_armor:
		has_armor = false
		character.texture = normal_character_texture
		display_popup_message("เกราะแดงแตกออกเพื่อป้องกันความเสียหาย!")
		return true
	return false

func handle_monster(button_name: String, monster_index: int) -> void:
	if monster_damaged.get(button_name, false):
		display_popup_message("มอนสเตอร์ตัวนี้เคยพ่ายแพ้ไปแล้ว!")
		return

	if has_sword:
		character.texture = sword_character_texture
		monster_damaged[button_name] = true
		display_popup_message("คุณเอาชนะมอนสเตอร์ด้วยแสงจากดาบขี้เรืองแสง!")
	else:
		encounter_monster(button_name, monster_index)



func encounter_monster(button_name: String, monster_index: int) -> void:
	if not monster_scene:
		print("Error: ไม่สามารถโหลดฉาก Monfight ได้!")
		return

	var monster_instance: Node = monster_scene.instantiate()
	get_tree().root.add_child(monster_instance)

	if mons.size() > monster_index:
		monster_instance.call_deferred("set_item_data", mons[monster_index])

	if monster_instance.has_signal("fight_ended"):
		monster_instance.fight_ended.connect(Callable(self, "_on_monster_fight_ended").bind(button_name))
	else:
		print("Error: Monfight scene ไม่มีสัญญาณ 'fight_ended'!")

func _on_monster_fight_ended(button_name: String) -> void:
	monster_damaged[button_name] = true
	display_popup_message("คุณได้ปราบมอนสเตอร์ในปุ่ม %s แล้ว!" % button_name)

# ==============================================================================
# UI & ITEM SYSTEM (ระบบ UI และไอเทม)
# ==============================================================================
func trigger_game_over() -> void:
	var game_over_instance: Node = load(SCENE_GAME_OVER).instantiate()
	get_tree().root.add_child(game_over_instance)

func _change_scene_to_win() -> void:
	if is_inside_tree():
		var ds = _get_data_store_node()
		if ds: # ส่งจำนวนโหนดทั้งหมดของด่านนี้ไปที่ DataStore
			ds.current_level = 1
			ds.total_nodes_in_level = visited_buttons.keys().size()
		var result: Error = get_tree().change_scene_to_file(SCENE_WIN)
		if result != OK:
			print("Error: Failed to change scene. Error code:", result)

func display_popup_message(message: String) -> void:
	popup_label.text = message
	popup_label.visible = true
	await get_tree().create_timer(2.0).timeout
	popup_label.visible = false

func pause_item(item_index: int) -> void:
	if get_tree().paused:
		get_tree().paused = false
	else:
		if item_index >= 0 and item_index < items.size():
			var item_instance = item_scene.instantiate()
			get_tree().root.add_child(item_instance)
			print("Selected Item: ", items[item_index]["name"])
			item_instance.call_deferred("set_item_data", items[item_index])
			get_tree().paused = true

func _on_show_hint() -> void:
	if not hint_node:
		hint_node = hint_scene.instantiate()
		add_child(hint_node)

func _on_hide_hint() -> void:
	if hint_node:
		hint_node.queue_free()
		hint_node = null

# ==============================================================================
# BUTTON EVENTS (เหตุการณ์เมื่อกดปุ่ม) - ใช้ Logic เดิมที่คุณชอบ
# ==============================================================================
func _on_a_pressed() -> void:
	decrease_hp(0)  # ไม่ลด HP แค่บันทึกการเยี่ยมชม
	visited_buttons["A"] = true
	
	var next_buttons: Array[Button] = []
	if not visited_buttons["B"]:
		next_buttons.append(button_b)
	if not visited_buttons["C"]:
		next_buttons.append(button_c)
	if not visited_buttons["D"]:
		next_buttons.append(button_d)
	
	move_to_button(button_a, next_buttons)
	_record_path(button_a)

func _on_b_pressed() -> void:
	if monster_damaged["B"]:
		display_popup_message("มอนสเตอร์ในปุ่มนี้เคยพ่ายแพ้แล้ว!")
	else:
		handle_monster("B", 0)
		decrease_hp(1)
		monster_damaged["B"] = true
	
	visited_buttons["B"] = true
	move_to_button(button_b, [button_a])  # แก้ไข: ลบการเรียกซ้ำออก
	_record_path(button_b)

func _on_c_pressed() -> void:
	heal_hp(1)  # แก้ไข: ใช้ heal_hp แทน decrease_hp(-1)
	visited_buttons["C"] = true
	
	# C เชื่อมกับ E เท่านั้น (ตาม logic เดิม)
	var next_buttons: Array[Button] = [button_e]
	move_to_button(button_c, next_buttons)
	
	pause_item(0)  # 0 = น้ำวิเศษ
	_record_path(button_c)

func _on_d_pressed() -> void:
	if monster_damaged["D"]:
		display_popup_message("มอนสเตอร์ในปุ่มนี้เคยพ่ายแพ้แล้ว!")
	else:
		handle_monster("D", 0)
		decrease_hp(1)
		monster_damaged["D"] = true
	
	visited_buttons["D"] = true
	
	# ห้ามแก้!!!!! กูเหนื่อย
	var next_buttons: Array[Button] = []
	if not visited_buttons["A"]:  
		next_buttons.append(button_a)
	if not visited_buttons["F"]:  
		next_buttons.append(button_f)
	if visited_buttons["F"]:
		next_buttons.append(button_a)
	move_to_button(button_d, next_buttons)
	_record_path(button_d)

func _on_e_pressed() -> void:
	visited_buttons["E"] = true
	_record_path(button_e)
	call_deferred("_change_scene_to_win")

func _on_f_pressed() -> void:
	heal_hp(1)  # แก้ไข: ใช้ heal_hp แทน decrease_hp(-1)
	visited_buttons["F"] = true
	has_armor = true
	character.texture = armor_character_texture
	move_to_button(button_f, [button_d])
	pause_item(1)  # แก้ไข: 1 = เกราะแดง (ตามที่คุณออกแบบไว้)
	_record_path(button_f)

func _on_more_pressed() -> void:
	get_tree().change_scene_to_file("res://game/Main/start/select/level/level1/morelevel_1.tscn")

func _on_hint_pressed() -> void:
	_on_show_hint()
