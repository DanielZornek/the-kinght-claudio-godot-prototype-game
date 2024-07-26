class_name MobSpawner
extends Node2D

@export var creatures: Array[PackedScene]
var mobs_per_minute: int = 30
@onready var path_follow_2d: PathFollow2D = %PathFollow2D
var cooldown: float = 0

func _process(delta: float) -> void:
	if GameManager.is_game_over: return
	# Temporizador (cooldown)
	cooldown -= delta
	if cooldown > 0: return
	# Frequencia = monstros por minuto
	# 6o monstros = cada 1 segundo um monstro
	# 60 / 60 = 1
	# 120 / 60 = 0.5 2 monstros por segundo
	# Interval = 60 / mobs per minute
	var interval = 60.0 / mobs_per_minute
	cooldown = interval
	# instanciar criatura aleatória
	var index = randf_range(0, creatures.size())
	# Pegar critura aleatória
	var creature_scene = creatures[index]	
	# Pegar ponto aleatório
	# Instanciar cena
	var creature = creature_scene.instantiate()
	# COlocar na posição
	
	# Checar se o ponto é válido
	var point = get_point()	
	# Perguntar pro jogo se esse ponto tem colisão
	var world_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = point
	parameters.collision_mask = 0b1001
	var result: Array = world_state.intersect_point(parameters, 1)
	if not result.is_empty(): return
	#Definir o parent
	creature.position = point
	get_parent().add_child(creature)
	
func get_point() -> Vector2:
	path_follow_2d.progress_ratio = randf()
	return path_follow_2d.position
