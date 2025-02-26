extends CharacterBody2D

@export_category("Nodes")
@export var ray_cast: RayCast2D = null
@export var sprite_anime: AnimatedSprite2D = null
@export var vfx_shader: AnimationPlayer = null
@export var on_detection_timer: Timer = null
@export var is_dashing_timer: Timer = null
@export var is_knockback_timer: Timer = null
@onready var main_scene = get_tree().get_root()
@onready var player_node = main_scene.get_node("Level_1/TileMap_Base/Player")
@onready var player_position: Vector2

enum enemy_state{
	MOVE,
	DETECTION,
	DASH,
	KNOCKBACK,
	DEATH
}
var current_state = enemy_state.MOVE

var attack_direction: Vector2
var move_direction: Vector2
var startPosition: Vector2 = global_position
var endPosition: Vector2 = Vector2(370,250)
var enemy_direction: Vector2
var direction: Vector2

var speed: float = 20
var dashing_speed: float = 65
var friction: float = 0.075

var knockback_impact: Vector2
var is_knockback: bool = false

var enemy_life: int = 0

var is_dashing: bool = false
var is_colliding: bool = false
var timer_dash_started: bool = false

func _move():
	move_direction = Vector2(endPosition - global_position)
	if global_position.x > 370:
		sprite_anime.flip_h = false
		sprite_anime.play("WalkLeft")
	elif global_position.x < 370:
		sprite_anime.flip_h = true
		sprite_anime.play("WalkRight")
	
	velocity = move_direction.normalized() * speed
	
func _detection():
	velocity.x = lerp(velocity.x, direction.normalized().x * speed, friction)
	velocity.y = lerp(velocity.y, direction.normalized().y * speed, friction)
	
	if ray_cast.is_colliding() and not timer_dash_started:
		if attack_direction.x > 0:
			sprite_anime.flip_h = true
			sprite_anime.play("IdleRight")
		elif attack_direction.x < 0:
			sprite_anime.flip_h = false
			sprite_anime.play("IdleLeft")
		on_detection_timer.start()
		timer_dash_started = true
	elif not ray_cast.is_colliding():
		timer_dash_started = false
		
func _dash():
	is_dashing = true
	is_dashing_timer.start()
	if ray_cast.is_colliding():
		if attack_direction.x > 0:
			sprite_anime.flip_h = true
			sprite_anime.play("DashRight")
		elif attack_direction.x < 0:
			sprite_anime.flip_h = false
			sprite_anime.play("DashLeft")
		
		velocity = lerp(velocity, ray_cast.target_position * dashing_speed, friction)

func _knockback():
	if current_state == enemy_state.KNOCKBACK:
		vfx_shader.play("Hit")
		if attack_direction.x > 0:
			sprite_anime.flip_h = true
			sprite_anime.play("StunRight")
		if attack_direction.x < 0:
			sprite_anime.flip_h = false
			sprite_anime.play("StunLeft")
		var knockback_strength = 40.0
		velocity = knockback_impact.normalized() * knockback_strength
		
func _physics_process(_delta):
	player_position = player_node.position
	attack_direction = (player_position - global_position).normalized()
	ray_cast.target_position = attack_direction * 80
	
	match current_state:
		enemy_state.MOVE:
			_move()
		enemy_state.DETECTION:
			_detection()
		enemy_state.DASH:
			_dash()
		enemy_state.KNOCKBACK:
			_knockback()
		enemy_state.DEATH:
			_death()
	
	if ray_cast.is_colliding():
		current_state = enemy_state.DETECTION
	elif is_knockback == true:
		current_state = enemy_state.KNOCKBACK
	else:
		current_state = enemy_state.MOVE
		
	move_and_slide()

func _death():
	set_physics_process(false)
	Global.enemy_deaths += 1
	Global.enemy_remain -= 1
	print(Global.enemy_remain)
	if attack_direction.x > 0:
		sprite_anime.flip_h = true
		sprite_anime.play("DeathRight")
	if attack_direction.x < 0:
		sprite_anime.flip_h = false
		sprite_anime.play("DeathLeft")

func on_detection_timeout():
	current_state = enemy_state.DASH

func is_dashing_timeout():
	is_dashing = false

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
	
	if area.is_in_group("shield"):
		current_state = enemy_state.DEATH

func _on_animate_sprite_animation_finished():
	if sprite_anime.animation == "DeathRight" or sprite_anime.animation == "DeathLeft":
		queue_free()


func _is_knockback_timeout():
	is_knockback = false
