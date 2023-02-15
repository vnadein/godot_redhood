extends KinematicBody2D

var _MOVE_DIRECTION = Vector2()
var _IN_AREA = false
var _PLAYER_BODY_ID = false
onready var _SPRITE = $AnimatedSprite
var _SPAWN_POSITION = false
var _ATTACK_FRAME = 0
var _MOVE_TO_SPAWN = false
var _IS_TAKEN_DAMAGE = false
var _MELEE_ENEMY_IN_RANGE = false
var _MELEE_DAMAGE_RANGE = false
var _EXP_FRAME = 3
var _STEP = 0
var _LAST_DAMAGE = 0
var _DAMAGE_LABEL = false
onready var _DRAW_DAMAGE_LABEL = $DamageLabel
onready var _HIT_PARTICLE := preload("res://Scenes/HitParticles.tscn")
var _PARTICLE_INSTANCE
var _HIT_PLAY_PARTICLE = 0

var STR = randi() % 5 + Main._LEVEL
var DEX = randi() % 5 + Main._LEVEL
var INT = randi() % 5 + Main._LEVEL

var BASE_HP = 10 + Main._LEVEL
var _HEALTH = round(int(STR / 2)) + BASE_HP
var BASE_MP = 15
var MP = INT * 2 + BASE_MP

var _MAX_HEALTH = _HEALTH

var ARMOR = STR / 2
var EVASION = DEX / 2
var SPELL_EVASION = INT / 2

var EVASION_RATING
var SPELL_EVASION_RATING = 30 + INT * 1.5 + SPELL_EVASION 
var STUN_ON_HIT_RATING = 30 + STR + DEX / 2
var STUN_ON_SPELL_HIT_RATING = 30 + INT + DEX / 2

var MOVE_SPEED = 1 + (STR / 2 * DEX / 2) / 100
var MELEE_ATACK_SPEED = 1 + (STR / 2) / 100
var RANGE_ATTACK_SPEED = 5 * 1 + (DEX / 2) / 100 
var SPELL_ATTACK_SPEED = 1 + (INT / 2) / 100

var REDUCE_DAMAGE = ARMOR / 5 
var REDUCE_SPELL = SPELL_EVASION / 5

var CHANCE_MELEE_HIT = 50 + STR / 5 * MELEE_ATACK_SPEED 
var CHANCE_RANGE_HIT = 50 + DEX / 5 * RANGE_ATTACK_SPEED 
var CHANCE_SPELL_HIT = 50 + INT / 5 * SPELL_ATTACK_SPEED

func _ready():
	_SPRITE.play("idle")
	scale = Vector2(.7, .7)
	
func _process(delta):
	EVASION_RATING = randi() % 100 + (30 + DEX * 1.5 + EVASION)
	if _DAMAGE_LABEL:
		$DamageLabel.text = String(_LAST_DAMAGE)
		$DamageLabel.visible = true
	else:
		$DamageLabel.visible = false
	if _STEP == 40:
		_DAMAGE_LABEL = false
		$DamageLabel.visible = false
		_STEP = 0
	
	_STEP = _STEP + 1
	
func _physics_process(delta):
	if  _HEALTH <= 0:
		die()
	elif _IS_TAKEN_DAMAGE:
		if _SPRITE.get_frame() == 0 and _HIT_PLAY_PARTICLE == 0:
			_PARTICLE_INSTANCE = _HIT_PARTICLE.instance()
			get_parent().add_child(_PARTICLE_INSTANCE)
			_PARTICLE_INSTANCE.global_position = Vector2(position.x, (position.y - 30))
			_PARTICLE_INSTANCE.one_shot = true
			_PARTICLE_INSTANCE.emitting = true
			_HIT_PLAY_PARTICLE = 1
		if(_IS_TAKEN_DAMAGE < STUN_ON_HIT_RATING):
			_SPRITE.play("hit")
			if _SPRITE.get_frame() == 3:
				_IS_TAKEN_DAMAGE = false
				_HIT_PLAY_PARTICLE = 0
		else:
			_IS_TAKEN_DAMAGE = false
	elif _IN_AREA:
		if (_PLAYER_BODY_ID.global_position.x + 30) > position.x and (_PLAYER_BODY_ID.global_position.x - 30) < position.x:
			_SPRITE.play("attack")
			if _MELEE_DAMAGE_RANGE:
				if _SPRITE.get_frame() == 6:
					if _SPRITE.get_frame() != _ATTACK_FRAME:
						_ATTACK_FRAME = 6
						var RAND_NUM = randi() % 100 + CHANCE_MELEE_HIT
						if RAND_NUM > Main.EVASION_RATING:
							randomize()
							_MELEE_ENEMY_IN_RANGE._IS_TAKEN_DAMAGE = randi() % 50
							var _DAMAGE = randi() % 3 + Main._LEVEL - Main.REDUCE_DAMAGE
							Main._HEALTH = Main._HEALTH - _DAMAGE
				elif _SPRITE.get_frame() == 7:
					_ATTACK_FRAME = 0
		elif _PLAYER_BODY_ID.global_position.x < position.x:
			_SPRITE.play("run")
			_SPRITE.flip_h = true
			position.x -= 0.7
		elif  _PLAYER_BODY_ID.global_position.x > position.x:
			_SPRITE.play("run")
			_SPRITE.flip_h = false
			position.x += 0.7
			
	if _MOVE_TO_SPAWN:
		if position.x < _SPAWN_POSITION.x:
			_SPRITE.play("run")
			position.x += 1
			_SPRITE.flip_h = false
		elif position.x > _SPAWN_POSITION.x:
			_SPRITE.play("run")
			position.x -= 1
			_SPRITE.flip_h = true
		elif position.x == _SPAWN_POSITION.x:
			_SPRITE.play("idle")
			_SPRITE.flip_h = true
			_MOVE_TO_SPAWN = false

func _on_Area_body_entered(body):
	if _HEALTH > 0:
		if body.name == "Player":
			_PLAYER_BODY_ID = body
			_IN_AREA = true
			_MOVE_TO_SPAWN = false
	
func _on_Area_body_exited(body):
	if _HEALTH > 0:
		if body.name == "Player":
			_PLAYER_BODY_ID = false
			_IN_AREA = false
			_MOVE_TO_SPAWN = true

func die():
	_SPRITE.play("death")
	if _SPRITE.get_frame() == 0 and _HIT_PLAY_PARTICLE == 0:
		_PARTICLE_INSTANCE = _HIT_PARTICLE.instance()
		get_parent().add_child(_PARTICLE_INSTANCE)
		_PARTICLE_INSTANCE.global_position = Vector2(position.x, (position.y - 30))
		_PARTICLE_INSTANCE.one_shot = true
		_PARTICLE_INSTANCE.emitting = true
		_HIT_PLAY_PARTICLE = 1
	var _IN_AREA = false
	var _IS_TAKEN_DAMAGE = false
	$CollisionShape2D.set_deferred("disabled", true)
	if _SPRITE.get_frame() == 3 and _EXP_FRAME == 3:
		_EXP_FRAME = 0
		Main._EXP = round(int(Main._EXP + 20 + Main._LEVEL * 2 + _HEALTH / 5))
		if Main._LIFE_FLASK_CHARHE != 40:
			Main._LIFE_FLASK_CHARHE += 1
		$DamageLabel.visible = false


func _on_CanAttack_body_entered(body):
	if body.name == "Player":
		_MELEE_DAMAGE_RANGE = true
		_MELEE_ENEMY_IN_RANGE = body
		


func _on_CanAttack_body_exited(body):
	if body.name == "Player":
		_MELEE_DAMAGE_RANGE = false
		_MELEE_ENEMY_IN_RANGE = false

