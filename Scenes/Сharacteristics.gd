extends Node2D


func _on_AddSTR_pressed():
	Main._EMPTY_POINT -= 1
	Main.STR += 1
	if Main._HEALTH == Main._MAX_HEALTH:
		Main._MAX_HEALTH = Main.BASE_HP + round(Main.STR * 2)
		Main._HEALTH = Main._MAX_HEALTH
	else:
		Main._MAX_HEALTH = Main.BASE_HP + round(Main.STR * 2)
		Main._HEALTH = Main._HEALTH + 2


func _on_AddDEX_pressed():
	Main._EMPTY_POINT -= 1
	Main.DEX += 1


func _on_AddINT_pressed():
	Main._EMPTY_POINT -= 1
	Main.INT += 1
	if Main._MANA == Main._MAX_MANA:
		Main._MAX_MANA = Main.BASE_MP + round(Main.INT * 2)
		Main._MANA = Main._MAX_MANA
	else:
		Main._MAX_MANA = Main.BASE_MP + round(Main.INT * 2)
		Main._MANA = Main._MANA + 2
