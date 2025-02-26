extends Area2D

@export var sprite_anime: AnimatedSprite2D = null

var direction: Vector2

var is_colliding: bool = false

func _ready() -> void:
	randomize()
	
	sprite_anime.play("ParticleSpawn")
	
func _physics_process(delta: float) -> void:
	if is_colliding == false:
		translate(direction * delta * 125.0)

func _on_particle_anime_sprite_animation_finished():
	if sprite_anime.animation == "ParticleSpawn":
		sprite_anime.play("ParticleSpawned")
	if sprite_anime.animation == "ParticleDestroyed":
		queue_free()

func _on_body_entered(_body):
	is_colliding = true
	sprite_anime.play("ParticleDestroyed")

func _on_area_entered(area):
	is_colliding = true
	sprite_anime.play("ParticleDestroyed")
