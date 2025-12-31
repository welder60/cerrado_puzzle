extends PanelContainer # Mudamos para Control para gerenciar a árvore internamente


signal game_won(moves_count: int)
signal moves_updated(moves_count: int)

@export var card_scene: PackedScene
@export var card_padding: int = 10
@export var margin_padding: int = 150

var card_size: int = 0
var rows: int = 0
var cols: int = 0

var grid: Array = []
var card_nodes: Array = []
var slot_nodes: Array = []

var moves_count := 0
var is_playing := false

# Nós da Interface
@export var layout_grid: GridContainer
var overlay: Control
var center_container: CenterContainer

@onready var level_manager = LevelManager.new()

var _stage_id:int

func _ready() -> void:
	_setup_ui_structure()
	# Exemplo de início
	
func load_stage(stage_id:int):
	_stage_id = stage_id
	start_from_matrix(level_manager.get_stage_data(stage_id)["grid"])

func restart():
	load_stage(_stage_id)

func _setup_ui_structure() -> void:
	# Criamos a estrutura que garante a centralização e o overlay
	#set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	center_container = CenterContainer.new()
	#center_container.set_anchors_and_offsets_preset(Control.PRESET_VCENTER_WIDE)
	add_child(center_container)
	
	# Control que agrupa o Grid (fundo) e o Overlay (cards)
	var board_anchor = Control.new()
	board_anchor.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center_container.add_child(board_anchor)
	
	#layout_grid = GridContainer.new()
	layout_grid.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	#board_anchor.add_child(layout_grid)
	
	overlay = Control.new()
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_anchor.add_child(overlay)

func start_from_matrix(matrix: Array) -> void:
	if matrix.is_empty(): return
	rows = matrix.size()
	cols = matrix[0].size()
	
	# --- CÁLCULO DE RESPONSIVIDADE ---
	var screen_size = get_viewport_rect().size
	var available_w = screen_size.x  - margin_padding
	var available_h = screen_size.y  - margin_padding
	
	# Calcula o tamanho que cabe na tela
	var cell_w = floor(available_w / cols)
	var cell_h = floor(available_h / rows)
	card_size = int(min(cell_w, cell_h) - card_padding)
	
	_reset_game()
	_build_board(matrix)
	
	# Aguarda o Godot calcular as posições dos slots antes de colocar os cards
	await get_tree().process_frame
	await get_tree().process_frame
	
	_create_cards()
	is_playing = true

func _reset_game() -> void:
	moves_count = 0
	moves_updated.emit(moves_count)

func _build_board(id_matrix: Array) -> void:
	for c in layout_grid.get_children(): c.queue_free()
	for c in overlay.get_children(): c.queue_free()
	grid.clear()
	card_nodes.clear()
	slot_nodes.clear()
	
	layout_grid.columns = cols
	
	grid.resize(rows)
	slot_nodes.resize(rows)
	card_nodes.resize(rows)
	
	for y in range(rows):
		grid[y] = []
		grid[y].resize(cols)
		slot_nodes[y] = []
		slot_nodes[y].resize(cols)
		card_nodes[y] = []
		card_nodes[y].resize(cols)
		
		for x in range(cols):
			var slot = _make_slot_cell()
			layout_grid.add_child(slot)
			slot_nodes[y][x] = slot
			grid[y][x] = id_matrix[y][x]

func _create_cards() -> void:
	for y in range(rows):
		for x in range(cols):
			var card = card_scene.instantiate()
			overlay.add_child(card)
			
			# Passamos a posição X, Y para o card saber onde ele está
			card.setup(grid[y][x], card_size, Vector2i(x, y))
			
			# Conecta o sinal do card ao tabuleiro
			card.swipe_detected.connect(_on_card_swipe)
			
			card_nodes[y][x] = card
	_snap_cards_to_slots()
	_check_win_condition()
	

func _on_card_swipe(direction: Vector2, pos: Vector2i):
	if not is_playing: return
	
	if direction.x != 0:
		# Swipe horizontal: move a LINHA (Y)
		# Se dir.x for 1, move para direita. Se -1, para esquerda.
		rotate_row(pos.y, int(direction.x))
	elif direction.y != 0:
		# Swipe vertical: move a COLUNA (X)
		rotate_column(pos.x, int(direction.y))

# IMPORTANTE: Após o rotate_row/column e a animação, 
# precisamos atualizar o grid_pos interno de cada card!
func _update_card_grid_positions():
	for y in range(rows):
		for x in range(cols):
			card_nodes[y][x].grid_pos = Vector2i(x, y)

func _make_slot_cell() -> Control:
	var slot:Control = Control.new()
	
	# O slot define o tamanho no GridContainer
	slot.custom_minimum_size = Vector2(card_size + card_padding, card_size + card_padding)
	
	var inner = Control.new()
	inner.name = "Inner"
	inner.set_anchors_and_offsets_preset(Control.PRESET_CENTER) # Centraliza o card no slot
	slot.add_child(inner)
	return slot

func _get_slot_pos(y: int, x: int) -> Vector2:
	var inner = slot_nodes[y][x].get_node("Inner")
	return inner.global_position - Vector2(card_size/2.0, card_size/2.0)

func _snap_cards_to_slots() -> void:
	for y in range(rows):
		for x in range(cols):
			var card = card_nodes[y][x]
			if is_instance_valid(card):
				card.global_position = _get_slot_pos(y, x)

# --- Movimentação ---
func rotate_row(y: int, dir: int) -> void:
	if not is_playing: return
	var row_data = grid[y].duplicate()
	var row_cards = card_nodes[y].duplicate()
	
	if dir > 0:
		row_data.push_front(row_data.pop_back())
		row_cards.push_front(row_cards.pop_back())
	else:
		row_data.push_back(row_data.pop_front())
		row_cards.push_back(row_cards.pop_front())
		
	grid[y] = row_data
	card_nodes[y] = row_cards
	_animate_cards()
	_update_card_grid_positions() # Essencial para o próximo swipe funcionar!
	_post_move_check()
	
func rotate_column(x: int, dir: int) -> void:
	if not is_playing: return
	if x < 0 or x >= cols: return

	# 1. Extraímos os dados da coluna atual em arrays temporários
	var col_data: Array = []
	var col_cards: Array = []
	for y in range(rows):
		col_data.append(grid[y][x])
		col_cards.append(card_nodes[y][x])

	# 2. Rotacionamos os arrays temporários
	# Se dir > 0 (swipe para baixo), o último vai para o topo
	# No Godot, Y cresce para baixo, então dir=1 é para baixo, dir=-1 é para cima
	if dir > 0:
		col_data.push_front(col_data.pop_back())
		col_cards.push_front(col_cards.pop_back())
	else:
		col_data.push_back(col_data.pop_front())
		col_cards.push_back(col_cards.pop_front())

	# 3. Devolvemos os valores rotacionados para a estrutura principal do grid
	for y in range(rows):
		grid[y][x] = col_data[y]
		card_nodes[y][x] = col_cards[y]

	# 4. Atualizamos a visão e a lógica
	_animate_cards()               # Move visualmente os cards para os novos slots
	_update_card_grid_positions()  # Avisa cada card sua nova coordenada X,Y
	_post_move_check()             # Verifica se o jogador venceu

func _animate_cards() -> void:
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC)
	for y in range(rows):
		for x in range(cols):
			tween.tween_property(card_nodes[y][x], "global_position", _get_slot_pos(y, x), 0.2)

func _post_move_check() -> void:
	# 1. Incrementa e avisa a UI sobre o movimento
	moves_count += 1
	moves_updated.emit(moves_count)

	# 2. Verifica se o jogador venceu
	if _check_win_condition():
		is_playing = false
		_handle_victory()

# Regra: Cada carta deve ter pelo menos um vizinho (horizontal ou vertical) com o mesmo ID
func _check_win_condition() -> bool:
	var all_match = true
	for y in range(rows):
		for x in range(cols):
			
			var current_id = grid[y][x]
			var has_match := false
			# Verificar vizinhos (Cima, Baixo, Esquerda, Direita)
			# Usamos um array de direções para limpar o código
			var directions = [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]
			
			for dir in directions:
				var nx = x + dir.x
				var ny = y + dir.y
				
				# Verifica se o vizinho está dentro dos limites do grid
				if nx >= 0 and nx < cols and ny >= 0 and ny < rows:
					if grid[ny][nx] == current_id:
						has_match = true
						#break # Encontrou um par, pode parar de checar este card
			
			card_nodes[y][x].match(has_match)
			
			# Se este card específico não tem nenhum vizinho igual, o jogo ainda não acabou
			if not has_match:
				all_match = false
	return all_match

func _handle_victory() -> void:
	await get_tree().create_timer(0.5).timeout
	game_won.emit(moves_count)
