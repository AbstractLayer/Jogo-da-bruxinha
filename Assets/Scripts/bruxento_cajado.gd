extends Node2D
class_name BruxentoCajado

const PARTICLE: PackedScene = preload("res://Assets/Scenes/bruxento_particle.tscn")

# Importando os nodes para auxiliar a movimentação e animação do cajado.
@export_category("Nodes")
@export var cajado_sprite: Sprite2D = null
@export var spawn_particle_position: Node2D = null
@export var is_shooting_timer: Timer = null

var is_shooting: bool = false

func aim_shield(shield_attack_aim: Vector2, shield_direction_aim: Vector2) -> void:
	# esse if é para se caso for para esquerda ele rotacionar verticalmente o cajado
	# se não for esquerda, não rotaciona na direita.
	if shield_attack_aim.x < 0:
		cajado_sprite.flip_v = true
	if shield_attack_aim.x > 0:
		cajado_sprite.flip_v = false
	
	# esse if é para mudar a posição do cajado baseado onde o mouse esta sendo
	# direcionado, fazendo uma pespectiva melhor.
	if shield_attack_aim.x < -0.75:
		position = Vector2(0,0)
	elif shield_attack_aim.x > 0.75:
		position = Vector2(0,0)
	elif shield_attack_aim.y < -0.75: 
		position = Vector2(0,-2)
	elif shield_attack_aim.y > 0.75:
		position = Vector2(0,2)
	# look_at para fazer o cajado olhar para onde a direção do mouse esta.
	look_at(shield_direction_aim)

func aim_player(player_attack_aim: Vector2, player_direction_aim: Vector2) -> void:
	# esse if é para se caso for para esquerda ele rotacionar verticalmente o cajado
	# se não for esquerda, não rotaciona na direita.
	if player_attack_aim.x < 0:
		cajado_sprite.flip_v = true
	if player_attack_aim.x > 0:
		cajado_sprite.flip_v = false
	
	# esse if é para mudar a posição do cajado baseado onde o mouse esta sendo
	# direcionado, fazendo uma pespectiva melhor.
	if player_attack_aim.x < -0.75:
		position = Vector2(0,0)
	elif player_attack_aim.x > 0.75:
		position = Vector2(0,0)
	elif player_attack_aim.y < -0.75: 
		position = Vector2(0,-2)
	elif player_attack_aim.y > 0.75:
		position = Vector2(0,2)
	# look_at para fazer o cajado olhar para onde a direção do mouse esta.
	look_at(player_direction_aim)
	

#func _physics_process(_delta):
	#if not is_shooting:
		#is_shooting = true
		#is_shooting_timer.start()
		#spawn_particle()
		

func spawn_particle(aim_direction):
	var particle = PARTICLE.instantiate()
	particle.global_position = spawn_particle_position.global_position
	particle.direction = global_position.direction_to(aim_direction)
	var angle = particle.direction.angle()
	particle.rotation_degrees = rad_to_deg(angle)
	get_tree().root.call_deferred("add_child", particle)
	

#func is_shooting_timeout():
	#is_shooting = false
