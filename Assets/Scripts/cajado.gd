extends Node2D
class_name PlayerCajado

const PARTICLE: PackedScene = preload("res://Assets/Scenes/player_particle.tscn")

# Importando os nodes para auxiliar a movimentação e animação do cajado.
@export_category("Nodes")
@export var cajado_node: Node2D = null
@export var cajado_sprite: Sprite2D = null
@export var spawn_particle_position: Node2D = null
@export var is_shooting_timer: Timer = null

var is_shooting: bool = false

func move_aim(attack_direction: Vector2, direction: Vector2) -> void:
	# esse if é para se caso for para esquerda ele rotacionar verticalmente o cajado
	# se não for esquerda, não rotaciona na direita.
	if attack_direction.x < 0:
		cajado_sprite.flip_v = true
	if attack_direction.x > 0:
		cajado_sprite.flip_v = false
	
	# esse if é para mudar a posição do cajado baseado onde o mouse esta sendo
	# direcionado, fazendo uma pespectiva melhor.
	if attack_direction.x < -0.75:
		cajado_node.position = Vector2(4,0)
	elif attack_direction.x > 0.75:
		cajado_node.position = Vector2(-4,0)
	elif attack_direction.y < -0.75: 
		cajado_node.position = Vector2(0,0)
	elif attack_direction.y > 0.75:
		cajado_node.position = Vector2(0,0)
	# look_at para fazer o cajado olhar para onde a direção do mouse esta.
	look_at(direction)
	
func _physics_process(_delta):
	if Input.is_action_pressed("fire") and not is_shooting:
		is_shooting = true
		is_shooting_timer.start()
		spawn_particle()
		

func spawn_particle():
	var particle = PARTICLE.instantiate()
	particle.global_position = spawn_particle_position.global_position
	get_tree().root.call_deferred("add_child", particle)
	

func is_shooting_timeout():
	is_shooting = false
