extends ColorRect
@onready var moves_label = $PanelContainer/VBoxContainer/MovesLabel
@onready var star_buttons = [$PanelContainer/VBoxContainer/Stars/Star1,$PanelContainer/VBoxContainer/Stars/Star2,$PanelContainer/VBoxContainer/Stars/Star3]
@onready var recod_label = $PanelContainer/VBoxContainer/RecordLabel

func update_ui(moves_count:int,stars:int,new_record:bool):	
	moves_label.text = "Você venceu em %d movimentos!" % moves_count
	_set_stars(stars)
	recod_label.visible = new_record
	
func _set_stars(stars:int):
	for i in range(star_buttons.size()):
		star_buttons[i].disabled = !stars>i
