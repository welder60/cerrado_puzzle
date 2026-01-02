# Card.gd
extends Control

# Avisa o tabuleiro: (direção, x_ou_y_do_card)
signal swipe_detected(direction: Vector2, grid_pos: Vector2i)

var grid_pos: Vector2i # Posição lógica dele (setada pelo GameBoard)
var touch_start_pos: Vector2
var is_dragging := false
var threshold := 40.0 # Sensibilidade do arraste

# --- Componentes ---
@onready var textura_rect = $IconeCard
@onready var fundo:Panel = $ColorRect

@onready var borda_selecao = $BordaSelecao
@onready var fundo_match = $FundoMatch

var card_id: int = -1

var cores: Array[Color] = [
	Color("a9a3afff"),
	Color("EC6F60"),
	Color("CFA16C"),
	Color("f29f48"),
	Color("88a97a"),
	Color("f4b553"),
	]

func _ready() -> void:
	
	var style = fundo.get_theme_stylebox("panel").duplicate()
	if style is StyleBoxFlat:
		style.bg_color = cores.pick_random()
		fundo.add_theme_stylebox_override("panel", style)
	

func _gui_input(event: InputEvent):
	# Aceita tanto clique de mouse quanto toque na tela
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.pressed:
			touch_start_pos = event.position
			is_dragging = true
			
				
	if is_dragging:
		if _check_swipe(event.position):
			is_dragging = false			
	borda_selecao.visible = is_dragging

func _check_swipe(end_pos: Vector2) -> bool:
	var diff = end_pos - touch_start_pos
	if diff.length() < threshold: 
		return false
	
	var dir := Vector2.ZERO
	# Determina se o movimento foi mais horizontal ou vertical
	if abs(diff.x) > abs(diff.y):
		dir = Vector2(sign(diff.x), 0) # Esquerda (-1, 0) ou Direita (1, 0)
	else:
		dir = Vector2(0, sign(diff.y)) # Cima (0, -1) ou Baixo (0, 1)
		
	swipe_detected.emit(dir, grid_pos)
	return true



func match(matched:bool) -> void:
	fundo_match.visible = matched

func setup(id: int, size_px: int, pos: Vector2i):
	self.grid_pos = pos
	# Aqui você configuraria a textura/cor do card baseado no ID
	card_id = id
	custom_minimum_size = Vector2(size_px, size_px)
	size = custom_minimum_size
	
	var texture_path = "res://assets/images/image_%d.png" % id
	var loaded_texture = load(texture_path)
	if loaded_texture:
		textura_rect.texture = loaded_texture
		await get_tree().process_frame
	else:
		push_error("Não foi possível carregar a textura: " + texture_path)
		
