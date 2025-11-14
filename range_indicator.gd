extends Sprite2D


@export var radius: float = 100.0
@export var color: Color = Color(0, 1,0, 0.3)
@export var outline_color: Color = Color(0, 1,0, 0.8)
@export var outline_width: float = 2.0
@export var visible_in_game: bool = true

func _ready() -> void:
	queue_redraw()
	
func _process(delta: float) -> void:
	if visible_in_game:
		queue_redraw()
	else:
		visible = false

func _draw() -> void:
	if not visible_in_game:
		return
	draw_circle(Vector2.ZERO, radius, color)
	draw_circle(Vector2.ZERO, radius, outline_color, outline_width)

func set_radius(new_radius:float) -> void:
	radius = new_radius
	queue_redraw()
