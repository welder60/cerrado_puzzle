extends VBoxContainer
class_name GameManager

signal victory_handled(moves_count:int,stars:int,new_record:bool)

enum Difficulty { EASY,MEDIUM,HARD }

@onready var game_board = $GameBoard
@onready var level_manager = LevelManager.new()
@onready var score_manager = ScoreManager.new()

var _stage_id:int
var _quick_play_difficulty:Difficulty
var _quick_play_matrix:Array[Array]
var _quick_play:bool
var record_moves = -1
var max_moves = []

func _ready() -> void:
	game_board.game_won.connect(_handle_victory)

func _handle_victory(moves_count:int):	
	var stars = -1	
	var result = {}
	if !_quick_play:		
		stars = 1
		if moves_count<=max_moves[1]:stars = 2
		if moves_count<=max_moves[0]:stars = 3
		result = score_manager.update_stage_result(_stage_id,moves_count,stars)
	else:
		result = score_manager.update_quick_play(_quick_play_difficulty,moves_count)
		
	emit_signal("victory_handled",moves_count,stars,result["new_record"])


func load_stage(stage_id:int):
	_quick_play = false
	_stage_id = stage_id	
	record_moves = score_manager.get_stage_info(stage_id)["moves"]
	
	var stage_data = level_manager.get_stage_data(stage_id)
	max_moves = stage_data["max_moves"]	
	
	game_board.start_from_matrix(stage_data["grid"])


func quick_play(difficulty:Difficulty):
	_quick_play = true
	_quick_play_difficulty = difficulty	
	
	record_moves = score_manager.get_quick_play_info(difficulty)["moves"]
	
	var rows:int = 2
	var columns:int = 2
	
	match difficulty:
		Difficulty.EASY:
			rows = 4
			columns = 3
		Difficulty.MEDIUM:
			rows = 4
			columns = 4
		Difficulty.HARD:
			rows = 5
			columns = 4
	
	_quick_play_matrix = _generate_board(columns,rows)
	_quick_play_difficulty = difficulty
	_stage_id = -1
	game_board.start_from_matrix(_quick_play_matrix)

func restart():
	if _quick_play:
		game_board.start_from_matrix(_quick_play_matrix)		
	else:
		load_stage(_stage_id)
		
	
func _generate_board(columns:int,rows:int):
	var ids = _shuffle_ids()
	var matrix: Array[Array] = []
	var current_id_index = 0
	var total = columns*rows
	var filled_cells = 0
	var cicles = 0
	
	for i in range(rows):
		matrix.append([])
		matrix[i].resize(columns)
	
	var same_cell = false
	while filled_cells < total:
		var i = randi()%rows
		var j = randi()%columns
		if matrix[i][j] == null:
			matrix[i][j] = ids[current_id_index]
			filled_cells+=1
			if same_cell:
				current_id_index+=1
			same_cell = !same_cell
		cicles+=1
		if cicles>100:
			return matrix
	return matrix
	
func _shuffle_ids()->Array:
	var ids = []	
	for i in range(10):
		ids.append(i)		
	ids.shuffle()
	return ids
