class_name GameOverUI
extends CanvasLayer

@onready var time_label = %TimeLabel
@onready var monsters_label = %MonstersLabel

@export var restart_delay:float = 5.0
var restart_cooldown: float

func _ready() -> void:
	time_label.text = GameManager.time_elapsed_string
	monsters_label.text = str(GameManager.monsters_defeated_counter)
	restart_cooldown = restart_delay

func _process(delta) -> void:
	restart_cooldown -= delta
	if restart_cooldown <= 0.0:
		restart_game()

func restart_game():
	print("Reiniciando Jogo")
	GameManager.reset()	
	get_tree().reload_current_scene()
