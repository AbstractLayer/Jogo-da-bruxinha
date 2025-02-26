extends CharacterBody2D
class_name Bruxento

@export var bruxento_cajado: Node2D = null
@export var ray_cast: RayCast2D = null
@export var sprite_anime: AnimatedSprite2D = null
@export var vfx_shader: AnimationPlayer = null
@export var is_shooting_timer: Timer = null
@export var is_knockback_timer: Timer = null
@onready var main_scene = get_tree().get_root()
@onready var altar_node = main_scene.get_node("Level_1/TileMap_Base/Altar")
@onready var player_node = main_scene.get_node("Level_1/TileMap_Base/Player")
@onready var player_position: Vector2
var distance_to_altar: float

enum enemy_state{
	MOVE,
	SHOOTING_TOWER,
	SHOOTING_PLAYER,
	KNOCKBACK,
	DEATH
}
var current_state = enemy_state.MOVE

var enemy_life: int = 0

var attack_direction: Vector2
var direction: Vector2
var move_direction: Vector2
var startPosition: Vector2 = global_position
var endPosition: Vector2 = Vector2(370,250)

var knockback_impact: Vector2
var is_knockback: bool = false

var speed: float = 12.5
var friction: float = 0.2

var is_shooting: bool = false

func _ready():
	vfx_shader.play("Spawn")
	set_physics_process(false)
	await get_tree().create_timer(3).timeout
	set_physics_process(true)

func _physics_process(delta):
	player_position = player_node.position
	attack_direction = (player_position - global_position).normalized()
	distance_to_altar = global_position.distance_to(altar_node.global_position)
	ray_cast.target_position = attack_direction * 100
	
	match current_state:
		enemy_state.MOVE:
			_move()
		enemy_state.SHOOTING_TOWER:
			_shooting_tower()
		enemy_state.SHOOTING_PLAYER:
			_shooting_player()
		enemy_state.KNOCKBACK:
			_knockback()
		enemy_state.DEATH:
			_death()
	if ray_cast.is_colliding():
		bruxento_cajado.aim_player(global_position.direction_to(player_position), player_position)
	else:
		bruxento_cajado.aim_shield(global_position.direction_to(endPosition), altar_node.global_position)
	
	if ray_cast.is_colliding():
		current_state = enemy_state.SHOOTING_PLAYER
	elif distance_to_altar < 70:
		current_state = enemy_state.SHOOTING_TOWER
	elif is_knockback == true:
		current_state = enemy_state.KNOCKBACK
	else:
		current_state = enemy_state.MOVE
	move_and_slide()
	
func _move() -> void:
	move_direction = Vector2(endPosition - global_position)
	animation_manipulate("Walk")
	
	velocity = move_direction.normalized() * speed
	
func _shooting_tower() -> void:
	animation_manipulate("Idle")
	
	velocity.x = lerp(velocity.x, direction.normalized().x * speed, friction)
	velocity.y = lerp(velocity.y, direction.normalized().y * speed, friction)
	
	if not is_shooting:
		is_shooting_timer.start()
		is_shooting = true
		bruxento_cajado.spawn_particle(endPosition)
	
func _shooting_player() -> void:
	animation_manipulate("Idle")
	
	velocity.x = lerp(velocity.x, direction.normalized().x * speed, friction)
	velocity.y = lerp(velocity.y, direction.normalized().y * speed, friction)
	
	if ray_cast.is_colliding() and not is_shooting:
		is_shooting_timer.start()
		is_shooting = true
		bruxento_cajado.spawn_particle(player_position)

func _knockback() -> void:
	if current_state == enemy_state.KNOCKBACK:
		vfx_shader.play("Hit")
		var knockback_strength = 40.0
		velocity = knockback_impact.normalized() * knockback_strength

func _death() -> void:
	set_physics_process(false)
	Global.enemy_deaths += 1
	Global.enemy_remain -= 1
	print(Global.enemy_remain)
	animation_manipulate("Idle")
	vfx_shader.play("Death")

func animation_manipulate(anime_player) -> void:
	if global_position.x > 370:
		sprite_anime.flip_h = true
		sprite_anime.play(anime_player + "Right")
	elif global_position.x < 370:
		sprite_anime.flip_h = false
		sprite_anime.play(anime_player + "Left")

func _on_is_shooting_timeout():
	is_shooting = false

func _on_hit_box_area_entered(area):
	if area.is_in_group("shoot"):
		if enemy_life == 2:
			current_state = enemy_state.DEATH
		else:
			knockback_impact = (area.global_position - global_position).normalized() * -1.0
			current_state = enemy_state.KNOCKBACK
			is_knockback = true
			is_knockback_timer.start()
			enemy_life += 1

func _on_is_knockback_timeout():
	is_knockback = false

func _on_effects_animation_finished(anim_name):
	if anim_name == "Death":
		queue_free()
