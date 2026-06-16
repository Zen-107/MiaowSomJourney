class_name MonsterData
extends RefCounted

# ==============================================================================
# ข้อมูลมอนสเตอร์ทั้งหมดในเกม
# Index 0: มอนสเตอร์ระดับง่าย (กากเบี้ยว x2)
# Index 1: มอนสเตอร์ระดับกลาง (กากเบี้ยว + กีกี้คนสวย)
# Index 2: มอนสเตอร์ระดับยาก (กีกี้คนสวย + นุ่ยนุ้ยนาย)
# ==============================================================================
const MONSTERS: Array[Dictionary] = [
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
# Helper Functions
# ==============================================================================
static func get_monster(index: int) -> Dictionary:
	if index >= 0 and index < MONSTERS.size():
		return MONSTERS[index]
	return {}

static func get_monster_count() -> int:
	return MONSTERS.size()
