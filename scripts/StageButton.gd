extends Control

@export var stage_id:int = 0
@export var score:int = 0
@export var enabled:bool = true

@onready var stage_button = $Control/StageButton
@onready var stars_container:Container = $Stars
@onready var stars = [$Stars/Star1,$Stars/Star2,$Stars/Star3]
@onready var label:Label = $Control/Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = str(stage_id)
	stage_button.disabled=!enabled
	label.visible = enabled
	stars_container.visible = enabled
	for i in range(stars.size()):
		stars[i].disabled = !(score > i)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
