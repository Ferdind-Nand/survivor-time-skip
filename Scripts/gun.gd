extends Area2D

class_name gun

signal player_attacked

@onready var timer = $Timer
var base_fire_rate = 1.0
var attack_damage = 1.0
var attack_range = 100
var pierce = 4
var shooting_angle_offset = 0.2
@export var fire_type := FireType.SINGLE

enum FireType {
	SINGLE,
	DOUBLE,
	TRIPLE,
	QUADRUPEL,
	RING
}

func _ready() -> void:
	timer.wait_time = base_fire_rate
	timer.start()
	print_debug(fire_type)


func set_attack_speed(value:float) -> void:
	timer.wait_time = base_fire_rate / value
	if not timer.is_stopped():
		timer.start()
	print("Updated gun attack speed, timer wait_time: ", timer.wait_time)

func set_attack_damage(value: float) -> void:
	attack_damage = value

func set_attack_range(value: float) -> void:
	attack_range = value
	#%Range.scale = Vector2(value,value)
	_update_range_sprite()

func set_pierce(value: float) -> void:
	pierce = value

func set_fire_type(value: int) -> void:
	fire_type += value
	fire_type = clamp(fire_type, FireType.SINGLE, FireType.RING)
	print_debug("New fire type: ", fire_type)

func _physics_process(delta: float) -> void:
	# return overlapping areas as a list of arrays
	var enemies_in_range = get_overlapping_bodies()
	var target_enemy = get_nearest_enemy(get_overlapping_bodies())
	if enemies_in_range.size() > 0:
		look_at(target_enemy.global_position)

func get_nearest_enemy(enemies: Array) -> Node2D:
	var nearest_enemy = null
	var nearest_distance = INF
	for enemy in enemies:
		var d = global_position.distance_to(enemy.global_position)
		if  d < nearest_distance:
			nearest_distance = d
			nearest_enemy = enemy
	return nearest_enemy

func shoot(angle := 0.0):
	const BULLET = preload("res://bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = %ShootingPoint.global_position
	new_bullet.global_rotation = %ShootingPoint.global_rotation + angle
	new_bullet.bullet_damage = attack_damage
	new_bullet.pierce = pierce
	new_bullet.range = attack_range 
	%ShootingPoint.add_child(new_bullet)
	

func shoot_weapon() -> void:
	if fire_type == FireType.SINGLE:
		shoot()
	elif fire_type == FireType.DOUBLE:
		shoot(shooting_angle_offset)
		shoot(-shooting_angle_offset)
	elif fire_type == FireType.TRIPLE:
		shoot(shooting_angle_offset)
		shoot(0.0)
		shoot(-shooting_angle_offset)
	elif fire_type == FireType.QUADRUPEL:
		shoot(shooting_angle_offset*2)
		shoot(shooting_angle_offset/2)
		shoot(-shooting_angle_offset/2)
		shoot(-shooting_angle_offset*2)
	elif fire_type == FireType.RING:
		shoot(shooting_angle_offset*6)
		shoot(shooting_angle_offset*4)
		shoot(shooting_angle_offset*2)
		shoot()
		shoot(-shooting_angle_offset*2)
		shoot(-shooting_angle_offset*4)
		shoot(-shooting_angle_offset*6)

func _on_timer_timeout() -> void:
	shoot_weapon()
	player_attacked.emit()

func _update_range_sprite() -> void:
	var sprite = %RangeIndicator
	if not sprite.texture:
		return 
	var tex_size = sprite.texture.get_size().x
	var desired_scale = attack_range / tex_size
	sprite.scale = Vector2.ONE * desired_scale
	sprite.modulate = Color (0, 1, 0, 0.25)
