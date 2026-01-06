extends VBoxContainer

signal victory_handled(moves_count:int,stars:int,new_record:bool)

@onready var game_board = $GameBoard
@onready var level_manager = LevelManager.new()
@onready var score_manager = ScoreManager.new()

var _stage_id:int
var _quick_play_difficulty:String
var record_moves = -1
var max_moves = []

func _ready() -> void:
	game_board.game_won.connect(_handle_victory)
	

func _handle_victory(moves_count:int):
	
	var stars = 1	
	if moves_count<=max_moves[1]:stars = 2
	if moves_count<=max_moves[0]:stars = 3
	var result = score_manager.update_stage_result(_stage_id,moves_count,stars)
	emit_signal("victory_handled",moves_count,stars,result["new_record"])


func load_stage(stage_id:int):
	_stage_id = stage_id	
	record_moves = score_manager.get_stage_info(stage_id)["moves"]
	
	var stage_data = level_manager.get_stage_data(stage_id)
	max_moves = stage_data["max_moves"]	
	game_board.start_from_matrix(stage_data["grid"])

func restart():
	load_stage(_stage_id)
