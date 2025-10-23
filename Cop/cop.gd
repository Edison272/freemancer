extends RigidBody2D

var target_pos = Vector2.ZERO
const BASE_SPEED = 25
var speed = 50

const search_dist_max = 25
const search_dist_min = 10

const wander_time = 10
var curr_time = 0

var suspicious = true
var sus_time = 0

# shooting
@export var Bullet = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# start at a random position with a random target direction
	position = get_rand_pos()
	target_pos = get_rand_pos()
	$BigAlarm.hide()
	$Sus.hide()
	$Alarm.hide()
	$PewPew.hide()
	Bullet = $Bullet
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = (target_pos).normalized() * speed
		
	# update player position based on velocity
	if position.distance_to(target_pos) > 1:
		position += velocity * delta
	
	# position timer - have the entity wander to a diff position every 5 seconds
	curr_time += delta
	if (sus_time >= 3):  # if suspicion is over a certain level, find the player
		var player_pos = get_parent().get_node("Player").position
		target_pos = target_pos - position
		if (sus_time >= 9 && curr_time > 1):
			curr_time = 0
			
	elif(curr_time >= wander_time):			# wander arnd when minimal suspicion
		target_pos = get_rand_pos()
		curr_time = 0;
		
	if (suspicious):  # increase suspicion level when suspicious, otherwise decrease it
		sus_time += delta
	else:
		sus_time -= delta * 2
	set_aggression_state()  # set aggression level accordingly

# function to get a random position within the range
func get_rand_pos() -> Vector2:
	var random_angle = randf_range(0.0, TAU) # TAU is 2 * PI
	var random_radius = randf_range(search_dist_min, search_dist_max)
	return Vector2(cos(random_angle), sin(random_angle)) * random_radius


func _on_area_2d_area_entered(area: Area2D) -> void:  # detect magic areas used by player
	print(area.name)
	if (area.is_in_group('Magical')):
		print('MAGE DETECTED')
		suspicious = true


func _on_detection_field_area_exited(area: Area2D) -> void:
	if (area.is_in_group('Magical')):
		suspicious = false
	
func set_aggression_state() -> void: #set the vfx vased on the aggression level
	# sus is a question mark - cop is curious
	# Alarm is an exclamation point - cop WILL attack
	var player_pos = get_parent().get_node("Player").position
	if (sus_time >= 9):
		speed = BASE_SPEED * 2
		$BigAlarm.show()
		$Sus.hide()
		$Alarm.hide()
		$PewPew.show()
		$PewPew.look_at(player_pos)
	elif (sus_time >= 6): 
		speed = BASE_SPEED * 1.5
		$BigAlarm.hide()
		$Sus.hide()
		$Alarm.show()
		$PewPew.show()
		$PewPew.look_at(player_pos)
	elif (sus_time >= 3):
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
