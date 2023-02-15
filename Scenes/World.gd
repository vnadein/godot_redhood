extends Node2D

var timer = 0

func _ready():
	randomize()
	var max_enemy = randi() % 50 +15
	set_process(true)
	for number in range(1,max_enemy):
		var _ENEMY := preload("res://Scenes/Skeleton.tscn")
		var _ENEMY_POSITION = _ENEMY.instance()
		randomize()
		var x_range = Vector2(300, 8300)
		var random_x = randi() % int(x_range[1]- x_range[0]) + 1 + x_range[0] 
		var random_pos = Vector2(random_x, 2)
		_ENEMY_POSITION.global_position = random_pos
		_ENEMY_POSITION._SPAWN_POSITION = random_pos
		add_child(_ENEMY_POSITION)
		
	
	$Player/Camera2D/Label.text = str("Prepare to Level ", Main._LEVEL)
	$Player/Camera2D/Label.visible = true

	
func _process(delta):
	if Main._HEALTH <= 0:
		Main._HEALTH = 0
	$Player/Camera2D/Hp_label.text = str(Main._HEALTH, "/", Main._MAX_HEALTH)
	$Player/Camera2D/Mp_label.text = str(Main._MANA, "/", Main._MAX_MANA)
	$Player/Camera2D/Exp_label.text = str(Main._EXP, "/", Main._MAX_EXP)
	

	timer += 1
	if timer > 150:
		$Player/Camera2D/Label.visible = false
	if Input.is_action_pressed("key_exit"):
		get_tree().quit()
