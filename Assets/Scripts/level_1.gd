extends Node2D

@export var game_over_node: Control = null

signal altar_label
signal player_death_label
signal player_winning_label

func _process(delta):
	if Global.enemy_deaths == 10:
		_on_player_player_winning()


func _on_altar_game_over():
	await get_tree().create_timer(1.5).timeout
	game_over_node.visible = true
	get_tree().paused = true
	emit_signal("altar_label")


func _on_player_player_death():
	await get_tree().create_timer(1.0).timeout
	game_over_node.visible = true
	get_tree().paused = true
	emit_signal("player_death_label")

func _on_player_player_winning():
	await get_tree().create_timer(4.0).timeout
	game_over_node.visible = true
	get_tree().paused = true
	emit_signal("player_winning_label")
