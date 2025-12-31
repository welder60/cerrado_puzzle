extends Control

signal stage_selected(stage_id:int)

@export var stages_container:Container
@export var stage_scene:PackedScene

@onready var level_manager = LevelManager.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	for stage in level_manager.load_stages_data():
		stages_container.add_child(create_stage(stage["id"]))
		
func create_stage(id:int) -> Control:
	var stage = stage_scene.instantiate()
	stage.stage_id = id
	stage.get_node("Control/StageButton").pressed.connect(func():emit_signal("stage_selected",id))
	return stage
