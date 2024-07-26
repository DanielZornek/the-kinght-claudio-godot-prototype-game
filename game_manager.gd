extends Node
# esse script é como um satélite, ele pode pegar valores e compartilhar com 
# outros scripts

signal game_over

var player_position: Vector2
var player: Player
var is_game_over: bool = false

var time_elapsed: float = 0.0
var time_elapsed_string: String
var meat_counter: int = 0
var monsters_defeated_counter: int = 0

func _process(delta: float) -> void:
	time_elapsed += delta
	# floor: arredonda pra baixo
	# floori: vai arredondar pra baixo e retornar um integer
	# então tambem tem o floorf que retorna um float
	# round: depende do número, vai pra baixo ou pra cima
	# ceil: sempre pra cima
	# update timer
	var time_elapsed_in_seconds: int = floori(time_elapsed)
	var seconds: int = time_elapsed_in_seconds % 60
	var minutes: int = time_elapsed_in_seconds / 60
	# 2:59 = 179
	# 3:00 = 180
	time_elapsed_string = "%02d:%02d" % [minutes, seconds]
	# o % significa que queremos formatar algo
	# o d significa que é um digito um numero inteiro
	# e 02 significa que teremos apenas 2 digitos, e os que não conseguir copular vai ser 0

func end_game():
	if is_game_over: return
	is_game_over = true
	game_over.emit()

func reset():
	player = null
	player_position = Vector2.ZERO 
	is_game_over = false
	monsters_defeated_counter = 0
	meat_counter = 0
	time_elapsed_string = "00:00"
	time_elapsed = 0.0
	for connection in game_over.get_connections():
		game_over.disconnect(connection.callable)
