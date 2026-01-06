extends Control
class_name ScoreManager
# Estrutura: { "1": {"moves": 5, "stars": 3}, "2": {"moves": 12, "stars": 2} }
var level_data: Dictionary = {}
const SAVE_PATH = "user://level_scores.save"

# Atualiza os dados da fase. Retorna um dicionário com o que mudou.
func update_stage_result(stage_id: int, moves: int, stars: int) -> Dictionary:	
	load_data()
	var stage_key = str(stage_id)
	var new_record = false
	var new_stars = false
	# Se a fase nunca foi jogada, cria a entrada inicial
	if not level_data.has(stage_key):
		level_data[stage_key] = {"moves": moves, "stars": stars}
		new_record = true
		new_stars = true
	else:
		# Verifica se bateu o recorde de movimentos (menor é melhor)
		if moves < level_data[stage_key]["moves"]:
			level_data[stage_key]["moves"] = moves
			new_record = true
		
		# Verifica se ganhou mais estrelas do que já tinha
		if stars > level_data[stage_key]["stars"]:
			level_data[stage_key]["stars"] = stars
			new_stars = true
	
	if new_record or new_stars:
		save_data()
	
	return {"new_record": new_record, "new_stars": new_stars}

# Retorna os dados de uma fase ou valores padrão
func get_stage_info(stage_id: int) -> Dictionary:
	load_data()
	var stage_key = str(stage_id)
	if level_data.has(stage_key):
		return level_data[stage_key]
	return {"moves": -1, "stars": 0}

func save_data():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(level_data)
		file.close()

func load_data():
	level_data = {}
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var data = file.get_var()
			if data is Dictionary:
				level_data = data
			file.close()

func clear_data():
	level_data = {}
	save_data()
