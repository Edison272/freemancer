extends Area2D

const MAX_MANA = 10
var mana = 5

const MAX_SUS = 5
var sus = 1

# player stats
@export var speed = 400

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_mana_ui()
	update_sus_ui()
	$mana.max_value = MAX_MANA
	$sus.max_value = MAX_SUS
	
func update_mana_ui():
	set_mana_bar()

func set_mana_bar() -> void:
	$mana.value = mana
	
func update_sus_ui():
	set_sus_bar()

func set_sus_bar() -> void:
	$sus.value = sus

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO # player movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x += -1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y += -1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		
	# update player position based on velocity
	position += velocity * delta
	# position = position.clamp(Vector2.ZERO)
	
	if (Input.is_action_just_pressed("cast_spell") && mana >= 1):
		mana -= 1
	
	if (mana < MAX_MANA):
		mana += delta
	else:
		position = Vector2.ZERO
		mana = 0
	
	update_mana_ui()
	update_sus_ui()
	
