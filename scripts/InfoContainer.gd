extends PanelContainer

@onready var tabs_container:TabContainer = $VBoxContainer/TabContainer
@onready var previous_button = $VBoxContainer/TabsControl/Anterior
@onready var next_button = $VBoxContainer/TabsControl/Proximo
@onready var begin_button = $VBoxContainer/TabsControl/Inicio
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	previous_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)
	begin_button.pressed.connect(inicio)
	check_tab_controls()
	visibility_changed.connect(inicio)

func inicio():
	tabs_container.current_tab=0
	check_tab_controls()

func check_tab_controls():
	begin_button.visible =  tabs_container.current_tab >= tabs_container.get_tab_count() - 1
	if tabs_container.get_tab_count()>1:
		next_button.visible = tabs_container.current_tab < tabs_container.get_tab_count() - 1
		previous_button.visible = tabs_container.current_tab > 0
	else:
		next_button.hide()
		previous_button.hide()

func _on_next_pressed():
	# Verifica se ainda não é a última aba
	if tabs_container.current_tab < tabs_container.get_tab_count() - 1:
		tabs_container.current_tab += 1
	check_tab_controls()

func _on_prev_pressed():
	if tabs_container.current_tab > 0:
		tabs_container.current_tab -= 1
	check_tab_controls()
