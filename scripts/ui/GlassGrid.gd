extends Control

@export var grid_size: float = 32.0
@export var line_alpha: float = 0.075
@export var dot_alpha: float = 0.12

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_process(false)
    queue_redraw()

func _draw() -> void:
    var viewport_size: Vector2 = get_viewport_rect().size
    var cols: int = int(ceil(viewport_size.x / grid_size))
    var rows: int = int(ceil(viewport_size.y / grid_size))
    var line_color = Color(0.96, 0.88, 0.70, line_alpha)
    var dot_color = Color(1.0, 0.92, 0.72, dot_alpha)

    for x in range(cols + 1):
        var px: float = float(x) * grid_size
        draw_line(Vector2(px, 0.0), Vector2(px, viewport_size.y), line_color, 1.0)
    for y in range(rows + 1):
        var py: float = float(y) * grid_size
        draw_line(Vector2(0.0, py), Vector2(viewport_size.x, py), line_color, 1.0)

    for x in range(0, cols + 1, 3):
        for y in range(0, rows + 1, 3):
            draw_circle(Vector2(float(x) * grid_size, float(y) * grid_size), 1.8, dot_color)
