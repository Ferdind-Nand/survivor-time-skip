extends CharacterBody2D

class_name Player

signal health_depleted
signal augment_selection

#Player stats
var stats := {
	"health": 100.0,
	"move_speed": 600.0,
	"experience_multiplier": 1.0,
	"current_experience": 0.0,
	"next_level_experience": 5.0,
	"current_level": 1.0,
	"attack_speed": 1.0,
	"attack_damage": 1.0,
	"attack_range": 100.0,
	"pierce": 1.0,
	"fire_type": 0
}

var stats_text = "Debug Window"

@onready var gun = $Gun
var is_attacking = false


func _ready() -> void:
	ExperienceSystem.give_experience.connect(self.handle_give_experience_signal)
	%ExperienceBar.value = stats["current_experience"]
	%ExperienceBar.max_value = stats["next_level_experience"]
	gun.player_attacked.connect(_on_player_attacked)
	$Knight_Girl/AnimatedSprite2D.animation_finished.connect(_on_attack_anima_finished)
	_update_gun_stats()


func _physics_process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * stats["move_speed"]
	move_and_slide()
	
	const DAMAGE_RATE = 50.0
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		stats["health"] -= DAMAGE_RATE * overlapping_mobs.size() * delta
		%ProgressBar.value = stats["health"]
		if stats["health"] <= 0.0:
			health_depleted.emit()
	
	player_animation()


func _process(delta):
	var debug_text = ""
	for key in stats.keys():
		debug_text += "%s: %.2f\n" %[key.capitalize(), stats[key]]
	get_tree().root.get_node("Main/DebugOverlay/StatsWindow").text = debug_text


func _on_player_attacked():
	print_debug(is_attacking)
	if not is_attacking:
		is_attacking = true
		$Knight_Girl/AnimatedSprite2D.play("attack_1")
	
	
func _on_attack_anima_finished():
	print_debug(is_attacking)
	if is_attacking:
		is_attacking = false
		$Knight_Girl/AnimatedSprite2D.play("idle_1")
		print_debug("attack animation stopped")

func _update_gun_stats() -> void:
	if not gun:
		return
	gun.set_attack_speed(stats["attack_speed"])
	gun.set_attack_damage(stats["attack_damage"])
	gun.set_attack_range(stats["attack_range"])
	gun.set_pierce(stats["pierce"])
	gun.set_fire_type(int(stats["fire_type"]))


	
func player_animation():
	if velocity[0] > 0:
		$Knight_Girl/AnimatedSprite2D.flip_h = false
	elif velocity[0] < 0:
		$Knight_Girl/AnimatedSprite2D.flip_h = true
	
	if is_attacking:
		return
	
	if velocity.length() > 0.0:
		$Knight_Girl/AnimatedSprite2D.play("walking_1")
	else:
		%Knight_Girl/AnimatedSprite2D.play("idle_1")



func handle_give_experience_signal(value):
	stats["current_experience"] += value * stats["experience_multiplier"]
	%ExperienceBar.value = stats["current_experience"]
	if stats["current_experience"] >= stats["next_level_experience"]:
		level_up()
		

func level_up():
	print("Debug message: Called level up func")
	get_tree().paused = true
	stats["current_experience"] -= stats["next_level_experience"]
	stats["next_level_experience"] += 2 * stats["current_level"] # 5xp, 7xp, 11xp, 17xp, 
	%ExperienceBar.max_value = stats["next_level_experience"]
	%ExperienceBar.value = stats["current_experience"]
	stats["current_level"] += 1
	augment_selection.emit()
	
	#level up visuals
	const LEVELUP_SCENCE = preload("res://smoke_explosion/levelup_explosion.tscn")
	var levelup_explosion = LEVELUP_SCENCE.instantiate()
	get_parent().add_child(levelup_explosion)
	levelup_explosion.global_position = global_position
	

func get_stat(stat_name: String) -> float:
	if not stats.has(stat_name):
		print("Unknown stat: ", stat_name)
		return 0.0
	else:
		return stats[stat_name]

func _on_game_stat_increase(stat_name: String, increase_value: float) -> void:
	if not stats.has(stat_name):
		print("Unknown stat: ", stat_name)
		return
	if stat_name in ["attack_speed", "experience_multiplier"]:
		stats[stat_name] += increase_value / 100.0
	else:
		stats[stat_name] += increase_value
	
	print("%s increased to %.2f" % [stat_name, stats[stat_name]])
	_update_gun_stats()
