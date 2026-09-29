extends Control

const BG_PATH = "res://assets/backgrounds/plain_menu_bg.png"
const TITLE_PATH = "res://assets/ui/credits/credits_title.png"
const GOLD = Color("#d8bb72")
const GOLD_BRIGHT = Color("#f3dea8")
const CREAM = Color("#f3e5be")
const MUTED = Color("#ccb992")
const PANEL = Color(0.035, 0.018, 0.012, 0.58)

func _ready() -> void:
    _build_ui()

func _build_ui() -> void:
    var bg = TextureRect.new()
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    bg.texture = load(BG_PATH)
    bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(bg)

    var overlay = ColorRect.new()
    overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    overlay.color = Color(0.01, 0.005, 0.003, 0.36)
    overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(overlay)

    var panel = Panel.new()
    panel.position = Vector2(205, 45)
    panel.size = Vector2(870, 625)
    panel.add_theme_stylebox_override("panel", _panel_style(PANEL, Color(0.48, 0.37, 0.19, 0.70), 18, 1, 20, 0.24))
    add_child(panel)

    var title = TextureRect.new()
    title.position = Vector2(260, 10)
    title.size = Vector2(350, 120)
    title.texture = load(TITLE_PATH)
    title.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    title.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    title.mouse_filter = Control.MOUSE_FILTER_IGNORE
    panel.add_child(title)

    var line = ColorRect.new()
    line.position = Vector2(95, 122)
    line.size = Vector2(680, 1)
    line.color = Color(0.64, 0.53, 0.32, 0.62)
    panel.add_child(line)

    var content = VBoxContainer.new()
    content.position = Vector2(95, 145)
    content.size = Vector2(680, 405)
    content.alignment = BoxContainer.ALIGNMENT_BEGIN
    content.add_theme_constant_override("separation", 5)
    panel.add_child(content)

    _add_heading(content, "GAME DESIGN & DEVELOPMENT")
    _add_body(content, "Wisnu Aldiansyah (Mobile Development)\nMuhammad Rizki Basuki (Mobile Development)\nSilvia Fhadilla Ristianti (Web Development)\nFauzan Evan Febrian (Web Development)", 15, 72)

    _add_spacer(content, 5)
    _add_heading(content, "GRAPHIC DESIGN")
    _add_body(content, "Nindri Nurillahi Rahmi (Art Direction · UI/UX · Visual Design)\nAshya Aurellia Ahshaina (Graphic Design · UI/UX · Character Design)", 15, 58)

    _add_spacer(content, 5)
    _add_heading(content, "TOOLS")
    _add_body(content, "Godot Engine, Aseprite, Canva, LDtk", 15, 28)

    var copyright = Label.new()
    copyright.position = Vector2(0, 542)
    copyright.size = Vector2(870, 28)
    copyright.text = "© 2026 HELLO, STRANGER"
    copyright.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    copyright.add_theme_color_override("font_color", MUTED)
    copyright.add_theme_font_size_override("font_size", 13)
    panel.add_child(copyright)

    var back = Button.new()
    back.position = Vector2(370, 577)
    back.size = Vector2(130, 38)
    back.text = "BACK"
    back.focus_mode = Control.FOCUS_NONE
    back.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    back.add_theme_font_size_override("font_size", 17)
    back.add_theme_color_override("font_color", GOLD_BRIGHT)
    back.add_theme_color_override("font_hover_color", CREAM)
    back.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
    back.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
    back.pressed.connect(_on_back_pressed)
    panel.add_child(back)

func _add_heading(parent: VBoxContainer, text_value: String) -> void:
    var l = Label.new()
    l.text = text_value
    l.custom_minimum_size = Vector2(680, 28)
    l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    l.add_theme_color_override("font_color", GOLD_BRIGHT)
    l.add_theme_font_size_override("font_size", 18)
    parent.add_child(l)

func _add_body(parent: VBoxContainer, text_value: String, font_size: int, min_height: int) -> void:
    var l = Label.new()
    l.text = text_value
    l.custom_minimum_size = Vector2(680, min_height)
    l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    l.add_theme_color_override("font_color", CREAM)
    l.add_theme_font_size_override("font_size", font_size)
    parent.add_child(l)

func _add_spacer(parent: VBoxContainer, size_value: int) -> void:
    var spacer = Control.new()
    spacer.custom_minimum_size = Vector2(1, size_value)
    parent.add_child(spacer)

func _on_back_pressed() -> void:
    SceneManager.go_to("res://scenes/main/MainMenu.tscn")

func _panel_style(bg: Color, border: Color, radius: int, border_width: int, shadow: int, shadow_alpha: float) -> StyleBoxFlat:
    var s = StyleBoxFlat.new()
    s.bg_color = bg
    s.border_color = border
    s.set_border_width_all(border_width)
    s.set_corner_radius_all(radius)
    s.shadow_color = Color(0, 0, 0, shadow_alpha)
    s.shadow_size = shadow
    return s
