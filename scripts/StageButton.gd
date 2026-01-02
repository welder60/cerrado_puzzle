extends Control

@export var stage_id:int = 0
@export var score:int = 0

@onready var stage_button = $Control/StageButton
@onready var stars_container:Container = $Stars
@onready var stars = [$Stars/Star1,$Stars/Star2,$Stars/Star3]
@onready var label:Label = $Control/Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = str(stage_id)
	enable(false)
		
func set_stars(n_stars:int):	
	for i in range(n_stars):
		stars[i].disabled = false

func enable(enabled:bool):
	stage_button.disabled = !enabled
	label.visible = enabled
	stars_container.visible = enabled
