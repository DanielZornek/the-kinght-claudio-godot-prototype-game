extends Node

#@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var enemy: Enemy
var sprite: AnimatedSprite2D

@export var speed: float

func _ready():
	enemy = get_parent()
	sprite = enemy.get_node("AnimatedSprite2D")
	speed = enemy.speed
	#tem que ser o nome

func _physics_process(delta: float) -> void:
	if GameManager.is_game_over: return
	
	var player_position = GameManager.player_position
	var difference =  player_position - enemy.position 
	var input_vector = difference.normalized()
	enemy.velocity = input_vector * speed * 100.0
	
	enemy.move_and_slide()
	
		# girar sprite conforme 
	if input_vector.x > 0:
	# desmarcar flip h no sprite2d
		sprite.flip_h = false
	elif input_vector.x < 0:
	# marcar flip h no sprite2d
		sprite.flip_h = true
