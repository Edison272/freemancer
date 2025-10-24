extends Area2D

var speed = 10
var lifetime = 0

func _physics_process(delta):
	position += transform.x * speed * delta
	if (lifetime > 3):
		queue_free()
	lifetime += delta
