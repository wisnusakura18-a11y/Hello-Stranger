extends Area2D

var item_id: String = ""
var title: String = "Item"
var kind: String = "sparkle"
var pulse: float = 0.0
var collected: bool = false
var item_label: Label

func setup(id_value: String, title_value: String, kind_value: String) -> void:
    item_id = id_value
    title = title_value
    kind = kind_value
    set_meta("id", item_id)
    set_meta("title", title)
    set_meta("kind", kind)
    _build_label()
    if item_label != null:
        item_label.text = title
    item_label.visible = false
    queue_redraw()

func _ready() -> void:
    var shape: CollisionShape2D = CollisionShape2D.new()
    var circle: CircleShape2D = CircleShape2D.new()
    circle.radius = 14.0
    shape.shape = circle
    add_child(shape)
    _build_label()

func _build_label() -> void:
    if item_label != null:
        return
    item_label = Label.new()
    item_label.position = Vector2(-40.0, 9.0)
    item_label.size = Vector2(80.0, 14.0)
    item_label.text = title
    item_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    item_label.add_theme_font_size_override("font_size", 8)
    item_label.scale = Vector2(0.15, 0.15)
    item_label.add_theme_color_override("font_color", Color(1.0, 0.96, 0.82, 0.84))
    item_label.add_theme_color_override("font_shadow_color", Color(0.02, 0.015, 0.04, 0.8))
    item_label.add_theme_constant_override("shadow_offset_x", 1)
    item_label.add_theme_constant_override("shadow_offset_y", 1)
    item_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(item_label)


func set_player_near(near_player: bool) -> void:
    if item_label != null and is_instance_valid(item_label):
        item_label.visible = near_player

func _process(delta: float) -> void:
    if collected:
        return
    pulse += delta
    queue_redraw()

func _draw() -> void:
    if collected:
        return
    var lift: float = sin(pulse * 3.6) * 2.2
    var center: Vector2 = Vector2(0.0, -6.0 + lift)
    var glow_alpha: float = 0.08 + (sin(pulse * 4.0) + 1.0) * 0.05
    draw_circle(center, 11.0, Color(1.0, 0.88, 0.38, glow_alpha))
    draw_circle(center, 7.0, Color(1.0, 0.78, 0.20, 0.24))
    draw_circle(center, 4.5, Color(1.0, 0.96, 0.70, 0.94))

    match kind:
        "book":
            draw_rect(Rect2(center + Vector2(-7.0, -8.0), Vector2(14.0, 16.0)), Color("#f7e8c7"), true)
            draw_line(center + Vector2(-3.0, -5.0), center + Vector2(-3.0, 5.0), Color("#bd8c61"), 1.0)
            draw_line(center + Vector2(0.0, -3.0), center + Vector2(5.0, -3.0), Color("#c8a577"), 1.0)
            draw_line(center + Vector2(0.0, 1.0), center + Vector2(5.0, 1.0), Color("#c8a577"), 1.0)
        "food":
            draw_circle(center, 9.0, Color("#f3cf9d"))
            draw_circle(center + Vector2(0.0, -2.0), 3.2, Color("#db7c65"))
            draw_line(center + Vector2(-7.0, 7.0), center + Vector2(-10.0, 11.0), Color("#8d664f"), 1.4)
            draw_line(center + Vector2(7.0, 7.0), center + Vector2(10.0, 11.0), Color("#8d664f"), 1.4)
        "note":
            draw_rect(Rect2(center + Vector2(-8.0, -6.0), Vector2(16.0, 12.0)), Color("#fff5bd"), true)
            draw_line(center + Vector2(-4.0, -2.0), center + Vector2(4.0, -2.0), Color("#c9ad7c"), 1.0)
            draw_line(center + Vector2(-4.0, 2.0), center + Vector2(2.0, 2.0), Color("#c9ad7c"), 1.0)
        "ball":
            draw_circle(center, 9.0, Color("#eef3ff"))
            draw_arc(center, 8.0, 0.0, TAU, 16, Color("#8796ce"), 1.3)
            draw_line(center + Vector2(-4.0, -6.0), center + Vector2(5.0, 5.0), Color("#8796ce"), 1.0)
        "cone":
            var tri: PackedVector2Array = PackedVector2Array([
                center + Vector2(0.0, -9.0),
                center + Vector2(7.0, 8.0),
                center + Vector2(-7.0, 8.0)
            ])
            draw_colored_polygon(tri, Color("#f28b6d"))
            draw_line(center + Vector2(-5.0, 2.0), center + Vector2(5.0, 2.0), Color("#ffe7b1"), 1.5)
        "id_card":
            draw_rect(Rect2(center + Vector2(-9.0, -6.0), Vector2(18.0, 12.0)), Color("#e9f1fb"), true)
            draw_circle(center + Vector2(-4.0, -1.0), 2.0, Color("#8ca9c9"))
            draw_line(center + Vector2(0.0, -2.0), center + Vector2(6.0, -2.0), Color("#a6b4c6"), 1.0)
            draw_line(center + Vector2(0.0, 2.0), center + Vector2(6.0, 2.0), Color("#a6b4c6"), 1.0)
        "bottle":
            draw_rect(Rect2(center + Vector2(-5.0, -5.0), Vector2(10.0, 13.0)), Color("#9bd9eb"), true)
            draw_rect(Rect2(center + Vector2(-3.0, -8.0), Vector2(6.0, 4.0)), Color("#d4f4ff"), true)
        "cap":
            draw_arc(center + Vector2(0.0, 1.0), 8.0, PI, TAU, 12, Color("#d87885"), 3.0)
            draw_line(center + Vector2(-8.0, 1.0), center + Vector2(8.0, 1.0), Color("#c55d6d"), 2.0)
        "paper":
            draw_rect(Rect2(center + Vector2(-7.0, -9.0), Vector2(14.0, 18.0)), Color("#fff8e9"), true)
            draw_line(center + Vector2(-4.0, -4.0), center + Vector2(4.0, -4.0), Color("#cbbda9"), 1.0)
            draw_line(center + Vector2(-4.0, 0.0), center + Vector2(5.0, 0.0), Color("#cbbda9"), 1.0)
            draw_line(center + Vector2(-4.0, 4.0), center + Vector2(2.0, 4.0), Color("#cbbda9"), 1.0)
        _:
            draw_circle(center, 6.0, Color("#ffe6a7"))

    var sparkle_alpha: float = 0.55 + (sin(pulse * 5.2) + 1.0) * 0.15
    draw_line(center + Vector2(-11.0, 0.0), center + Vector2(-7.0, 0.0), Color(1.0, 0.97, 0.80, sparkle_alpha), 1.4)
    draw_line(center + Vector2(11.0, 0.0), center + Vector2(7.0, 0.0), Color(1.0, 0.97, 0.80, sparkle_alpha), 1.4)
    draw_line(center + Vector2(0.0, -12.0), center + Vector2(0.0, -8.0), Color(1.0, 0.97, 0.80, sparkle_alpha), 1.4)
