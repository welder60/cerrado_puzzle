extends Control

signal stage_selected(stage_id:int)

@export var stages_container:Container
@export var stage_scene:PackedScene

@onready var level_manager = LevelManager.new()
@onready var score_manager = ScoreManager.new()

@onready var stages:Array[Control] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	for stage_data in level_manager.load_stages_data():
		var stage:Control = create_stage(stage_data["id"])
		stages_container.add_child(stage)
		stages.append(stage)
	
	update_stages()
	visibility_changed.connect(update_stages)
	
func update_stages():
	score_manager.load_data()
	stages[0].enable(true)
	for stage in stages:
		var stage_score = score_manager.get_stage_info(stage.stage_id)
		if stage_score["moves"]>0:
			stages[stage.stage_id].enable(true)
			stage.set_stars(stage_score["stars"])
func create_stage(id:int) -> Control:
	var stage = stage_scene.instantiate()
	stage.stage_id = id
	stage.get_node("Control/StageButton").pressed.connect(func():emit_signal("stage_selected",id))
	return stage
