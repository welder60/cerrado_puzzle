# ScoreManager.gd
# Script para gerenciar a pontuação e o highscore.

extends Node

# --- Variáveis ---
var highscore: int = 0
const SAVE_PATH = "user://highscore.save"

# Chamado quando o nó entra na árvore da cena.
func _ready():
	load_highscore()

# Calcula o score final baseado no número de movimentos.
func calculate_score(moves_count: int) -> int:
	# Fórmula simples: menos movimentos = maior score.
	# 10000 é um valor base, pode ser ajustado.
	var score = 10000 - (moves_count * 50)
	if score < 0:
		score = 0
	return score

# Atualiza o highscore se o novo score for maior.
func update_highscore(new_score: int):
	if new_score > highscore:
		highscore = new_score
		save_highscore()

# Salva o highscore em um arquivo.
func save_highscore():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(highscore)
		file.close()

# Carrega o highscore de um arquivo.
func load_highscore():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			highscore = file.get_var()
			file.close()
