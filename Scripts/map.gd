extends Node2D

class_name MapGenerator

var map_height: int = 2000
var map_width: int = 2000
var leaves_probability: int = 20 #higher means less
var tree_probability: int = 5000 #higher means less 
var tree_spacing: int = 12 #higher means less 
var fairy_probability: int = 10000
var leaf_radius := 6 #Tiles where leaves are visible around the player

#Parameter for chunck grid
@export var line_color := Color.RED
@export var line_thickness := 3.0

func _ready() -> void:
	pass
	#var poly := Polygon2D.new()
	#poly.polygon = [
		#Vector2(0, 0),
		#Vector2(map_width, 0),
		#Vector2(map_width, map_height),
		#Vector2(0, map_height)
	#]
	#poly.color = line_color
	#add_child(poly)

func _process(_delta: float) -> void:
	repeat_trees_around_player()


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
		"leaves": []}
	var area := 2000 #Double as area in func repeat_trees_around_player()
	var tile_area := 125

	for i in range(100):
		map_data["objects"].append({
		"type": "tree",
		"x": rng.randi_range(0, area),
		"y": rng.randi_range(0, area),
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
	pass
	#var fairy_scene := preload("res://fairy.tscn")
	#var ground_cells = []
	#var leaf_cells = []
	#
	#
	#for y in range(map_height*2):
		#for x in range(map_width*2):
			##var pos = Vector2i(x-map_width, y-map_height)
			#
			###Ground position generation
			##ground_cells.append({
				##"position": pos,
				##"source_id": 0,
				##"atlas_coords": Vector2i(6, 13)
			##})
			##
			###Leaves position generation
			##if randi_range(0, leaves_probability) == 0:
				##var extra_leaves = Vector2i(randi_range(0,1), randi_range(0,2))
				##%LeavesLayer.set_cell(Vector2())
			#
			##Fairy position generation
			#if randi_range(0, fairy_probability) == 0:
				#var fairy = fairy_scene.instantiate()
				#fairy.global_position = Vector2((x-map_width) * tree_spacing*10,
												#(y-map_height) * tree_spacing*10)
				#get_node("Fairies").add_child(fairy)
			#
	#%GroundLayer.set_cell(ground_cells)
	#%LeavesLayer.set_cell(leaf_cells)
		#
			#
			#Generate fairies
			
