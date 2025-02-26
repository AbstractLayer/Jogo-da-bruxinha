extends Label

func _process(delta):
	self.text = "Enemy Remain:" + str(Global.enemy_remain)
