extends Control

var take_damage = 45

func _on_player_health_changed():
	$Hearts_Sprite.size.x = take_damage
	take_damage -= 9
