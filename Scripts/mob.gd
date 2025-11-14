extends CharacterBody2D

@export var stats: EnemyStats

var speed : float
var health : float
var experienceReward: float = 5
var stat_growth = 2.0

@onready var player = get_node("/root/Main/Player")

func _ready() -> void:
	randomize()
	
	var randomizer_value =  randf_range(1.0,stat_growth)
	health = stats.base_health * randomizer_value
	speed = stats.base_speed / randomizer_value
	scale = scale * randomizer_value/2
	experienceReward = experienceReward * randomizer_value
	var rng = RandomNumberGenerator.new()
	rng.randomize()
		
	$Slime.modulate = Color.from_hsv(randomizer_value/stat_growth, 0.5, 1)
	
	%Slime.play_walk()
	


func _physics_process(_delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	move_and_slide()

func take_damage(value):
	health -= value
	%Slime.play_hurt()
	if health <= 0:
		die()
		
func die():
	ExperienceSystem.give_experience.emit(experienceReward)
	queue_free()
	#Smoke animation
	const SMOKE_SCENCE = preload("res://smoke_explosion/smoke_explosion.tscn")
	var smoke = SMOKE_SCENCE.instantiate()
	get_parent().add_child(smoke)
	smoke.global_position = global_position
