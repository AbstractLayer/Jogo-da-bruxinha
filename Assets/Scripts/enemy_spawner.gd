extends Node2D

const ENEMY: PackedScene = preload("res://Assets/Scenes/feioso.tscn")
@export var enemy_spawned_timer: Timer = null

var enemy_count: int = 1
var enemy_spawned: bool = false

func _ready():
	enemy_spawned_timer.wait_time = randf_range(5,15)


func _physics_process(_delta):
	if enemy_count < 4 and enemy_spawned == false:
		enemy_spawned = true
		enemy_spawned_timer.start()
		enemy_count += 1
		
func _on_enemy_spawned_timer_timeout():
	enemy_spawned = false
	enemy_spawned_timer.stop()
	var enemy = ENEMY.instantiate()
	enemy.global_position.x = randf_range(-20,20)
	add_child(enemy)
