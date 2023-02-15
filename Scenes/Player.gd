extends KinematicBody2D
var _SPEED := 100
var _GRAVITY := 150
var _JUMP_FORCE = 0.85
var _MOVE = Vector2()
var _ATTACK = false
var _SHOOT_TIMER = 0
var _LAST_STATE
var _ATTACK_FRAME = 0
var _MELEE_ENEMY_IN_RANGE = []
var _IS_TAKEN_DAMAGE = false
onready var _ANIMATION = get_node("AnimatedSprite")
onready var _ARROW := preload("res://Scenes/Arrow.tscn")
onready var _FIRE_ARROW := preload("res://Scenes/FireArrow.tscn")
onready var _SPRITE := $AnimatedSprite
onready var _HIT_PARTICLE := preload("res://Scenes/HitPlayersParticles.tscn")
var _PARTICLE_INSTANCE
var _HIT_PLAY_PARTICLE = 0

var _BASE_SPEED = 1
var _BASE_ATTACK_SPEED
var _RANGE_ATTACK_SPEED

var _ARROW_INSTANSE

var CHANCE_MELEE_HIT
var CHANCE_RANGE_HIT
var CHANCE_SPELL_HIT


func _ready():
	var _SPEED = Main.SPEED
	$Camera2D/PlayerHealth.visible = true
	$Camera2D/PlayerMana.visible = true
	$Camera2D/Enemy_label.visible = false
	$Camera2D/PlayerHealth.max_value = Main._MAX_HEALTH
	$Camera2D/PlayerMana.max_value = Main._MAX_MANA
	$Camera2D/ExpBar.max_value = Main._MAX_EXP
	$Camera2D/ExpBar.value = Main._EXP

func _process(delta):
	
	var STR = Main.STR
	var DEX = Main.DEX
	var INT = Main.INT
	
	$"Camera2D/Сharacteristics/Control/Level".text = "Level "+ str(Main._PLAYER_LEVEL)
	$"Camera2D/Сharacteristics/Control/Class".visible = false
	$"Camera2D/Сharacteristics/Control/STR".text = "STRENGTH:   "+ str(STR) 
	$"Camera2D/Сharacteristics/Control/DEX".text = "DEXTERITY:   "+ str(DEX)
	$"Camera2D/Сharacteristics/Control/INT".text = "INTELLIGANCE:   "+ str(INT)
	$"Camera2D/Сharacteristics/Control/EMPTY".text = "EMPTY POINT:   "+ str(Main._EMPTY_POINT)
	_BASE_SPEED = Main.MOVE_SPEED
	_BASE_ATTACK_SPEED = Main.MELEE_ATACK_SPEED
	_RANGE_ATTACK_SPEED = Main.RANGE_ATTACK_SPEED
	
	if Main._EXP >= Main._MAX_EXP:
		var _LAST = Main._EXP - Main._MAX_EXP
		Main._MAX_EXP = Main._MAX_EXP * 2
		$Camera2D/ExpBar.max_value = Main._MAX_EXP
		Main._EXP = 0 + _LAST
		$Camera2D/ExpBar.value = Main._EXP
		Main._PLAYER_LEVEL_UP()
		
	if _MELEE_ENEMY_IN_RANGE:
		$Camera2D/Enemy.max_value = _MELEE_ENEMY_IN_RANGE[0]._MAX_HEALTH
		$Camera2D/Enemy.value = _MELEE_ENEMY_IN_RANGE[0]._HEALTH
		$Camera2D/Enemy.visible = true
		$Camera2D/Enemy_label.visible = true
		$Camera2D/Enemy_label.text = str(_MELEE_ENEMY_IN_RANGE[0]._HEALTH, "/", _MELEE_ENEMY_IN_RANGE[0]._MAX_HEALTH)
	else: 
		$Camera2D/Enemy.visible = false
		$Camera2D/Enemy_label.visible = false
		
	if Input.is_action_just_pressed("characteristics"):
		if $"Camera2D/Сharacteristics/".visible:
			$"Camera2D/Сharacteristics/".visible = false
		else:
			$"Camera2D/Сharacteristics/".visible = true
			
			
	if Main._EMPTY_POINT != 0:
		$"Camera2D/Сharacteristics/Control/AddSTR".visible = true
		$"Camera2D/Сharacteristics/Control/AddDEX".visible = true
		$"Camera2D/Сharacteristics/Control/AddINT".visible = true
		$"Camera2D/LevelUPCharButton".visible = true
		
	else:
		$"Camera2D/Сharacteristics/Control/AddSTR".visible = false
		$"Camera2D/Сharacteristics/Control/AddDEX".visible = false
		$"Camera2D/Сharacteristics/Control/AddINT".visible = false
		$"Camera2D/LevelUPCharButton".visible = false

func _physics_process(delta: float):
	if Main._LIFE_FLASK_CHARHE == 40:
		$Camera2D/LifeFlask/LifeFlaskFull.visible = true
		$Camera2D/LifeFlask/LifeFlaskEmpty.visible = false
		$Camera2D/LifeFlask/Tank.visible = false
	if Main._LIFE_FLASK_CHARHE < 40:
		$Camera2D/LifeFlask/LifeFlaskFull.visible = false
		$Camera2D/LifeFlask/LifeFlaskEmpty.visible = true
		$Camera2D/LifeFlask/Tank.visible = true
		$Camera2D/LifeFlask/Tank.text = str(round(Main._LIFE_FLASK_CHARHE * 2.5))+"%" 
		
	$Camera2D/PlayerHealth.value = Main._HEALTH
	$Camera2D/PlayerMana.value = Main._MANA
	$Camera2D/ExpBar.value = Main._EXP
	if Main._HEALTH <= 0:
		pass
	if Input.is_action_pressed("ui_left"):
		_MOVE.x = -1
		_SPRITE.offset.x = -9
		_SPRITE.flip_h = true
	elif Input.is_action_pressed("ui_right"):
		_MOVE.x = 1
		_SPRITE.offset.x = 9
		_SPRITE.flip_h = false
	else:
		_MOVE.x = 0
		
	if Input.is_action_pressed("ui_up") and _MOVE.y == 0:
		_MOVE.y -= _JUMP_FORCE * _SPEED
	
	_MOVE.y += _GRAVITY * delta
	
	_MOVE.x = _MOVE.x * _SPEED
	if _IS_TAKEN_DAMAGE:
		if _SPRITE.get_frame() == 0 and _HIT_PLAY_PARTICLE == 0:
			_PARTICLE_INSTANCE = _HIT_PARTICLE.instance()
			get_parent().add_child(_PARTICLE_INSTANCE)
			_PARTICLE_INSTANCE.global_position = Vector2(position.x, (position.y - 15))
			_PARTICLE_INSTANCE.one_shot = true
			_PARTICLE_INSTANCE.emitting = true
			_HIT_PLAY_PARTICLE = 1
		if Main._HEALTH == 0:
			Main._HEALTH = Main._MAX_HEALTH
			get_tree().reload_current_scene()
		if(randi() % 100 >  Main.STUN_ON_HIT_RATING):
			if _SPRITE.get_frame() != 5:
				_SPRITE.play("hit")
			else:
				_IS_TAKEN_DAMAGE = false
		else:
			_IS_TAKEN_DAMAGE = false
			_HIT_PLAY_PARTICLE = 0
			
	elif Input.is_action_pressed("left_mouse") and is_on_floor() and !$"Camera2D/Сharacteristics/".visible:
		_play_attack_animation("main_attack")
	elif Input.is_action_pressed("right_mouse") and is_on_floor() and !$"Camera2D/Сharacteristics/".visible:
		_play_attack_animation("secondary_attack")
	elif Input.is_action_just_released("right_mouse"):
		_SHOOT_TIMER = 0
	else: 
		_play_move_animation(_MOVE)
		_MOVE = move_and_slide(_MOVE, Vector2.UP)
	
	if Input.is_action_just_released("life_flask") and Main._LIFE_FLASK_CHARHE == 40:
		Main._LIFE_FLASK_CHARHE = 0
		Main._HEALTH += 20
		if Main._HEALTH > Main._MAX_HEALTH:
			Main._HEALTH = Main._MAX_HEALTH
	
func _play_attack_animation(_TYPE: String):
	if _TYPE == "main_attack":
		_SPRITE.offset.y = 0
		if _SPRITE.flip_h: 
			_SPRITE.offset.x = -12
		else:
			_SPRITE.offset.x = 10
		_SPRITE.play("attack")
		_SPRITE.speed_scale = Main.MELEE_ATACK_SPEED
		if _MELEE_ENEMY_IN_RANGE:
			$Camera2D/Enemy.max_value = _MELEE_ENEMY_IN_RANGE[0]._MAX_HEALTH
			$Camera2D/Enemy.value = _MELEE_ENEMY_IN_RANGE[0]._HEALTH
			randomize()
			if _SPRITE.get_frame() == 2:
				if _SPRITE.get_frame() != _ATTACK_FRAME:
					_ATTACK_FRAME = 2
					var RAND_NUM = randi() % 100 + Main.CHANCE_MELEE_HIT
					if RAND_NUM > _MELEE_ENEMY_IN_RANGE[0].EVASION_RATING:
						_MELEE_ENEMY_IN_RANGE[0]._IS_TAKEN_DAMAGE = randi() % 50
						_MELEE_ENEMY_IN_RANGE[0]._HEALTH = _MELEE_ENEMY_IN_RANGE[0]._HEALTH - Main._BASE_DAMAGE
						_MELEE_ENEMY_IN_RANGE[0]._LAST_DAMAGE = String(Main._BASE_DAMAGE)
						_MELEE_ENEMY_IN_RANGE[0]._DAMAGE_LABEL = true
			if _SPRITE.get_frame() == 9:
				if _SPRITE.get_frame() != _ATTACK_FRAME:
					_ATTACK_FRAME = 9
					var RAND_NUM = randi() % 100 + Main.CHANCE_MELEE_HIT
					if RAND_NUM > _MELEE_ENEMY_IN_RANGE[0].EVASION_RATING:
						_MELEE_ENEMY_IN_RANGE[0]._IS_TAKEN_DAMAGE = randi() % 50
						_MELEE_ENEMY_IN_RANGE[0]._HEALTH = _MELEE_ENEMY_IN_RANGE[0]._HEALTH - Main._BASE_DAMAGE
						_MELEE_ENEMY_IN_RANGE[0]._LAST_DAMAGE = String(Main._BASE_DAMAGE)
						_MELEE_ENEMY_IN_RANGE[0]._DAMAGE_LABEL = true
			if _SPRITE.get_frame() == 16:
				if _SPRITE.get_frame() != _ATTACK_FRAME:
					_ATTACK_FRAME = 16
					var RAND_NUM = randi() % 100 + Main.CHANCE_MELEE_HIT
					if RAND_NUM > _MELEE_ENEMY_IN_RANGE[0].EVASION_RATING:
						_MELEE_ENEMY_IN_RANGE[0]._IS_TAKEN_DAMAGE = randi() % 50
						_MELEE_ENEMY_IN_RANGE[0]._HEALTH = _MELEE_ENEMY_IN_RANGE[0]._HEALTH - Main._BASE_DAMAGE
						_MELEE_ENEMY_IN_RANGE[0]._LAST_DAMAGE = String(Main._BASE_DAMAGE)
						_MELEE_ENEMY_IN_RANGE[0]._DAMAGE_LABEL = true

		
	elif _TYPE == "secondary_attack":
		_SPRITE.set_speed_scale(Main.RANGE_ATTACK_SPEED)
		_SPRITE.play("archer")
		_SPRITE.offset.y = 3
		if _SPRITE.get_frame() == 5 and _SHOOT_TIMER == 0:
			_box_to_shot()
			_SHOOT_TIMER = 1
		if _SPRITE.get_frame() == 6:
			_SHOOT_TIMER = 0
		
		
func _play_move_animation(_MOVE: Vector2):
	_SPRITE.set_speed_scale(_BASE_SPEED)
	_SPRITE.offset.y = 0
	if _MOVE.x == 0 and is_on_floor():
		_SPRITE.offset.x = 0
		_SPRITE.play("idle")
	elif _MOVE.x != 0 and is_on_floor():
		_SPRITE.play("run")
	elif _MOVE.y != 0 and !is_on_floor():
		_SPRITE.play("jump")
	

func _box_to_shot():
	_ARROW_INSTANSE = _FIRE_ARROW.instance()
	if _SPRITE.flip_h:
		_ARROW_INSTANSE.flip_h = true
		_ARROW_INSTANSE._DIRECTION = -5
		get_parent().add_child(_ARROW_INSTANSE)
		_ARROW_INSTANSE.global_position = $Position2D2.global_position
	else:
		get_parent().add_child(_ARROW_INSTANSE)
		_ARROW_INSTANSE.global_position = $Position2D.global_position

func _on_MeleDamageArea_body_entered(body):
	if body.name != "Player":
		if body.name != "TileMap" and body.name != "Portal":
			_MELEE_ENEMY_IN_RANGE.append(body)
	if body.name == "Portal":
		Main._LEVEL += 1
		
		get_tree().reload_current_scene()

func _on_MeleDamageArea_body_exited(body):
	_MELEE_ENEMY_IN_RANGE.erase(body)


func _on_LevelUpButton_pressed():
	if $"Camera2D/Сharacteristics/".visible:
		$"Camera2D/Сharacteristics/".visible = false
	else:
		$"Camera2D/Сharacteristics/".visible = true
