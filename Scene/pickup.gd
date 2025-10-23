extends Node2D

const SPAWNRATE = 0.1

var spawn_time = 0

@export var package : PackedScene

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (spawn_time >= SPAWNRATE):
		spawn_time = 0
		
		var random_angle = randf_range(0.0, TAU) # TAU is 2 * PI
		var random_radius = randf_range(0, 10)
		var p = package.instantiate()
		get_tree().root.add_child(p)
		p.position = position + Vector2(cos(random_angle), sin(random_angle)) * random_radius
	else:
		spawn_time += delta
