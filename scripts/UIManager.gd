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
@onready var about_container = $About
@onready var htp_container = $HowToPlay
@onready var config_container = $Config
@onready var confirmation = $Confirmation

@onready var scenes:Array[Control] = [main_menu,game_ui,victory_screen,game_stages,about_container,htp_container,config_container,confirmation]

@onready var victory_moves_label = $VictoryScreen/PanelContainer/VBoxContainer/MovesLabel
@onready var new_highscore_label = $VictoryScreen/PanelContainer/VBoxContainer/HighscoreMessage

# Chamado quando o nó entra na árvore da cena.
func _ready():
	# Conecta os sinais dos botões a este script
	# Menu Principal
	main_menu.get_node("VBoxContainer/CenterContainer/FirstMenu/Buttons/PlayButton").pressed.connect(_on_PlayButton_pressed)
	main_menu.get_node("VBoxContainer/CenterContainer/FirstMenu/Buttons/AboutButton").pressed.connect(show_about)
	main_menu.get_node("VBoxContainer/CenterContainer/FirstMenu/Buttons/HTPButton").pressed.connect(show_htp)
	main_menu.get_node("VBoxContainer/CenterContainer/FirstMenu/Buttons/ConfigButton").pressed.connect(show_config)
		
		# UI do Jogo
	game_ui.get_node("MarginContainer/MarginContainer/HBoxContainer/Buttons/ResetButton").pressed.connect(_on_ResetButton_pressed)
	game_ui.get_node("MarginContainer/MarginContainer/HBoxContainer/Buttons/MenuButton").pressed.connect(quit_game)
	
	game_stages.get_node("Panel/MarginContainer/VBoxContainer/HBoxContainer/MenuButton").pressed.connect(_on_MenuButton_pressed)
	# Tela de Vitória
	victory_screen.get_node("PanelContainer/VBoxContainer/ActionButtons/PlayAgainButton").pressed.connect(_on_PlayAgainButton_pressed)
	victory_screen.get_node("PanelContainer/VBoxContainer/ActionButtons/MenuButton").pressed.connect(_on_MenuButton_pressed)
	victory_screen.get_node("PanelContainer/VBoxContainer/ActionButtons/ContinueButton").pressed.connect(_on_PlayButton_pressed)

	about_container.get_node("MarginContainer/VBoxContainer/HBoxContainer/MenuButton").pressed.connect(_on_MenuButton_pressed)
	htp_container.get_node("MarginContainer/VBoxContainer/HBoxContainer/MenuButton").pressed.connect(_on_MenuButton_pressed)
	config_container.get_node("MarginContainer/VBoxContainer/HBoxContainer/MenuButton").pressed.connect(_on_MenuButton_pressed)
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
	
func show_about():
	hide_all()
	show_scene(about_container)
	
func show_htp():
	hide_all()
	show_scene(htp_container)
	
func show_config():
	hide_all()
	show_scene(config_container)
	
func quit_game():
	confirmation.message_text = "Deseja sair a partida?"
	confirmation.confirm_text = "Sair da partida"
	confirmation.dismiss_text = "Permanecer"
	confirmation.reset_signal()
	confirmation.confirm_button.pressed.connect(_on_PlayButton_pressed)	
	show_confirmation()

# --- Funções de Atualização de Dados ---
func show_confirmation():
	show_scene(confirmation)



func set_victory_details(moves: int, is_new_highscore: bool):
	victory_moves_label.text = "Você venceu em %d movimentos!" % moves
	#victory_score_label.text = "Score: %d" % score
	new_highscore_label.visible = is_new_highscore

# --- Handlers de Sinais dos Botões ---

func _on_PlayButton_pressed():
	emit_signal("play_button_pressed")

func _on_ResetButton_pressed():
	confirmation.message_text = "Reiniciar a partida?"
	confirmation.confirm_text = "Reiniciar"
	confirmation.dismiss_text = "Permanecer"
	confirmation.reset_signal()
	confirmation.confirm_button.pressed.connect(reset_game)	
	show_confirmation()

func reset_game():	
	emit_signal("reset_button_pressed")
	

func _on_MenuButton_pressed():
	emit_signal("menu_button_pressed")

func _on_PlayAgainButton_pressed():
	# Funciona como o botão de reset
	emit_signal("reset_button_pressed")
