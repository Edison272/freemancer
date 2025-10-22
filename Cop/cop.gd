extends Area2D

var target_pos = Vector2.ZERO
var target_entity
var speed = 50

const search_dist = 20

const wander_time = 10
var curr_time = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target_entity = $"../Player"
	target_pos = get_rand_pos(target_entity.position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = (target_pos-position).normalized() * speed
		
	# update player position based on velocity
	if position.distance_to(target_pos) > 1:
		position += velocity * delta
	
	# position timer - have the entity wander to a diff position every 5 seconds
	curr_time += delta
	if(curr_time >= wander_time):
		target_pos = get_rand_pos(target_entity.position)
		curr_time = 0;

# function to get a random position within the range
func get_rand_pos(base_pos: Vector2) -> Vector2:
	var random_angle = randf_range(0.0, TAU) # TAU is 2 * PI
	var random_radius = randf_range(0.0, search_dist)
	print(base_pos + Vector2(cos(random_angle), sin(random_angle)) * random_radius)
	return base_pos + Vector2(cos(random_angle), sin(random_angle)) * random_radius
	
