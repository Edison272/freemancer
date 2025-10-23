extends RigidBody2D

# player stats
const MAX_MANA = 100
var mana = MAX_MANA / 2

var spell_state = false

const MAX_SUS = 5
var sus = 1

const BASE_SPEED = 200
var speed = BASE_SPEED

var money = 0;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_mana_ui()
	update_sus_ui()
	levitation_spell(false)
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
	
	# cast spell
	if (Input.is_action_just_pressed("cast_spell")):
		if (spell_state == true):			# if spell is already in use, player can deactivate it free of charge
			spell_state = false
			speed = BASE_SPEED
			levitation_spell(false)			# deactivate the spell
			
		elif (mana > 10):					# otherwise, if the player has some mana, cast the spell
			spell_state = true
			mana -= 10
			speed = BASE_SPEED * 2
			levitation_spell(true)			# activate the spell
	
	if (mana < MAX_MANA):
		mana += delta
	else:
		position = Vector2.ZERO
		mana = 0
	
	update_mana_ui()
	update_sus_ui()
	
func levitation_spell(toggleOn: bool) -> void:
	$LevitationField.visible = toggleOn
	$LevitationField/LevitationShape.set_deferred("disabled", !toggleOn)


func _on_levitation_field_body_entered(body: Node2D) -> void:
	pass
	# print('body')


func _on_levitation_field_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	pass
	# print('shape') # Replace with function body.
