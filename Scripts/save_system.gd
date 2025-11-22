extends Node

class_name SaveSystem

const SAVE_FILE := "user://worldsave.json"

static func load_save() -> Dictionary:
	var file := FileAccess.open(SAVE_FILE, FileAccess.READ)
	if file == null:
		return {
			"seed": randi(),
			"map_data": {}
		}
	
	var text := file.get_as_text()
	var parsed:Variant = JSON.parse_string(text)
	
	if  typeof(parsed) != TYPE_DICTIONARY:
		push_error("SaveSystem: worldsave.json damaged")
		return {
			"seed": randi(),
			"map_data": {}
		}
	return parsed
		

static func save(data: Dictionary) -> void:
	var file := FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	
static func delete_save() -> void:
	if FileAccess.file_exists(SAVE_FILE):
		DirAccess.remove_absolute(SAVE_FILE)
