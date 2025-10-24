extends Area2D

# player stats
const MAX_MANA = 100
var mana = MAX_MANA / 2

var spell_state = false

const MAX_SUS = 5
var sus = 1

const BASE_SPEED = 100
var speed = BASE_SPEED

@export var money = 0;
const mortgage = 200

#j*b
var package_array = []
const max_packages = 5


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
	
func player_explodes() -> void:
	if (mana >= MAX_MANA):
		queue_free();

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
			
			if (package_array.size() > 1):
				for i in range(package_array.size()-1, -1, -1): # drop all packages except for the one being carried
					var random_angle = randf_range(0.0, TAU) # TAU is 2 * PI
					var random_radius = randf_range(0, 50)
					package_array[i].global_position = global_position + Vector2(cos(random_angle), sin(random_angle)) * random_radius
					remove_child(package_array[i])
					get_parent().get_node("Objects").get_node("Pickup").add_child(package_array[i])
					package_array.remove_at(i)
			
		elif (mana > 10):					# otherwise, if the player has some mana, cast the spell
			spell_state = true
			mana -= 10
			speed = BASE_SPEED * 2
			levitation_spell(true)			# activate the spell
	
	if (mana < MAX_MANA):
		mana += delta * 2
	else:
		position = Vector2.ZERO
		mana = 5
		money -= 10
		for i in range(package_array.size()-1, -1, -1): # drop all packages except for the one being carried
			var random_angle = randf_range(0.0, TAU) # TAU is 2 * PI
			var random_radius = randf_range(0, 50)
			package_array[i].global_position = global_position + Vector2(cos(random_angle), sin(random_angle)) * random_radius
			remove_child(package_array[i])
			get_parent().get_node("Objects").get_node("Pickup").add_child(package_array[i])
			package_array.remove_at(i)
		
		
	# package carrying
	if spell_state: # while spell is active, hold ALL packages over the player's head
		for i in package_array.size(): # drop all packages except for the one being carried
			package_array[i].position = Vector2(0, -30) + Vector2(0, -10 * (i))
	elif package_array.size() > 0:
		package_array[0].position = Vector2(0, -30)
		
	# update money
	$money.text = str(money) + str(' / ') + str(mortgage) 
	
	update_mana_ui()
	update_sus_ui()
	
func levitation_spell(toggleOn: bool) -> void:
	$LevitationField.visible = toggleOn
	$LevitationField/LevitationShape.set_deferred("disabled", !toggleOn)
	# print('shape') # Replace with function body.

 # Replace with function body.

func _on_area_entered(area: Area2D) -> void:
	if (area.is_in_group('Bullet')):
		speed += 1
	if (area.is_in_group('Package') && area.get_parent().name == 'Pickup'):
		if (package_array.size() > 0): # if the player isn't casting magic, they can only hold one package
			return
		package_array.append(area)
		area.get_parent().remove_child(area)
		add_child(area)
	if (area.is_in_group('Destination')):
		for i in range(package_array.size()-1, -1, -1): # drop all packages except for the one being carried
			var p = package_array[i]
			package_array.remove_at(i)
			p.queue_free()
			money += 5
func _on_levitation_field_area_entered(area: Area2D) -> void:
	if (area.is_in_group('Package') && area.get_parent().name == 'Pickup'):
		if (package_array.size() < max_packages): # if the player isn't casting magic, they can only hold one package
			package_array.append(area)
			area.get_parent().remove_child(area)
			add_child(area)
