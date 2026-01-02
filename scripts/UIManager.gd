# UIManager.gd
# Script central para gerenciar todas as interações e atualizações da UI.

extends MarginContainer

# --- Sinais ---
signal play_button_pressed
signal reset_button_pressed
signal menu_button_pressed

# --- Referências de Nós (preenchidas no editor) ---
@onready var main_menu = $MainMenu
@onready var game_ui = $GameUI
@onready var victory_screen = $VictoryScreen
@onready var game_stages = $GameStages

@onready var scenes:Array[Control] = [main_menu,game_ui,victory_screen,game_stages]

@onready var victory_moves_label = $VictoryScreen/PanelContainer/VBoxContainer/MovesLabel
@onready var new_highscore_label = $VictoryScreen/PanelContainer/VBoxContainer/HighscoreMessage

# Chamado quando o nó entra na árvore da cena.
func _ready():
	# Conecta os sinais dos botões a este script
	# Menu Principal
	main_menu.get_node("VBoxContainer/CenterContainer/FirstMenu/Buttons/PlayButton").pressed.connect(_on_PlayButton_pressed)
		
		# UI do Jogo
	game_ui.get_node("MarginContainer/MarginContainer/HBoxContainer/Buttons/ResetButton").pressed.connect(_on_ResetButton_pressed)
	game_ui.get_node("MarginContainer/MarginContainer/HBoxContainer/Buttons/MenuButton").pressed.connect(_on_MenuButton_pressed)
	
	game_stages.get_node("Panel/VBoxContainer/HBoxContainer/MenuButton").pressed.connect(_on_MenuButton_pressed)
	# Tela de Vitória
	victory_screen.get_node("PanelContainer/VBoxContainer/ActionButtons/PlayAgainButton").pressed.connect(_on_PlayAgainButton_pressed)
	victory_screen.get_node("PanelContainer/VBoxContainer/ActionButtons/MenuButton").pressed.connect(_on_MenuButton_pressed)
	victory_screen.get_node("PanelContainer/VBoxContainer/ActionButtons/ContinueButton").pressed.connect(_on_PlayButton_pressed)

	
	# Estado inicial: mostrar apenas o menu principal
	show_main_menu()

# --- Funções de Visibilidade ---

func hide_all():
	for scene in scenes:
		scene.hide()
	
func show_scene(scene:Control):
	scene.show()
	
func show_stages():	
	hide_all()
	show_scene(game_stages)

func show_main_menu():	
	hide_all()
	show_scene(main_menu)

func show_game_ui():	
	hide_all()
	show_scene(game_ui)

func show_victory_screen():
	show_scene(victory_screen)
	


# --- Funções de Atualização de Dados ---




func set_victory_details(moves: int, is_new_highscore: bool):
	victory_moves_label.text = "Você venceu em %d movimentos!" % moves
	#victory_score_label.text = "Score: %d" % score
	new_highscore_label.visible = is_new_highscore

# --- Handlers de Sinais dos Botões ---

func _on_PlayButton_pressed():
	emit_signal("play_button_pressed")

func _on_ResetButton_pressed():
	emit_signal("reset_button_pressed")

func _on_MenuButton_pressed():
	emit_signal("menu_button_pressed")

func _on_PlayAgainButton_pressed():
	# Funciona como o botão de reset
	emit_signal("reset_button_pressed")
