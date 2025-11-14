extends Area2D

var travelled_distance = 0
var bullet_damage: float
var pierce: int
var range = 100
var hit_enemies = {}

func _physics_process(delta: float) -> void:
	const BULLLET_SPEED = 500
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * BULLLET_SPEED * delta
	travelled_distance += BULLLET_SPEED * delta 
	
	for body in get_overlapping_bodies():
		print("Collided with: ", body.name)
		
	if travelled_distance > range:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	var already_hit = false
	
	for i in hit_enemies:
		if body == hit_enemies[i]:
			already_hit = true

	if already_hit == false:
		if body.has_method("take_damage"):
			body.take_damage(bullet_damage)
			pierce -= 1
			if pierce <= 0:
				queue_free()
