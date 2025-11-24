extends Node2D

class_name MapGenerator

var map_height: int = 2000
var map_width: int = 2000
var leaves_probability: int = 20 #higher means less
var tree_probability: int = 5000 #higher means less 
var tree_spacing: int = 12 #higher means less 
var fairy_probability: int = 10000
var leaf_radius := 12 #Tiles where leaves are visible around the player
var leaf_density := 12
var seed = 12345

#Parameter for chunck grid
@export var line_color := Color.RED
@export var line_thickness := 3.0

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	repeat_trees_around_player()
	leaf_generation()

func evolve_map(map_data: Dictionary) -> Dictionary:
	var new_trees := []
	
	for tree in map_data["trees"]:
		tree["age"] += 1
		if tree["age"] >= 5:
			continue
		new_trees.append(tree)
	
		if randf() < 0.4:
			new_trees.append({
				"x": tree["x"] + randi_range(-5, 5) * 50,
				"y": tree["y"] + randi_range(-5, 5) * 50,
				"age": 1
			})
	if new_trees.size() > 400:
		new_trees = new_trees.slice(0, 400)
	map_data["trees"] = new_trees
	return map_data

func leaf_generation():
	var player_pos: Vector2 = Global.main.get_node("Player").global_position
	var player_tile: Vector2i = %LeavesLayer.local_to_map(player_pos)
	
	%LeavesLayer.clear()
	
	for y in range(player_tile.y - leaf_radius,player_tile.y + leaf_radius + 1):
		for x in range(player_tile.x - leaf_radius,player_tile.x + leaf_radius + 1):
			var cell := Vector2i(x,y)
			
			if cell.distance_to(player_tile) > leaf_radius:
				continue
			
			#Consistent random value for cell. This results in the cell keeping 
			#the same value through one round
			var h = hash(cell + Vector2i(seed, seed))
			
			if h % leaf_density == 0:
				var tile_index = int((h >> 8) % 3) #0,1,2 leaf tiles (0,0) (0,1) and (0,2)
				%LeavesLayer.set_cell(cell, 0, Vector2i(tile_index % 2, tile_index % 3)) 

func repeat_trees_around_player():
	var area := 1000 #half of area in func generate_map
	var player_pos: Vector2 = Global.main.get_node("Player").global_position
	var trees : Array = Global.main.map.get_node("Trees").get_children()
	
	for tree in trees:
		var pos = tree.global_position
		
		var dx = pos.x - player_pos.x
		var dy = pos.y - player_pos.y
		
		if dx > area: pos.x -= area * 2
		elif dx < -area: pos.x += area * 2
		
		if dy > area: pos.y -= area * 2
		elif dy < -area: pos.y += area * 2
		
		tree.global_position = pos

func generate_map(map_seed: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = map_seed
	
	var map_data: Dictionary = {
		"objects": [],
		"trees": []}
	var area := 500 #Double as area in func repeat_trees_around_player()
	var tile_area := 125

	for i in range(100):
		map_data["trees"].append({
		"x": rng.randi_range(0, area * 4),
		"y": rng.randi_range(0, area * 4),
		"age": rng.randi_range(1, 3)
	})
	
	for i in range(400):
		map_data["objects"].append({
		"type": "leaves",
		"x": rng.randi_range(0, tile_area),
		"y": rng.randi_range(0, tile_area),
		"tile": var_to_str(Vector2i(randi_range(0,1), randi_range(0,2)))
	})

	return map_data

func generate_map_eye_candy():
	var fairy_scene := preload("res://fairy.tscn")

	for y in range(map_height*2):
		for x in range(map_width*2):

			#Fairy position generation
			if randi_range(0, fairy_probability) == 0:
				var fairy = fairy_scene.instantiate()
				fairy.global_position = Vector2((x-map_width) * tree_spacing*10,
												(y-map_height) * tree_spacing*10)
				get_node("Fairies").add_child(fairy)
