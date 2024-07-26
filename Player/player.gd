class_name Player
extends CharacterBody2D

@export_category("Movement")
@export var speed: float = 1
@export_category("Sword")
@export var sword_damage: int = 2
@export_category("Ritual")
@export var ritual_damage: int = 1
@export var ritual_interval: float = 30
@export var ritual_scene: PackedScene
@export_category("Life")
@export var health: int = 100
@export var death_prefab: PackedScene
@export var max_health: int = 100

@onready var animation_player: AnimationPlayer = $AnimationPlayer 
@onready var sprite: Sprite2D = $sprite
@onready var sword_area: Area2D = $SwordArea
@onready var hitbox_area: Area2D = $HitboxArea
@onready var health_progress_bar: ProgressBar = $HealthProgressBar

var input_vector: Vector2 = Vector2(0, 0)
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false 
var attack_cooldown: float = 0.0
var hitbox_cooldown: float = 0.0
var ritual_cooldown: float = 0.0

signal meat_collected(value: int)

func _ready()->void:
	GameManager.player = self
	meat_collected.connect(func(value: int): GameManager.meat_counter += 1)

func _process(delta: float)-> void:
	GameManager.player_position = position
	# ler input
	read_input()
	# processar ataque
	update_attack_cooldown(delta)
	if Input.is_action_just_pressed("attack"):
		attack()	
	# tocar animação idle e controle de run 
	play_idle_animation()
	# rotacionar sprite
	if not is_attacking:
		rotate_sprite()	
	
	# Processar dano
	update_hitbox_detection(delta)
	
	# Ritual
	update_ritual(delta)
	
	# Atualizar HealthBar
	health_progress_bar.max_value = max_health
	health_progress_bar.value = health

#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("move_left"):
		#if is_running:
			#animation_player.play("idle")
			#is_running = false
		#else:
			#animation_player.play("run")
			#is_running = true

func _physics_process(delta: float) -> void:
	# Modificar a velocidade
	var target_velocity = input_vector * speed  * 100.0
	if is_attacking:
		velocity *= 0.4
	velocity = lerp(velocity, target_velocity, 0.05)
	
	move_and_slide()
	
func update_attack_cooldown(delta: float)->void:
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			is_attacking = false
			is_running = false
			animation_player.play("idle")
	
func read_input() -> void:	
		# obter o input vector
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if abs(input_vector.x) < 0.15:
		input_vector.x = 0.0
	if abs(input_vector.y) < 0.15:
		input_vector.y = 0.0
		
	# atualizar o is running
	was_running = is_running
	is_running = not input_vector.is_zero_approx() 

func play_idle_animation() -> void:
			# tocar animação
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")
	
func rotate_sprite() -> void:
		# girar sprite conforme 
	if input_vector.x > 0:
		# desmarcar flip h no sprite2d
		sprite.flip_h = false
	elif input_vector.x < 0:
		# marcar flip h no sprite2d
		sprite.flip_h = true
		
func attack() -> void:
	if is_attacking:
		return  
	#tocar animação
	animation_player.play("attack_side_1")
	# configurar temporizados
	attack_cooldown = 0.6
	# marcar ataque
	is_attacking = true;
	
func deal_damage_to_enemies() -> void:
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction: Vector2
			
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			var dot_product = direction_to_enemy.dot(attack_direction)
			
			if dot_product >= 0.3:
				enemy.damage(sword_damage)

func update_hitbox_detection(delta: float) -> void:
	# Temporizador
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0: return
	
	# Frequencia (2x por segundo)
	hitbox_cooldown = 0.5
	# HitboxArea
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var damage_amount = 3
			damage(damage_amount)
				
func damage(amount: int) -> void:
	if health <= 0:
		return
	health -= amount
	# print("inimigo recebeu dano de : ", amount,"A vida total é de: ", health)
	# piscar node
	modulate = Color.CRIMSON
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	if health <= 0:
		die()

func die() -> void:
	GameManager.end_game()
	if death_prefab:
		var death_object = death_prefab.instantiate()
		get_parent().add_child(death_object)
		death_object.position = position
	
	queue_free()

func heal(amount: int) -> int:
	health += amount
	if health > max_health:
		health = max_health
	print("Player recebeu cura de ", amount, " A vida total é de: ",health,"/",max_health)
	return health

func update_ritual(delta: float) -> void:
	ritual_cooldown -= delta
	if ritual_cooldown > 0: return
	
	# resetar temporizados
	ritual_cooldown = ritual_interval
	
	# Criar o ritual
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual)
