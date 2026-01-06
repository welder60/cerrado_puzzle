extends Control

# Arraste a sua cena principal (o jogo) para cá no Inspetor
@export var next_scene: PackedScene 

func _ready():
	# Inicia a animação
	$AnimationPlayer.play("splash_animation")
	
	# Conecta o sinal de término da animação para mudar de cena
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(_anim_name):
	# Muda para a cena do menu principal ou do jogo
	get_tree().change_scene_to_packed(next_scene)
