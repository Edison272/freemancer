extends RigidBody2D

var target_pos = Vector2.ZERO
var speed = 50

const search_dist_max = 25
const search_dist_min = 10

const wander_time = 10
var curr_time = 0

var aggression_state = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# start at a random position with a random target direction
	position = get_rand_pos()
	target_pos = get_rand_pos()
	$Sus.hide()
	$Alarm.hide()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = (target_pos).normalized() * speed
		
	# update player position based on velocity
	if position.distance_to(target_pos) > 1:
		position += velocity * delta
	
	# position timer - have the entity wander to a diff position every 5 seconds
	curr_time += delta
	if(curr_time >= wander_time):
		target_pos = get_rand_pos()
		curr_time = 0;
		
	set_aggression_VFX()

# function to get a random position within the range
func get_rand_pos() -> Vector2:
	var random_angle = randf_range(0.0, TAU) # TAU is 2 * PI
	var random_radius = randf_range(search_dist_min, search_dist_max)
	return Vector2(cos(random_angle), sin(random_angle)) * random_radius


func _on_area_2d_area_entered(area: Area2D) -> void:  # detect magic areas used by player
	print(area.name)
	if (area.is_in_group('Magical')):
		print('MAGE DETECTED')
		aggression_state += 1


func _on_detection_field_area_exited(area: Area2D) -> void:
	if (area.is_in_group('Magical')):
		aggression_state -= 1
	
func set_aggression_VFX() -> void: #set the vfx vased on the aggression level
	# sus is a question mark - cop is curious
	# Alarm is an exclamation point - cop WILL attack
	if (aggression_state >= 2): 
		$Sus.hide()
		$Alarm.show()
	elif (aggression_state >= 1):
		$Sus.show()
		$Alarm.hide()
	else:
		$Sus.hide()
		$Alarm.hide()
