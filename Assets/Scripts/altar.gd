extends StaticBody2D

signal game_over

@export var shield: Area2D = null
@export var shield_collision: CollisionShape2D = null
@export var sprite_anime: AnimatedSprite2D = null
@onready var player = get_parent().get_node("Player")

var distance
var shield_life: int = 8

func _ready() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property($"Book Sprite", "position", Vector2(0,-16), 1)
	tween.tween_property($"Book Sprite", "position", Vector2(0,-12), 1)

func _physics_process(delta) -> void:
	distance = player.global_position.distance_to(shield.global_position)
	if shield_life > 6:
		distance_shield("ShieldFullNear", "ShieldFullLong")
	elif shield_life <= 5 and shield_life >= 4:
		distance_shield("ShieldBreak1Near", "ShieldBreak1Long")
	elif shield_life >= 1 and shield_life <= 4:
		distance_shield("ShieldBreak2Near", "ShieldBreak2Long")
	elif shield_life == 0:
		sprite_anime.play("ShieldBroken")

func distance_shield(shieldnear, shieldlong) -> void:
	if distance < 60:
		sprite_anime.visible = true
		sprite_anime.play(shieldnear)
	elif distance < 80:
		sprite_anime.visible = true
		sprite_anime.play(shieldlong)
	elif distance > 120:
		sprite_anime.visible = false

func _on_shield_area_entered(area):
	if area.is_in_group("feioso"):
		shield_life -= 1
	if area.is_in_group("bruxento"):
		shield_life -= 1

func _on_restart_area_entered(area):
	if area.is_in_group("feioso") and shield_life <= 0:
		game_over.emit()
	if area.is_in_group("bruxento") and shield_life <= 0:
		game_over.emit()
	
func _on_shield_anime_sprite_animation_finished():
	if sprite_anime.animation == "ShieldBroken":
		shield_collision.disabled = true
		shield.visible = false

