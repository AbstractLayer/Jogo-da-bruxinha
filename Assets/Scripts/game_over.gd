extends Control


func _on_restart_button_pressed():
	Global.enemy_deaths = 0
	Global.enemy_remain = 10
	get_tree().paused = false
	get_tree().reload_current_scene()
	

func _on_level_1_player_death_label():
	$ColorRect/GameOver.text = "Você morreu!"


func _on_level_1_altar_label():
	$ColorRect/GameOver.text = "O Inimigo adquiriu o enchiridion"

func _on_level_1_player_winning_label():
	$ColorRect/GameOver.text = "Você Venceu!"
