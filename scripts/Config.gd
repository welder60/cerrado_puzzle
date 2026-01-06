# SettingsManager.gd
extends Node

@export var sfx_on_icon:Texture
@export var sfx_off_icon:Texture

@export var confirmation:PanelContainer

@onready var sfx_button = $MarginContainer/VBoxContainer/VBoxContainer/EfeitosSonoros
@onready var erase_data_button = $MarginContainer/VBoxContainer/VBoxContainer/EraseData

@onready var score_manager = ScoreManager.new()

# Caminho para salvar apenas as preferências (separado do progresso)
const SETTINGS_PATH = "user://settings.save"

# Variáveis de estado
var sound_enabled: bool = true

func _ready():
	load_settings()
	apply_sound_settings()
	sfx_button.pressed.connect(func():set_sound_enabled(!sound_enabled))
	erase_data_button.pressed.connect(confirm_data_erase)
	update_sfx_button()

# Função chamada pelo botão da UI
func set_sound_enabled(enabled: bool):
	sound_enabled = enabled
	apply_sound_settings()
	save_settings()
	update_sfx_button()
	
func update_sfx_button():
	if sound_enabled:
		sfx_button.icon = sfx_on_icon
	else:
		sfx_button.icon = sfx_off_icon

# Aplica a configuração atual no servidor de áudio do Godot
func apply_sound_settings():
	# Pega o índice do canal "Master" (o principal)
	var master_bus_index = AudioServer.get_bus_index("Master")
	# Muta ou desmuta com base na variável (not sound_enabled porque true = sem mudo)
	AudioServer.set_bus_mute(master_bus_index, not sound_enabled)

func save_settings():
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		# Salvamos um dicionário simples
		file.store_var({"sound": sound_enabled})
		file.close()

func load_settings():
	if not FileAccess.file_exists(SETTINGS_PATH):
		sound_enabled = true # Padrão se não houver arquivo
		return

	var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file:
		var data = file.get_var()
		file.close()
		if data is Dictionary and data.has("sound"):
			sound_enabled = data["sound"]
			
func confirm_data_erase():
	confirmation.message_text = "Os dados salvos do jogo serão apagador. Deseja continuar?"
	confirmation.confirm_text = "Excluir dados"
	confirmation.dismiss_text = "Cancelar"
	confirmation.reset_signal()
	confirmation.confirm_button.pressed.connect(erase_data)
	confirmation.confirm_button.pressed.connect(func():confirmation.hide())
	confirmation.show()
	
func erase_data():
	score_manager.clear_data()
