extends Control

const BG_PATH: String = "res://assets/backgrounds/plain_menu_bg.png"
const GOLD: Color = Color("#edcb78")
const GOLD_LIGHT: Color = Color("#f8e7b9")
const CREAM: Color = Color("#fff4d7")
const MUTED: Color = Color(0.95, 0.88, 0.73, 0.74)
const PANEL: Color = Color(0.12, 0.06, 0.03, 0.72)

var master_slider: HSlider
var music_slider: HSlider
var sfx_slider: HSlider
var fullscreen_toggle: CheckButton
var guide_toggle: CheckButton
var autosave_toggle: CheckButton
var server_input: LineEdit
var status_label: Label

func _ready() -> void:
    _build_ui()
    _load_values()

func _build_ui() -> void:
    var bg: TextureRect = TextureRect.new()
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    bg.texture = load(BG_PATH) as Texture2D
    bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(bg)

    var tint: ColorRect = ColorRect.new()
    tint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    tint.color = Color(0.20, 0.09, 0.03, 0.16)
    tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(tint)

    var grid: Control = preload("res://scripts/ui/GlassGrid.gd").new() as Control
    grid.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    grid.modulate.a = 0.10
    grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(grid)

    var panel: Panel = Panel.new()
    panel.position = Vector2(300, 60)
    panel.size = Vector2(680, 620)
    panel.add_theme_stylebox_override("panel", _style(PANEL, Color(0.92, 0.76, 0.48, 0.52), 30, 2, 18))
    add_child(panel)

    var title: Label = _label(panel, Vector2(30, 18), Vector2(620, 42), "✦  SETTINGS  ✦", 27, GOLD_LIGHT)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    var sub: Label = _label(panel, Vector2(70, 58), Vector2(540, 28), "Yang kepake buat main. Nggak ada filler.", 10, MUTED)
    sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

    _section(panel, "AUDIO", 100)
    _audio_row(panel, "Master Volume", master_slider, 137, "master")
    _audio_row(panel, "Music", music_slider, 173, "music")
    _audio_row(panel, "Sound Effects", sfx_slider, 209, "sfx")

    _section(panel, "DISPLAY", 255)
    _label(panel, Vector2(52, 285), Vector2(180, 26), "Fullscreen", 12, CREAM)
    fullscreen_toggle = CheckButton.new()
    fullscreen_toggle.position = Vector2(244, 282)
    fullscreen_toggle.size = Vector2(130, 34)
    fullscreen_toggle.text = "ON / OFF"
    fullscreen_toggle.add_theme_font_size_override("font_size", 11)
    fullscreen_toggle.toggled.connect(_on_fullscreen)
    panel.add_child(fullscreen_toggle)

    _section(panel, "GAMEPLAY", 327)
    _label(panel, Vector2(52, 357), Vector2(180, 26), "Guide Arrow", 12, CREAM)
    guide_toggle = CheckButton.new()
    guide_toggle.position = Vector2(244, 354)
    guide_toggle.size = Vector2(130, 34)
    guide_toggle.text = "ON / OFF"
    guide_toggle.add_theme_font_size_override("font_size", 11)
    panel.add_child(guide_toggle)

    _label(panel, Vector2(430, 357), Vector2(150, 26), "Auto Save", 12, CREAM)
    autosave_toggle = CheckButton.new()
    autosave_toggle.position = Vector2(530, 354)
    autosave_toggle.size = Vector2(112, 34)
    autosave_toggle.text = "ON / OFF"
    autosave_toggle.add_theme_font_size_override("font_size", 11)
    panel.add_child(autosave_toggle)

    _section(panel, "CONTROLS", 382)
    _label(panel, Vector2(52, 414), Vector2(125, 26), "Movement", 11, CREAM)
    _label(panel, Vector2(165, 414), Vector2(135, 26), "WASD / ARROWS", 10, GOLD_LIGHT)
    _label(panel, Vector2(320, 414), Vector2(105, 26), "Interact", 11, CREAM)
    _label(panel, Vector2(405, 414), Vector2(80, 26), "E", 12, GOLD_LIGHT)
    _label(panel, Vector2(490, 414), Vector2(80, 26), "Save", 11, CREAM)
    _label(panel, Vector2(540, 414), Vector2(70, 26), "F5", 12, GOLD_LIGHT)

    _section(panel, "EXHIBITION / LAN", 445)
    _label(panel, Vector2(52, 475), Vector2(150, 26), "Server URL", 12, CREAM)
    server_input = LineEdit.new()
    server_input.position = Vector2(200, 470)
    server_input.size = Vector2(420, 40)
    server_input.placeholder_text = "http://192.168.x.x:8765"
    server_input.add_theme_font_size_override("font_size", 11)
    server_input.add_theme_color_override("font_color", CREAM)
    server_input.add_theme_stylebox_override("normal", _line_style(Color(0.07, 0.03, 0.015, 0.58), Color(0.92, 0.74, 0.45, 0.30), 11, 1))
    server_input.add_theme_stylebox_override("focus", _line_style(Color(0.10, 0.05, 0.02, 0.74), GOLD, 11, 1))
    panel.add_child(server_input)

    var lan_note: Label = _label(panel, Vector2(70, 514), Vector2(540, 42), "PC C: jalankan server • PC A/B: isi IP PC C • leaderboard refresh otomatis", 9, MUTED)
    lan_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    lan_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

    status_label = _label(panel, Vector2(55, 544), Vector2(570, 24), "", 9, Color("#ead9a2"))
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

    var reset: Button = _button(panel, "RESET DEFAULT", Vector2(55, 575), Vector2(175, 38), 10)
    reset.pressed.connect(_reset_defaults)
    var save: Button = _button(panel, "SAVE SETTINGS", Vector2(250, 575), Vector2(180, 38), 10)
    save.pressed.connect(_save_settings)
    var back: Button = _button(panel, "BACK", Vector2(450, 575), Vector2(125, 38), 10)
    back.pressed.connect(_on_back_pressed)

func _section(panel: Panel, text_value: String, y: float) -> void:
    var label: Label = _label(panel, Vector2(52, y), Vector2(150, 18), text_value, 9, GOLD)
    var line: ColorRect = ColorRect.new()
    line.position = Vector2(180, y + 8)
    line.size = Vector2(440, 1)
    line.color = Color(0.92, 0.76, 0.48, 0.22)
    line.mouse_filter = Control.MOUSE_FILTER_IGNORE
    panel.add_child(line)

func _audio_row(panel: Panel, text_value: String, slider: HSlider, y: float, key_name: String) -> void:
    _label(panel, Vector2(52, y), Vector2(165, 26), text_value, 12, CREAM)
    slider = HSlider.new()
    slider.position = Vector2(220, y - 3)
    slider.size = Vector2(390, 30)
    slider.min_value = 0.0
    slider.max_value = 100.0
    slider.step = 1.0
    if key_name == "master":
        master_slider = slider
        slider.value_changed.connect(_on_master_volume)
    elif key_name == "music":
        music_slider = slider
        slider.value_changed.connect(_on_music_volume)
    else:
        sfx_slider = slider
        slider.value_changed.connect(_on_sfx_volume)
    panel.add_child(slider)

func _load_values() -> void:
    master_slider.value = GameState.master_volume * 100.0
    music_slider.value = GameState.music_volume * 100.0
    sfx_slider.value = GameState.sfx_volume * 100.0
    fullscreen_toggle.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
    guide_toggle.button_pressed = GameState.show_guide_arrow
    autosave_toggle.button_pressed = GameState.auto_save
    server_input.text = GameState.get_server_url()

func _on_master_volume(value: float) -> void:
    GameState.master_volume = clampf(value / 100.0, 0.0, 1.0)
    GameState._apply_audio_settings()

func _on_music_volume(value: float) -> void:
    GameState.music_volume = clampf(value / 100.0, 0.0, 1.0)
    GameState._apply_audio_settings()

func _on_sfx_volume(value: float) -> void:
    GameState.sfx_volume = clampf(value / 100.0, 0.0, 1.0)
    GameState._apply_audio_settings()

func _on_fullscreen(enabled: bool) -> void:
    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED)

func _save_settings() -> void:
    GameState.show_guide_arrow = guide_toggle.button_pressed
    GameState.auto_save = autosave_toggle.button_pressed
    GameState.set_server_url(server_input.text.strip_edges())
    GameState.save_settings()
    status_label.text = "SETTINGS SAVED • LAN: " + GameState.get_server_status_text()

func _reset_defaults() -> void:
    GameState.master_volume = 0.85
    GameState.music_volume = 0.70
    GameState.sfx_volume = 0.85
    GameState.show_guide_arrow = true
    GameState.auto_save = true
    master_slider.value = 85.0
    music_slider.value = 70.0
    sfx_slider.value = 85.0
    guide_toggle.button_pressed = true
    autosave_toggle.button_pressed = true
    GameState.save_settings()
    status_label.text = "DEFAULT SETTINGS RESTORED"

func _on_back_pressed() -> void:
    SceneManager.go_to("res://scenes/main/MainMenu.tscn")

func _label(parent: Control, pos: Vector2, size_value: Vector2, text_value: String, font_size: int, color: Color) -> Label:
    var label: Label = Label.new()
    label.position = pos
    label.size = size_value
    label.text = text_value
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(label)
    return label

func _button(parent: Control, text_value: String, pos: Vector2, size_value: Vector2, font_size: int) -> Button:
    var b: Button = Button.new()
    b.position = pos
    b.size = size_value
    b.text = text_value
    b.focus_mode = Control.FOCUS_NONE
    b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    b.add_theme_font_size_override("font_size", font_size)
    b.add_theme_color_override("font_color", CREAM)
    b.add_theme_color_override("font_hover_color", GOLD_LIGHT)
    b.add_theme_stylebox_override("normal", _style(Color(0.15, 0.075, 0.03, 0.56), Color(0.92, 0.76, 0.46, 0.26), 12, 1, 4))
    b.add_theme_stylebox_override("hover", _style(Color(0.21, 0.11, 0.045, 0.72), Color(0.98, 0.84, 0.60, 0.58), 12, 1, 6))
    parent.add_child(b)
    return b

func _line_style(bg: Color, border: Color, radius: int, width: int) -> StyleBoxFlat:
    var style: StyleBoxFlat = StyleBoxFlat.new()
    style.bg_color = bg
    style.border_color = border
    style.set_border_width_all(width)
    style.set_corner_radius_all(radius)
    return style

func _style(bg: Color, border: Color, radius: int, width: int, shadow: int) -> StyleBoxFlat:
    var style: StyleBoxFlat = StyleBoxFlat.new()
    style.bg_color = bg
    style.border_color = border
    style.set_border_width_all(width)
    style.set_corner_radius_all(radius)
    style.shadow_color = Color(0.10, 0.04, 0.01, 0.32)
    style.shadow_size = shadow
    style.shadow_offset = Vector2(0, 3)
    return style
