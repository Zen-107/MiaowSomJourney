class_name ItemData
extends RefCounted

# ==============================================================================
# ข้อมูลไอเทมทั้งหมดในเกม (Index: 0=น้ำวิเศษ, 1=เกราะแดง, 2=ดาบขี้เรืองแสง)
# ==============================================================================
const ITEMS: Array[Dictionary] = [
	{
		"name": "น้ำวิเศษ",
		"description": "เครื่องดื่มหวานปนขมทำให้อยากดื่มเรื่อยๆ สามารถเพิ่มเลือด 1 HP",
		"texture": preload("res://resource/item/ยา2.PNG")
	},
	{
		"name": "เกราะแดง",
		"description": "เกราะสีแดงที่งดงาม สามารถป้องกันได้ 1 HP",
		"texture": preload("res://resource/item/เกราะแดง.PNG")
	},
	{
		"name": "ดาบขี้เรืองแสง",
		"description": "ดาบที่ไม่คมแต่แสงนั้น!!! แสบตามาก แต่เรามีแว่นกันแดด เมื่อหยิบดาบขึ้นมอนสเตอร์ทุกตัวต่างต้องหลับตาเพราะแสงของมัน ทำให้คุณเดินผ่านมันไปได้อย่างราบรื่น",
		"texture": preload("res://resource/item/ดาบขี้เรืองแสง.PNG")
	}
]

# ==============================================================================
# Helper Functions
# ==============================================================================
static func get_item(index: int) -> Dictionary:
	if index >= 0 and index < ITEMS.size():
		return ITEMS[index]
	return {}

static func get_item_count() -> int:
	return ITEMS.size()
