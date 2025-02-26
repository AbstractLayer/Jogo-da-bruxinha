extends CharacterBody2D
class_name Player

@export_category("Nodes")
# Colocando os nodes no script.
@export var cajado: Node2D = null
@export var hurtbox_collision: CollisionShape2D = null
@export var sprite_anime: AnimatedSprite2D = null
@export var vfx_shader: AnimationPlayer = null
@export var is_dashing_timer: Timer = null
@export var is_dashing_cooldown_timer: Timer = null
@export var is_knockback_timer: Timer = null

@export_category("Velocity")
# Determina a velocidade inicial da bruxinha.
@export var speed: float = 75
@export var acceleration: float = 0.2
@export var friction: float = 0.2

# Enum para fazer um state_machine que se basea em dividir cada tarefa que ela
# fizer para maior escalabilidade de codigo.
enum player_states{
	IDLE,
	WALK,
	DASH,
	KNOCKBACK,
	DEATH
}

signal health_changed()
signal player_death()
var current_health: int = 5
var is_death: bool = false

# Booleanos para o Dash
var is_dashing: bool = false
var is_dashing_cooldown: bool = false

# Current_state = Situação atual do personagem
# Direction_played = Direção que esta sendo iniciada
# Direction = Direção do personagem
# MousePos = Direção do Mouse em get_local_mouse_position
var current_state = player_states.IDLE
var direction_played = "Down"
var direction: Vector2
var mousePos: Vector2

# KnockBack
var knockback_vector: Vector2
var knockback_impact: Vector2
var is_knockback: bool = false

# Função para fazer tudo funcionar(physics_process).
# Primeiro a movimentação do cajado antes da movimentação, puxando os argumentos
# para fazer a movimentação do mouse funcione.
# Logo após, vem um match(case em outras linguagens) para determina qual state
# devera ser iniciado determinado pelas suas ações.
# Depois disso tudo, o move_and_slide para funciona todo o calculo da movimentação.
func _physics_process(_delta: float) -> void:
	cajado.move_aim(get_aim_direction(), get_mouse_position())
	match current_state:
		player_states.IDLE:
			_idle()
		player_states.WALK:
			_move()
		player_states.DASH:
			_dash()
		player_states.KNOCKBACK:
			_knockback()
		player_states.DEATH:
			_death()
	
	print(current_state)
	
	if current_health < 0 and not is_death:
		is_death = true
		current_state = player_states.DEATH
	
	move_and_slide()
	
# Função para a movimentação completa do personagem.
func _move() -> void:
	# Função move_direction e para modificar toda vez que a _move for chamada
	# ela muda os parametros determinados pela função.
	move_direction()
	
	# Detectar se o ESPAÇO esta sendo para fazer o dash.
	# Se isso ocorrer, muda para o estado de DASH.
	if Input.is_action_pressed("dash") and not is_dashing_cooldown:
		current_state = player_states.DASH
	
	# Esse if funciona da seguinte forma: .dot é para fazer a conversão entre
	# 0 graus = -1, 90 graus = 0, 180 graus = 1
	# sign converte o Vector2 do MousePos(transforma qualquer float em -1,0,1
	# dependendo se o valor é negativo,positivo ou zero) para comparar com o dot
	# quando a direção do teclado e do mouse são iguais roda o if, se não,
	# roda o else pois são diferentes.
	if sign(mousePos.dot(direction)) >= 1:
		if direction != Vector2.ZERO:
			animate_detection()
			sprite_anime.play("Walk" + direction_played)
			speed = 65
	elif direction != Vector2.ZERO:
		animate_detection()
		sprite_anime.play("Walk_Reversed" + direction_played)
		speed = 55
	else:
		current_state = player_states.IDLE
	
	# E no final de tudo, movimentar o personagem baseado na aceleração e speed
	# juntamente com um lerp para dar uma polida na movimentação.
	if direction != Vector2.ZERO:
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration)
		velocity.y = lerp(velocity.y, direction.y * speed, acceleration)

func _idle() -> void:
	# esse if no caso se a direção for diferente de zero, se nao for
	# roda o else que faz o personagem fica parado.
	if move_direction() != Vector2.ZERO:
		current_state = player_states.WALK
	else:
		animate_detection()
		sprite_anime.play("Idle" + direction_played)
		
		velocity.x = lerp(velocity.x, direction.x * speed, friction)
		velocity.y = lerp(velocity.y, direction.y * speed, friction)
	
func _dash() -> void:
	# Essa e a função de dash, que nada mais é que se o ESPAÇO for pressionado
	# E o is_dashing_cooldown for falso ele ativa, desencadeando na animação
	# ser tocada, iniciando 2 timers, 1 para saber ate quando vai o dash
	# e o outro para o botao nao ser pressionado milhares de vezes
	# aumentando seu speed, e movimentando o personagem baseado nisso.
	# quando acaba o timer e ir para as funções time_out o dash acaba.
	if Input.is_action_pressed("dash") and not is_dashing_cooldown and not is_dashing:
		if sign(mousePos.dot(direction)) >= 1:
			if direction != Vector2.ZERO:
				animate_detection()
				sprite_anime.play("Dash" + direction_played)
				speed = 150
		elif direction != Vector2.ZERO:
			animate_detection()
			sprite_anime.play("Dash_Reversed" + direction_played)
			speed = 125
		hurtbox_collision.disabled = true
		is_dashing_timer.start()
		is_dashing_cooldown_timer.start()
		is_dashing_cooldown = true
		is_dashing = true
		velocity = direction * speed

func _knockback() -> void:
	if current_state == player_states.KNOCKBACK and not is_knockback:
		is_knockback_timer.start()
		is_knockback = true
		vfx_shader.play("Hit")
		var knockback_strength = 80.0
		velocity = knockback_impact.normalized() * knockback_strength

func _death() -> void:
	animate_detection()
	sprite_anime.play("Death" + direction_played)
	set_physics_process(false)
	
# Funções para deixa as variaveis em escopo global.
func move_direction() -> Vector2:
	direction = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	).normalized()
	return direction

func mouse_pos() -> Vector2:
	mousePos = get_local_mouse_position().normalized()
	return mousePos

# Funções para auxiliar a movimentação do cajado.
func get_aim_direction() -> Vector2:
	return global_position.direction_to(get_global_mouse_position())

func get_mouse_position() -> Vector2:
	return get_global_mouse_position()

# Função para detectar qual animação devera ser tocada baseado na posição do mouse
# Dando sensibilidade baseando se em 0.75 do valor.
func animate_detection() -> void:
	if mouse_pos().x < -0.75:
			sprite_anime.flip_h = true
			direction_played = "Left" 
	elif mouse_pos().x > 0.75:
			sprite_anime.flip_h = false
			direction_played = "Right"
	elif mouse_pos().y < -0.75: 
			sprite_anime.flip_h = false
			direction_played = "Up"
	elif mouse_pos().y > 0.75:
			sprite_anime.flip_h = false
			direction_played = "Down"

func player_taked_damage() -> void:
	print(current_health)
	current_health -= 1
	emit_signal("health_changed")

# Funções time_out para quando um dos timer acaba, sendo um para parar o dash
# e volta para a posição padrão, e outro para não spamar o botão de dash.
func _on_is_dashing_timer_timeout():
	hurtbox_collision.disabled = false
	is_dashing = false
	current_state = player_states.IDLE

func _on_is_dashing_cooldown_timeout():
	is_dashing_cooldown = false

func _on_hurt_box_area_entered(area):
	if area.is_in_group("feioso"):
		player_taked_damage()
		
		knockback_impact = (area.global_position - global_position) * -1.0
		current_state = player_states.KNOCKBACK

	if area.is_in_group("bruxento"):
		player_taked_damage()
		
		knockback_impact = (area.global_position - global_position) * -1.0
		current_state = player_states.KNOCKBACK
	
func _is_knockback_timeout():
	is_knockback = false
	current_state = player_states.IDLE

func _on_sprite_animate_animation_finished():
	if sprite_anime.animation == "Death" + direction_played:
		emit_signal("player_death")
		visible = false
