extends Control

var target_direction: Vector2 = Vector2.RIGHT
var pulse: float = 0.0

func set_direction(value: Vector2) -> void:
    if value.length() > 0.01:
        target_direction = value.normalized()
    rotation = target_direction.angle()
    queue_redraw()

func _process(delta: float) -> void:
    pulse += delta
    queue_redraw()

func _draw() -> void:
    var bob: float = sin(pulse * 3.0) * 2.0
    draw_circle(Vector2(32.0, 32.0), 29.0, Color(0.12, 0.055, 0.02, 0.46))
    draw_circle(Vector2(32.0, 32.0), 23.0, Color(1.0, 0.88, 0.46, 0.08))
    var shaft_start: Vector2 = Vector2(10.0, 32.0)
    var shaft_end: Vector2 = Vector2(42.0 + bob, 32.0)
    draw_line(shaft_start, shaft_end, Color(1.0, 0.91, 0.63, 0.96), 4.0, true)
    var tip: Vector2 = Vector2(55.0 + bob, 32.0)
    var left: Vector2 = tip + Vector2(-13.0, -10.0)
    var right: Vector2 = tip + Vector2(-13.0, 10.0)
    draw_colored_polygon(PackedVector2Array([tip, left, right]), Color(0.98, 0.70, 0.24, 0.98))
