extends Sprite

var _DIRECTION = 5

func _ready():
	scale = Vector2(1, 1.1)

func _physics_process(delta):
	position.x += _DIRECTION

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	

func _on_Arrow_body_entered(body):
	if body.name.begins_with("@Skeleton"):
		if body._HEALTH > 0:
			randomize()
			var RAND_NUM = randi() % 100 + Main.CHANCE_RANGE_HIT
			if RAND_NUM > body.EVASION_RATING:
				body._IS_TAKEN_DAMAGE = randi() % 50
				body._HEALTH = body._HEALTH - Main._RANGE_DAMAGE
				body._LAST_DAMAGE = Main._RANGE_DAMAGE
				body._DAMAGE_LABEL = true
				queue_free()
		else: 
			body.die()
