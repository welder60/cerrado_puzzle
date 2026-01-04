# Main.gd
# Script principal que orquestra o jogo, conectando UI, GameBoard e ScoreManager.

extends Control



# Referências aos nós principais
@onready var game_ui = $UIManager/GameUI
@onready var game_board = $UIManager/GameUI/GameBoard
@onready var ui_manager = $UIManager
@onready var game_stages = $UIManager/GameStages
@onready var moves_label = $UIManager/GameUI/MarginContainer/MarginContainer/HBoxContainer/Labels/MovesLabel
@onready var high_score_label = $UIManager/GameUI/MarginContainer/MarginContainer/HBoxContainer/Labels/HScoreLabel

func _ready():
	# Conecta os sinais do UIManager
		
	ui_manager.play_button_pressed.connect(_on_play_button_pressed)
	ui_manager.reset_button_pressed.connect(_on_reset_button_pressed)
	ui_manager.menu_button_pressed.connect(_on_menu_button_pressed)
	
	game_stages.stage_selected.connect(_on_stage_selected)
	
	# Conecta os sinais do GameBoard
#	game_board.moves_updated.connect(ui_manager.update_moves)
	game_board.game_won.connect(_on_game_won)
	game_board.moves_updated.connect(update_moves)
		
	
	# Esconde o tabuleiro inicialmente
	#game_board.hide()
	
	
	#_on_play_button_pressed()

func _on_stage_selected(stage_id:int):
	game_board.load_stage(stage_id)
	ui_manager.show_game_ui()

func _on_play_button_pressed():
	ui_manager.show_stages()
	
	#game_board.show()
	#game_board.initialize_board()

func _on_reset_button_pressed():
	game_board.restart()
	ui_manager.show_game_ui()
	ui_manager.victory_screen.hide()

func _on_menu_button_pressed():
	ui_manager.show_main_menu()
	#game_board.hide()

func _on_rotate_row(row_index: int, direction: int):
	game_board.rotate_row(row_index, direction)

func _on_rotate_col(col_index: int, direction: int):
	game_board.rotate_column(col_index, direction)

func update_moves(moves: int,high_score:int):
	moves_label.text = "Movimentos: %d" % moves
	high_score_label.visible = high_score>0
	high_score_label.text = "Recorde: %d" % high_score

func _on_game_won(moves_count:int):
	var moves = game_board.moves_count
	#var score = score_manager.calculate_score(moves)
	#var is_new_highscore = score_manager.save_highscore(score)
	var is_new_highscore = false
	ui_manager.set_victory_details(moves, is_new_highscore)
	ui_manager.show_victory_screen()
	
#	if is_new_highscore:
#		ui_manager.update_highscore(score)
