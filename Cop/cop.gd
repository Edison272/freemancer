extends RigidBody2D

var target_pos = Vector2.ZERO
const BASE_SPEED = 25
var speed = 50

const search_dist_max = 25
const search_dist_min = 10
var safe_dist = 1

const wander_time = 10
var curr_time = 0

var suspicious = false
var sus_time = 0

# help player!
var target_package = null
var has_package = false

# shooting
@export var Bullet : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# start at a random position with a random target direction
	# position = get_rand_pos()
	suspicious = false
	target_package = null
	target_pos = Vector2.ZERO
	$BigAlarm.hide()
	$Sus.hide()
	$Alarm.hide()
	$PewPew.hide()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (target_package != null): # find package
		if has_package:
			target_package.global_position = global_position - Vector2(0, 30)
			target_pos = get_parent().get_node("Objects").get_node("Destination").global_position - global_position
		elif (target_package.get_parent().name != 'Pickup'):
			target_package = null
		else:
			target_pos = target_package.global_position - global_position
			
	else:
		var package_search = get_parent().get_node("Objects").get_node("Pickup").get_tree().get_nodes_in_group('Package')
		if (package_search.size() > 0):
			var nearest_p = package_search[0]
			for p in package_search:
				if p.get_parent().name == "Pickup":
					if nearest_p.get_parent().name != "Pickup":
						nearest_p = p
						continue
					if p.global_position.distance_to(global_position) < nearest_p.global_position.distance_to(global_position):
						nearest_p = p
			target_package = nearest_p
			
	var velocity = (target_pos).normalized() * speed
	# update player position based on velocity
	position += velocity * delta
	
	# position timer - have the entity wander to a diff position every 5 seconds
	curr_time += delta
	if (sus_time < 0):
		sus_time = 0
	if (sus_time >= 0.5):  # if suspicion is over a certain level, find the player
		var player_pos = get_parent().get_node("Player").position
		safe_dist = 40
		if (sus_time >= 2 && curr_time > 0.5):
			var b = Bullet.instantiate()
			get_tree().root.add_child(b)
			b.transform = $PewPew.transform
			b.position = position + get_rand_pos()
			curr_time = 0
			safe_dist = 120
		if (sus_time > 4):
			sus_time = 4
		
	if (suspicious):  # increase suspicion level when suspicious, otherwise decrease it
		sus_time += delta
	else:
		sus_time -= delta * 2
	set_aggression_state()  # set aggression level accordingly

# function to get a random position within the range
func get_rand_pos() -> Vector2:
	if (position.distance_to(Vector2.ZERO) < 250): # if the cop is within the spawn zone, they go wherever they want
		var random_angle = randf_range(0.0, TAU) # TAU is 2 * PI
		var random_radius = randf_range(search_dist_min, search_dist_max)
		return Vector2(cos(random_angle), sin(random_angle)) * random_radius
	else:											# otherwise, go towards the middle
		return Vector2.ZERO - position


func _on_area_2d_area_entered(area: Area2D) -> void:  # detect magic areas used by player
	if (area.is_in_group('Magical')):
		suspicious = true
	if (area.is_in_group('Package') && area.get_parent().name == 'Pickup'):
		print('PACKAGE DETECTED')
		if (!has_package):
			target_package = area
			has_package = true
			area.get_parent().remove_child(area)
			add_child(area)
			print(target_package.get_parent().name)
	if (area.is_in_group('Destination')):
		if (has_package):
			print('PACKAGE DELIVERED')
			has_package = false
			target_pos = Vector2.ZERO
			target_package.queue_free()
		


func _on_detection_field_area_exited(area: Area2D) -> void:
	if (area.is_in_group('Magical')):
		suspicious = false
	
func set_aggression_state() -> void: #set the vfx vased on the aggression level
	# sus is a question mark - cop is curious
	# Alarm is an exclamation point - cop WILL attack
	var player_pos = get_parent().get_node("Player").position
	if (sus_time >= 2):
		speed = BASE_SPEED * 2
		$BigAlarm.show()
		$Sus.hide()
		$Alarm.hide()
		$PewPew.show()
		$PewPew.look_at(player_pos)
	elif (sus_time >= 1.5): 
		speed = BASE_SPEED * 1.2
		$BigAlarm.hide()
		$Sus.hide()
		$Alarm.show()
		$PewPew.show()
		$PewPew.look_at(player_pos)
	elif (sus_time >= 0.5):
		speed = BASE_SPEED
		$BigAlarm.hide()
		$Sus.show()
		$Alarm.hide()
		$PewPew.show()
	else:
		speed = BASE_SPEED
		$BigAlarm.hide()
		$Sus.hide()
		$Alarm.hide()
		$PewPew.hide()
