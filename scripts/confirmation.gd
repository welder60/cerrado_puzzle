extends PanelContainer

signal on_confirm

@export var message_text:String = "Deseja continuar?"
@export var dismiss_text:String = "Voltar"
@export var confirm_text:String = "Confirmar"

@onready var message_label:Label = $VBoxContainer/Message
@onready var dismiss_button:Button = $VBoxContainer/Buttons/Back
@onready var confirm_button:Button = $VBoxContainer/Buttons/Confirm
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dismiss_button.pressed.connect(hide)
	visibility_changed.connect(ui_refresh)	
	ui_refresh()
	
func ui_refresh():
	message_label.text = message_text
	confirm_button.text = confirm_text
	dismiss_button.text = dismiss_text
	
func reset_signal():
	for connection in confirm_button.pressed.get_connections():
		confirm_button.pressed.disconnect(connection.callable)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
