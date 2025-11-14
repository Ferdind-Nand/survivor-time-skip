extends Node2D
#print("Debug message: ")
#changes made
#more changes test
signal augment_selected(augment_number)
signal stat_increase(stat_name, increase_value)

var augments_value:= [0,0,0]
var augments_index:= [0,0,0]
var augment_title: String
@onready var player = $Player
@onready var pauseMenu = $PauseMenu
@onready var gameOverMenu = $GameOverMenu
var paused = false
@export var enemy_spawn := EnemySpawn.ON

enum EnemySpawn {
	ON,
	OFF
}

var possible_augments = [
	{"name": "Attack Speed", "stat": "attack_speed" , "min": 10, "max": 30, "suffix": "%", "weight": 10, "max_amount": 4, "icon": "res://Assets/Tiles/Large tiles/Thick outline/tile_0014.png"},
	{"name": "Attack Speed+", "stat": "attack_speed" , "min": 40, "max": 70, "suffix": "%", "weight": 2, "max_amount": 4, "icon": "res://Assets/Tiles/Large tiles/Thick outline/tile_0017.png"},
	{"name": "Attack Damage", "stat": "attack_damage" , "min": 0.3, "max": 1, "suffix": "", "weight": 10, "max_amount": 10, "icon": "res://Assets/Tiles/Large tiles/Thick outline/tile_0014.png"},
	{"name": "Attack Damage+", "stat": "attack_damage" , "min": 1.3, "max": 2, "suffix": "", "weight": 2, "max_amount": 10, "icon": "res://Assets/Tiles/Large tiles/Thick outline/tile_0017.png"},
	{"name": "Attack Range", "stat": "attack_range" , "min": 5, "max": 10, "suffix": "", "weight": 10, "max_amount": 1000, "icon": "res://Assets/Tiles/Large tiles/Thick outline/tile_0014.png"},
	{"name": "Attack Range+", "stat": "attack_range" , "min": 15, "max": 20, "suffix": "", "weight": 5, "max_amount": 1000, "icon": "res://Assets/Tiles/Large tiles/Thick outline/tile_0017.png"},
	{"name": "Pierce", "stat": "pierce", "min": 1, "max": 1, "suffix": "", "weight": 2, "max_amount": 10, "icon": "res://Assets/Tiles/Large tiles/Thick outline/tile_0014.png"},
	{"name": "Pierce+", "stat": "pierce", "min": 2, "max": 2, "suffix": "", "weight": 1, "max_amount": 10, "icon": "res://Assets/Tiles/Large tiles/Thick outline/tile_0017.png"},
	{"name": "Move Speed", "stat": "move_speed" , "min": 25, "max": 50, "suffix": "", "weight": 10, "max_amount": 2000, "icon": "res://Assets/Tiles/Large tiles/Thick outline/tile_0014.png"},
	{"name": "Move Speed+", "stat": "move_speed" , "min": 75, "max": 100, "suffix": "", "weight": 2, "max_amount": 2000, "icon": "res://Assets/Tiles/Large tiles/Thick outline/tile_0017.png"},
	{"name": "Experience Multiplier", "stat": "experience_multiplier", "min": 10, "max": 20, "suffix": "", "weight": 10, "max_amount": 10, "icon": "res://Assets/Tiles/Large tiles/Thick outline/tile_0014.png"},
	{"name": "Experience Multiplier+", "stat": "experience_multiplier", "min": 30, "max": 40, "suffix": "", "weight": 2, "max_amount": 10, "icon": "res://Assets/Tiles/Large tiles/Thick outline/tile_0017.png"},
	{"name": "Weapon Upgrade", "stat": "fire_type", "min": 1, "max": 1, "suffix": "", "weight": 1, "max_amount": 3, "icon": "res://Assets/Tiles/Large tiles/Thick outline/tile_0020.png"}
	]

func _ready():
	spawn_mob()
	spawn_mob()
	spawn_mob()
	spawn_mob()
	%DebugOverlay.get_node("StatsWindow").text = "Debug Window Test"
	Global.main = self

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause_menu"):
		pause_menu()
		
func pause_menu():
	if paused:
		pauseMenu.hide()
		Engine.time_scale = 1
	else:
		pauseMenu.show()
		Engine.time_scale = 0
	
	paused = !paused

func spawn_mob():
	var new_mob = preload("res://mob.tscn").instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)

func _on_timer_timeout() -> void:
	if enemy_spawn == EnemySpawn.ON:
		spawn_mob()
	elif enemy_spawn == EnemySpawn.OFF:
		pass

func _on_wave_increase_timer_timeout() -> void:
	pass	#include function to reduce the spawn timer for the mobs

func _on_player_health_depleted() -> void:
	%GameOverMenu.visible = true
	get_tree().paused = true

# Menue with restart and exit button
#func _on_restart_button_pressed() -> void:
	#print("Debug message: Pressed restart button")
	#get_tree().paused = false
	#get_tree().reload_current_scene()
	#print("Debug message: Scene reset")
	#%GameOverMenu.visible = false
	
#func _on_exit_button_pressed() -> void:
	#get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	#get_tree().quit()

# Augment menue with 3 augments that are chosen at random
func _on_player_augment_selection() -> void:
	print("Debug Message: called on_player_augment_selection")
	%AugmentSelection.visible = true
	
	var chosen_augments = weighted_randomizer(possible_augments, 3)
			
	for i in 3:
		var augment = chosen_augments[i]
		var increase_value = round(randf_range(augment["min"], augment["max"])*10)/10
		augments_value[i] = {
			"name": augment["name"],
			"stat": augment["stat"],
			"value": increase_value,
			"icon": augment["icon"]
		}
		
		var button = %AugmentSelection.get_child(i)
		button.get_node("Title").text = augment["name"]
		button.get_node("Value").text = "+%s%s" % [str(increase_value),
			augment["suffix"]]
		
		var icon_node = button.get_node("Icon")
		icon_node.texture = load(augment["icon"])
		icon_node.scale = Vector2(9.375, 15.625)
		icon_node.position = Vector2(150, 250)
		icon_node.texture_filter = TEXTURE_FILTER_NEAREST

#____________________________________
# Augment buttons emitting if pressed
func _on_augment_1_pressed() -> void:
	apply_augment(0)

func _on_augment_2_pressed() -> void:
	apply_augment(1)

func _on_augment_3_pressed() -> void:
	apply_augment(2)

func apply_augment(button_index: int) -> void:
	var augment = augments_value[button_index]
	stat_increase.emit(augment["stat"], augment["value"])
	%AugmentSelection.visible = false
	get_tree().paused = false
	

func weighted_randomizer(augments: Array, count: int = 3):
	var chosen_augments = []
	
	# filtering for valid augments
	var available_augments: Array = []
	for augment in augments:
		#Check for max stats
		var stat_name: String = augment["stat"]
		var current_value: float = player.get_stat(stat_name)
		if augment.has("max_amount") and current_value >= augment["max_amount"]:
			continue #Stat reached max amount. Augment will not be available
		available_augments.append(augment)
	
	if available_augments.is_empty():
		return []
	
	#Adapt weighting
	var t = clamp(float(player.stats["current_level"]) / 50.0, 0.0, 1.0)
	var level_factor = lerp(1.0, 2.0, ease(t, 2.0))
	
	for i in range(count):
		#Determine total weight
		var total_weight := 0
		for augment in available_augments:
			total_weight += augment["weight"]
		
		#Weighted random choosing
		var random_pick := randf_range(0, total_weight)
		var cumulative := 0.0
		for augment in available_augments:
			cumulative += augment["weight"]
			if random_pick <= cumulative:
				chosen_augments.append(augment)
				break
	
	return chosen_augments
