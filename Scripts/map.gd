extends Node2D

var map_height: float = 1000
var map_width: float = 1000
var leaves_probability: int = 20 #higher means less
var trees_probability: int = 80 #higher means less 
var tree_spacing: float = 20 #higher means less 
var fairy_probability: int = 10000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_map()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func generate_map():
	var tree_scene := preload("res://pine_tree.tscn")
	var fairy_scene := preload("res://fairy.tscn")
	for y in map_height:
		for x in map_width:
			%GroundLayer.set_cell(Vector2(x-map_width/2,y-map_height/2),0, Vector2i(6,13))
			if 0 == randi_range(0,leaves_probability):
				var extra_leaves : Vector2i
				match randi_range(0,5):
					0: extra_leaves = Vector2i(0,0)
					1: extra_leaves = Vector2i(0,1)
					2: extra_leaves = Vector2i(1,0)
					3: extra_leaves = Vector2i(1,1)
					4: extra_leaves = Vector2i(0,2)
					0: extra_leaves = Vector2i(1,2)
				%LeavesLayer.set_cell(Vector2(x-map_width/2,y-map_height/2),0, extra_leaves)
			
			if 0 == randi_range(0,trees_probability):
				var tree := tree_scene.instantiate()
				tree.global_position = Vector2((x-map_width/2)*tree_spacing,(y-map_height/2)*tree_spacing)
				get_node("Trees").add_child(tree)
			
			if 0 == randi_range(0, fairy_probability):
				var fairy = fairy_scene.instantiate()
				fairy.global_position = Vector2((x-map_width/2)*tree_spacing,
												(y-map_height/2)*tree_spacing)
				get_node("Fairies").add_child(fairy)
	
			
