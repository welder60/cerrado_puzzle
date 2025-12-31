# Main.gd
# Script principal que orquestra o jogo, conectando UI, GameBoard e ScoreManager.

extends Node

# Referências aos nós principais
@onready var game_board = $GameBoard
@onready var score_manager = $ScoreManager
@onready var ui_manager = $UIManager

func _ready():
	# Conecta os sinais do UIManager
	ui_manager.play_button_pressed.connect(_on_play_button_pressed)
	ui_manager.reset_button_pressed.connect(_on_reset_button_pressed)
	ui_manager.menu_button_pressed.connect(_on_menu_button_pressed)
	ui_manager.rotate_row_pressed.connect(_on_rotate_row)
	ui_manager.rotate_col_pressed.connect(_on_rotate_col)
	
	# Conecta os sinais do GameBoard
	game_board.moves_updated.connect(ui_manager.update_moves)
	game_board.game_won.connect(_on_game_won)
	
	# Carrega o highscore e atualiza a UI
	var highscore = score_manager.load_highscore()
	ui_manager.update_highscore(highscore)
	
	# Esconde o tabuleiro inicialmente
	game_board.hide()

func _on_play_button_pressed():
	ui_manager.show_game_ui()
	game_board.show()
	game_board.initialize_board()

func _on_reset_button_pressed():
	game_board.initialize_board()
	ui_manager.show_game_ui()
	ui_manager.victory_screen.hide()

func _on_menu_button_pressed():
	ui_manager.show_main_menu()
	game_board.hide()

func _on_rotate_row(row_index: int, direction: int):
	game_board.rotate_row(row_index, direction)

func _on_rotate_col(col_index: int, direction: int):
	game_board.rotate_column(col_index, direction)

func _on_game_won():
	var moves = game_board.move_count
	var score = score_manager.calculate_score(moves)
	var is_new_highscore = score_manager.save_highscore(score)
	
	ui_manager.set_victory_details(moves, score, is_new_highscore)
	ui_manager.show_victory_screen()
	
	if is_new_highscore:
		ui_manager.update_highscore(score)
