extends Control

const BG_PATH = "res://assets/backgrounds/plain_menu_bg.png"
const GIRL_PATH = "res://assets/characters/mc_girl.png"
const BOY_PATH = "res://assets/characters/mc_boy.png"
const NAME_LABEL_PATH = "res://assets/ui/setup/name_label.png"
const START_BUTTON_PATH = "res://assets/ui/setup/start_button.png"

const GOLD = Color("#d8bb72")
const GOLD_BRIGHT = Color("#f3dea8")
const CREAM = Color("#f5e7c0")
const MUTED = Color("#d4c4a2")
const ERROR = Color("#e6a19a")
const SHELL_BG = Color(0.035, 0.018, 0.012, 0.60)
const LEFT_BG = Color(0.055, 0.031, 0.022, 0.52)
const RIGHT_BG = Color(0.035, 0.022, 0.016, 0.46)
const PREVIEW_BG = Color(0.02, 0.012, 0.01, 0.40)

var name_input: LineEdit
var girl_button: Button
var boy_button: Button
var character_frame: Panel
var character_preview: TextureRect
var selection_label: Label
var start_button: TextureButton
var status_label: Label
var selected_gender: String = "girl"

func _ready() -> void:
	_build_ui()
	_select_gender("girl")
	name_input.grab_focus()

func _build_ui() -> void:
	var bg: TextureRect = TextureRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.texture = load(BG_PATH)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var overlay: ColorRect = ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.015, 0.008, 0.006, 0.20)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)

	var back: Button = _make_text_button("‹ BACK", 17)
	back.position = Vector2(48, 34)
	back.size = Vector2(120, 42)
	back.pressed.connect(_on_back_pressed)
	add_child(back)

	var shell = Panel.new()
	shell.position = Vector2(220, 105)
	shell.size = Vector2(840, 545)
	shell.add_theme_stylebox_override("panel", _panel_style(SHELL_BG, Color(0.84, 0.72, 0.45, 0.88), 18, 2, 16, 0.24))
	add_child(shell)

	var left = Panel.new()
	left.position = Vector2(255, 138)
	left.size = Vector2(470, 480)
	left.add_theme_stylebox_override("panel", _panel_style(LEFT_BG, Color(0.44, 0.33, 0.17, 0.60), 14, 1, 10, 0.10))
	add_child(left)

	var right = Panel.new()
	right.position = Vector2(750, 138)
	right.size = Vector2(275, 480)
	right.add_theme_stylebox_override("panel", _panel_style(RIGHT_BG, Color(0.84, 0.72, 0.45, 0.88), 14, 2, 12, 0.16))
	add_child(right)

	var heading = Label.new()
	heading.position = Vector2(0, 18)
	heading.size = Vector2(470, 40)
	heading.text = "Create Your Student"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_color_override("font_color", GOLD_BRIGHT)
	heading.add_theme_font_size_override("font_size", 28)
	left.add_child(heading)

	var sub = Label.new()
	sub.position = Vector2(28, 60)
	sub.size = Vector2(414, 36)
	sub.text = "Seven days. Seven strangers. One new beginning."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_color_override("font_color", MUTED)
	sub.add_theme_font_size_override("font_size", 15)
	left.add_child(sub)

	var name_label = TextureRect.new()
	name_label.position = Vector2(138, 95)
	name_label.size = Vector2(194, 93)
	name_label.texture = load(NAME_LABEL_PATH)
	name_label.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	name_label.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	left.add_child(name_label)

	name_input = LineEdit.new()
	name_input.position = Vector2(58, 190)
	name_input.size = Vector2(354, 54)
	name_input.max_length = 18
	name_input.placeholder_text = "Masukkan namamu..."
	name_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_input.add_theme_color_override("font_color", CREAM)
	name_input.add_theme_color_override("font_placeholder_color", Color(0.80, 0.73, 0.60, 0.70))
	name_input.add_theme_font_size_override("font_size", 19)
	name_input.add_theme_stylebox_override("normal", _line_style(Color(0.035, 0.020, 0.015, 0.82), Color(0.45, 0.33, 0.17, 0.80), 10, 1))
	name_input.add_theme_stylebox_override("focus", _line_style(Color(0.045, 0.024, 0.016, 0.88), GOLD, 10, 2))
	left.add_child(name_input)

	var identity = Label.new()
	identity.position = Vector2(58, 263)
	identity.size = Vector2(354, 28)
	identity.text = "Pilih karaktermu"
	identity.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	identity.add_theme_color_override("font_color", GOLD_BRIGHT)
	identity.add_theme_font_size_override("font_size", 19)
	left.add_child(identity)

	girl_button = _make_choice_button("MC CEWE")
	girl_button.position = Vector2(58, 305)
	girl_button.size = Vector2(170, 52)
	girl_button.pressed.connect(_on_girl_pressed)
	left.add_child(girl_button)

	boy_button = _make_choice_button("MC COWO")
	boy_button.position = Vector2(242, 305)
	boy_button.size = Vector2(170, 52)
	boy_button.pressed.connect(_on_boy_pressed)
	left.add_child(boy_button)

	selection_label = Label.new()
	selection_label.position = Vector2(58, 370)
	selection_label.size = Vector2(354, 34)
	selection_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	selection_label.add_theme_color_override("font_color", MUTED)
	selection_label.add_theme_font_size_override("font_size", 15)
	left.add_child(selection_label)

	start_button = TextureButton.new()
	start_button.position = Vector2(118, 410)
	start_button.size = Vector2(234, 108)
	start_button.texture_normal = load(START_BUTTON_PATH)
	start_button.ignore_texture_size = true
	start_button.stretch_mode = TextureButton.STRETCH_SCALE
	start_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	start_button.tooltip_text = "Mulai permainan"
	start_button.pivot_offset = Vector2(117, 54)
	start_button.mouse_entered.connect(_on_start_hover)
	start_button.mouse_exited.connect(_on_start_exit)
	start_button.pressed.connect(_on_start_pressed)
	left.add_child(start_button)

	status_label = Label.new()
	status_label.position = Vector2(40, 525)
	status_label.size = Vector2(390, 26)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_color_override("font_color", ERROR)
	status_label.add_theme_font_size_override("font_size", 14)
	left.add_child(status_label)

	var preview_title = Label.new()
	preview_title.position = Vector2(20, 17)
	preview_title.size = Vector2(235, 34)
	preview_title.text = "CHARACTER PREVIEW"
	preview_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_title.add_theme_color_override("font_color", GOLD_BRIGHT)
	preview_title.add_theme_font_size_override("font_size", 18)
	right.add_child(preview_title)

	character_frame = Panel.new()
	character_frame.position = Vector2(36, 62)
	character_frame.size = Vector2(203, 337)
	character_frame.add_theme_stylebox_override("panel", _panel_style(PREVIEW_BG, GOLD_BRIGHT, 12, 2, 10, 0.10))
	right.add_child(character_frame)

	character_preview = TextureRect.new()
	character_preview.position = Vector2(12, 10)
	character_preview.size = Vector2(179, 317)
	character_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	character_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	character_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	character_frame.add_child(character_preview)

	var preview_hint = Label.new()
	preview_hint.position = Vector2(22, 410)
	preview_hint.size = Vector2(231, 42)
	preview_hint.text = "Klik pilihan di kiri untuk mengganti\nkarakter utama."
	preview_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_hint.add_theme_color_override("font_color", MUTED)
	preview_hint.add_theme_font_size_override("font_size", 14)
	right.add_child(preview_hint)

func _on_girl_pressed() -> void:
	_select_gender("girl")

func _on_boy_pressed() -> void:
	_select_gender("boy")

func _on_start_hover() -> void:
	_button_pop(start_button, 1.03)

func _on_start_exit() -> void:
	_button_pop(start_button, 1.0)

func _select_gender(gender: String) -> void:
	selected_gender = gender
	GameState.player_gender = gender
	character_preview.texture = load(GIRL_PATH if gender == "girl" else BOY_PATH)
	selection_label.text = "Terpilih: " + ("MC Cewe" if gender == "girl" else "MC Cowo")
	_apply_choice_style(girl_button, gender == "girl")
	_apply_choice_style(boy_button, gender == "boy")

func _apply_choice_style(button: Button, selected: bool) -> void:
	button.add_theme_stylebox_override("normal", _button_style(Color(0.06, 0.035, 0.024, 0.82), GOLD if selected else Color(0.37, 0.28, 0.17, 0.72), 10, 2 if selected else 1))
	button.add_theme_stylebox_override("hover", _button_style(Color(0.11, 0.07, 0.04, 0.90), GOLD_BRIGHT, 10, 2))
	button.add_theme_stylebox_override("pressed", _button_style(Color(0.15, 0.09, 0.05, 0.94), GOLD_BRIGHT, 10, 2))
	button.add_theme_color_override("font_color", GOLD_BRIGHT if selected else MUTED)
	button.add_theme_color_override("font_hover_color", CREAM)

func _on_start_pressed() -> void:
	var entered = name_input.text.strip_edges()
	if entered.is_empty():
		status_label.text = "Namamu masih kosong. Isi dulu, stranger."
		name_input.grab_focus()
		return
	GameState.new_game(entered, selected_gender)
	status_label.text = ""
	SceneManager.go_to("res://scenes/game/Game.tscn")

func _on_back_pressed() -> void:
	SceneManager.go_to("res://scenes/main/MainMenu.tscn")

func _button_pop(button: Control, scale_value: float) -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2.ONE * scale_value, 0.10)

func _make_choice_button(text_value: String) -> Button:
	var b = Button.new()
	b.text = text_value
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_font_size_override("font_size", 18)
	return b

func _make_text_button(text_value: String, font_size: int) -> Button:
	var b = Button.new()
	b.text = text_value
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_font_size_override("font_size", font_size)
	b.add_theme_color_override("font_color", MUTED)
	b.add_theme_color_override("font_hover_color", CREAM)
	b.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	b.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	return b

func _panel_style(bg: Color, border: Color, radius: int, border_width: int, shadow: int, shadow_alpha: float) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(border_width)
	s.set_corner_radius_all(radius)
	s.shadow_color = Color(0, 0, 0, shadow_alpha)
	s.shadow_size = shadow
	return s

func _line_style(bg: Color, border: Color, radius: int, border_width: int) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(border_width)
	s.set_corner_radius_all(radius)
	return s

func _button_style(bg: Color, border: Color, radius: int, border_width: int) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(border_width)
	s.set_corner_radius_all(radius)
	return s
