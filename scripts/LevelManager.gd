extends Node
class_name LevelManager

func load_stages_data() -> Array:
	var file_path = "res://data/stages.json" 
	
	if not FileAccess.file_exists(file_path):
		push_error("Arquivo JSON não encontrado!")
		return []

	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error != OK:
		print("Erro ao ler JSON: ", json.get_error_message())
		return []

	var data = json.data
	
	return data["stages"]
	
func get_stage_data(stage_id:int):
	for stage in load_stages_data():
		if stage["id"] == stage_id:
			return stage 
