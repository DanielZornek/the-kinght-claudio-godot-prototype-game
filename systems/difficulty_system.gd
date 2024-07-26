extends Node

var time: float = 0.0
@export var mob_spawner: MobSpawner
@export var initial_spawn_rate: float = 30.0
@export var spawn_rate_per_minute: float = 30.0
@export var wave_duration: float = 20
@export var break_intensity:float = 0.5

func _process(delta) -> void:
	# Ignorar Game Over
	if GameManager.is_game_over: return
	
	# Incrementar temporizados
	time += delta
	
	var sin_wave = sin((time * TAU) / wave_duration)
	var wave_factor = remap(sin_wave, -1.0, 1.0, break_intensity, 1)
	# PI = 3.14 	0 ~ 2PI		TAU
	
	var spawn_rate = initial_spawn_rate + spawn_rate_per_minute * (time / 60.0)
	spawn_rate *= wave_factor
		
	mob_spawner.mobs_per_minute = spawn_rate
