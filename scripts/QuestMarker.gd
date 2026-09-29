extends Node2D

var marker_id: String = ""
var title: String = ""
var pulse: float = 0.0
var active: bool = true
var prompt: Label
var _prompt_style: StyleBoxFlat

func setup(id_value: String, title_value: String) -> void:
    marker_id = id_value
    title = title_value
    _build_prompt()
    queue_redraw()

func _ready() -> void:
    _build_prompt()

func _build_prompt() -> void:
    if prompt != null:
        return
    prompt = Label.new()
    prompt.position = Vector2(-12.0, 10.0)
    prompt.size = Vector2(24.0, 18.0)
    prompt.text = ""
    prompt.visible = false
    prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    prompt.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    prompt.add_theme_font_size_override("font_size", 9)
    prompt.add_theme_color_override("font_color", Color("#2b2431"))
    prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _prompt_style = StyleBoxFlat.new()
    _prompt_style.bg_color = Color(1.0, 0.91, 0.56, 0.94)
    _prompt_style.border_color = Color(1.0, 0.98, 0.78, 0.92)
    _prompt_style.set_border_width_all(1)
    _prompt_style.set_corner_radius_all(8)
    _prompt_style.shadow_color = Color(0.05, 0.03, 0.07, 0.28)
    _prompt_style.shadow_size = 4
    prompt.add_theme_stylebox_override("normal", _prompt_style)
    add_child(prompt)

func _process(delta: float) -> void:
    if not active:
        return
    pulse += delta
    if prompt != null:
        var s: float = 1.0 + sin(pulse * 3.0) * 0.06
        prompt.scale = Vector2(s, s)
    queue_redraw()

func _draw() -> void:
    var lift: float = sin(pulse * 3.0) * 2.6
    var glow: float = 0.14 + (sin(pulse * 3.0) + 1.0) * 0.06
    var center: Vector2 = Vector2(0.0, -16.0 + lift)

    draw_circle(center, 21.0, Color(1.0, 0.90, 0.46, glow))
    draw_circle(center, 12.0, Color(1.0, 0.83, 0.23, 0.90))
    draw_circle(center, 5.0, Color(1.0, 0.98, 0.82, 0.99))

    _draw_item_icon(center)

    var sparkle_alpha: float = 0.60 + (sin(pulse * 5.0) + 1.0) * 0.18
    draw_line(center + Vector2(-20.0, 0.0), center + Vector2(-13.0, 0.0), Color(1.0, 0.96, 0.76, sparkle_alpha), 1.5)
    draw_line(center + Vector2(20.0, 0.0), center + Vector2(13.0, 0.0), Color(1.0, 0.96, 0.76, sparkle_alpha), 1.5)
    draw_line(center + Vector2(0.0, -21.0), center + Vector2(0.0, -14.0), Color(1.0, 0.96, 0.76, sparkle_alpha), 1.5)
    draw_line(center + Vector2(-5.0, -17.0), center + Vector2(-2.0, -14.0), Color(1.0, 0.96, 0.76, sparkle_alpha * 0.75), 1.2)

func _draw_item_icon(center: Vector2) -> void:
    match marker_id:
        "notebook":
            draw_rect(Rect2(center + Vector2(-7.0, -8.0), Vector2(14.0, 16.0)), Color("#fff6dc"), true)
            draw_line(center + Vector2(-4.0, -4.0), center + Vector2(4.0, -4.0), Color("#c29e74"), 1.0)
            draw_line(center + Vector2(-4.0, 0.0), center + Vector2(5.0, 0.0), Color("#c29e74"), 1.0)
            draw_line(center + Vector2(-4.0, 4.0), center + Vector2(2.0, 4.0), Color("#c29e74"), 1.0)
        "table_order":
            draw_circle(center + Vector2(0.0, 1.0), 8.0, Color("#f5dfc1"))
            draw_circle(center + Vector2(0.0, 1.0), 4.0, Color("#e99b6b"))
            draw_line(center + Vector2(-7.0, 9.0), center + Vector2(-9.0, 12.0), Color("#8c6048"), 1.6)
            draw_line(center + Vector2(7.0, 9.0), center + Vector2(9.0, 12.0), Color("#8c6048"), 1.6)
        "ball", "ball_delivered":
            draw_circle(center, 8.0, Color("#eef3ff"))
            draw_arc(center, 8.0, 0.0, TAU, 18, Color("#7b8ed1"), 1.4)
            draw_line(center + Vector2(-4.0, -6.0), center + Vector2(4.0, 6.0), Color("#7b8ed1"), 1.0)
        "cone":
            var tri: PackedVector2Array = PackedVector2Array([
                center + Vector2(0.0, -9.0),
                center + Vector2(7.0, 8.0),
                center + Vector2(-7.0, 8.0)
            ])
            draw_colored_polygon(tri, Color("#f27c5a"))
            draw_line(center + Vector2(-5.0, 2.0), center + Vector2(5.0, 2.0), Color("#ffe2a6"), 2.0)
        "id_card":
            draw_rect(Rect2(center + Vector2(-9.0, -6.0), Vector2(18.0, 12.0)), Color("#eef4ff"), true)
            draw_circle(center + Vector2(-4.0, -1.0), 2.0, Color("#8aa5c9"))
            draw_line(center + Vector2(0.0, -2.0), center + Vector2(6.0, -2.0), Color("#9faac0"), 1.0)
            draw_line(center + Vector2(0.0, 2.0), center + Vector2(6.0, 2.0), Color("#9faac0"), 1.0)
        "bottle":
            draw_rect(Rect2(center + Vector2(-5.0, -5.0), Vector2(10.0, 13.0)), Color("#9ddcf1"), true)
            draw_rect(Rect2(center + Vector2(-3.0, -8.0), Vector2(6.0, 4.0)), Color("#d6f5ff"), true)
            draw_line(center + Vector2(-3.0, 1.0), center + Vector2(3.0, 1.0), Color("#6db8d6"), 1.0)
        "cap":
            draw_arc(center + Vector2(0.0, 1.0), 8.0, PI, TAU, 12, Color("#da7b86"), 3.0)
            draw_line(center + Vector2(-8.0, 1.0), center + Vector2(8.0, 1.0), Color("#c55e6e"), 2.0)
        _:
            draw_circle(center, 7.0, Color("#ffe6a8"))
