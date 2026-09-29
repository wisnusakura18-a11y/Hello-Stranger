extends Control

const GOLD: Color = Color("#edcb78")
const GOLD_LIGHT: Color = Color("#f9e8bb")
const CREAM: Color = Color("#fff4d8")
const MUTED: Color = Color(0.95, 0.88, 0.73, 0.72)
const GIRL_PATH: String = "res://assets/custom/mc/cewe_down.png"
const BOY_PATH: String = "res://assets/custom/mc/cowo_down.png"

@onready var buttons: Array[TextureButton] = [
	$MenuRoot/PlayButton,
	$MenuRoot/LoadButton,
	$MenuRoot/LeaderboardButton,
	$MenuRoot/SettingsButton,
	$MenuRoot/CreditsButton,
	$MenuRoot/ExitButton,
]
@onready var play_button: TextureButton = $MenuRoot/PlayButton
@onready var play_arrow: Polygon2D = $MenuRoot/PlayArrow

const HOVER_SCALE: float = 1.05
var active_button: TextureButton
var status_label: Label
var load_modal: Control
var load_search: LineEdit
var load_status: Label
var load_grid: GridContainer
var load_entries: Array = []
var load_refresh_seconds: float = 0.0

func _ready() -> void:
	status_label = Label.new()
	status_label.position = Vector2(900, 624)
	status_label.size = Vector2(330, 40)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_color_override("font_color", GOLD_LIGHT)
	status_label.add_theme_font_size_override("font_size", 10)
	status_label.z_index = 6
	add_child(status_label)
	for button in buttons:
		button.z_index = 4
		button.scale = Vector2.ONE
		button.mouse_entered.connect(_on_button_hovered.bind(button))
		button.mouse_exited.connect(_on_button_exited.bind(button))
	_set_active_button(play_button)

func _glass_style(bg: Color, border: Color, radius: int, width: int, shadow: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.08, 0.03, 0.01, 0.28)
	style.shadow_size = shadow
	style.shadow_offset = Vector2(0, 3)
	return style

func _on_button_hovered(button: TextureButton) -> void:
	_set_active_button(button)
	_animate_button(button, HOVER_SCALE, 0.10)

func _on_button_exited(button: TextureButton) -> void:
	_animate_button(button, 1.0, 0.08)

func _animate_button(button: TextureButton, target_scale: float, duration: float) -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2.ONE * target_scale, duration)

func _set_active_button(button: TextureButton) -> void:
	active_button = button
	play_arrow.z_index = 5
	play_arrow.visible = true
	var center_y: float = button.position.y + button.size.y * 0.5
	play_arrow.position = Vector2(button.position.x - 26.0, center_y - 8.0)

func _on_play_pressed() -> void:
	GameState.loaded_from_save = false
	SceneManager.go_to("res://scenes/characters/CharacterSetup.tscn")

func _on_load_pressed() -> void:
	_show_load_modal()

func _show_load_modal() -> void:
	if load_modal != null and is_instance_valid(load_modal):
		return
	load_modal = Control.new()
	load_modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	load_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	load_modal.z_index = 20
	add_child(load_modal)

	var dim: ColorRect = ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.12, 0.055, 0.02, 0.60)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	load_modal.add_child(dim)

	var panel: Panel = Panel.new()
	panel.position = Vector2(170, 65)
	panel.size = Vector2(940, 590)
	panel.add_theme_stylebox_override("panel", _glass_style(Color(0.13, 0.065, 0.03, 0.84), Color(0.93, 0.78, 0.48, 0.50), 28, 2, 18))
	load_modal.add_child(panel)

	var title: Label = _modal_label(panel, Vector2(35, 22), Vector2(910, 38), "LOAD YOUR STORY", 24, GOLD_LIGHT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var desc: Label = _modal_label(panel, Vector2(100, 59), Vector2(780, 24), "Pilih save player • search username juga boleh", 10, MUTED)
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	load_search = LineEdit.new()
	load_search.position = Vector2(60, 95)
	load_search.size = Vector2(820, 40)
	load_search.placeholder_text = "⌕  Cari username..."
	load_search.add_theme_font_size_override("font_size", 12)
	load_search.add_theme_color_override("font_color", CREAM)
	load_search.add_theme_stylebox_override("normal", _line_style(Color(0.08, 0.035, 0.015, 0.52), Color(0.90, 0.74, 0.44, 0.32), 12, 1))
	load_search.text_changed.connect(_on_load_search_changed)
	panel.add_child(load_search)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.position = Vector2(42, 150)
	scroll.size = Vector2(856, 340)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)

	load_grid = GridContainer.new()
	load_grid.columns = 3
	load_grid.add_theme_constant_override("h_separation", 12)
	load_grid.add_theme_constant_override("v_separation", 12)
	scroll.add_child(load_grid)

	load_status = _modal_label(panel, Vector2(70, 493), Vector2(840, 24), "Memuat daftar player...", 9, GOLD_LIGHT)
	load_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var close: Button = _glass_button(panel, "CANCEL", Vector2(372, 540), Vector2(196, 34), 10)
	close.pressed.connect(_close_load_modal)

	load_refresh_seconds = 0.0
	GameState.get_player_profiles(Callable(self, "_on_player_profiles_received"))
	load_search.grab_focus()

func _on_player_profiles_received(entries: Array, online: bool) -> void:
	if load_modal == null or not is_instance_valid(load_modal):
		return
	if load_status == null or not is_instance_valid(load_status):
		return
	if load_search == null or not is_instance_valid(load_search):
		return
	load_entries = entries.duplicate()
	if online:
		load_status.text = "%d player ditemukan • server online" % load_entries.size()
	else:
		load_status.text = "%d save lokal • server offline" % load_entries.size()
	_render_load_cards(load_search.text)

func _on_load_search_changed(value: String) -> void:
	_render_load_cards(value)

func _render_load_cards(search_value: String) -> void:
	if load_grid == null or not is_instance_valid(load_grid):
		return
	var old_children: Array[Node] = load_grid.get_children()
	for child: Node in old_children:
		load_grid.remove_child(child)
		child.queue_free()
	var query: String = search_value.strip_edges().to_lower()
	var shown: int = 0
	for value in load_entries:
		if not (value is Dictionary):
			continue
		var entry: Dictionary = value as Dictionary
		var name_value: String = str(entry.get("name", "STRANGER"))
		if not query.is_empty() and not name_value.to_lower().contains(query):
			continue
		_add_load_card(entry)
		shown += 1
	if shown == 0:
		var empty: Label = Label.new()
		empty.custom_minimum_size = Vector2(876, 90)
		empty.text = "Nggak ketemu. Coba username lain."
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		empty.add_theme_font_size_override("font_size", 11)
		empty.add_theme_color_override("font_color", MUTED)
		load_grid.add_child(empty)

func _add_load_card(entry: Dictionary) -> void:
	var card: Panel = Panel.new()
	card.custom_minimum_size = Vector2(270, 96)
	card.add_theme_stylebox_override("panel", _glass_style(Color(0.16, 0.075, 0.03, 0.35), Color(0.93, 0.77, 0.46, 0.24), 16, 1, 5))
	load_grid.add_child(card)

	var avatar: TextureRect = TextureRect.new()
	avatar.position = Vector2(10, 10)
	avatar.size = Vector2(58, 74)
	avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	avatar.texture = _first_frame(str(entry.get("gender", "girl")))
	avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(avatar)

	var name_label: Label = _modal_label(card, Vector2(78, 10), Vector2(190, 24), str(entry.get("name", "STRANGER")), 12, GOLD_LIGHT)
	name_label.clip_text = true
	var _info: Label = _modal_label(card, Vector2(78, 37), Vector2(190, 20), "DAY %d / 7" % mini(int(entry.get("day", 1)), 7), 8, MUTED)
	var _score: Label = _modal_label(card, Vector2(78, 56), Vector2(190, 18), "%d pts • %d quest" % [int(entry.get("score", 0)), int(entry.get("quest_count", entry.get("quests", 0)))], 8, CREAM)

	var pick: Button = Button.new()
	pick.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pick.flat = true
	pick.text = ""
	pick.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	pick.pressed.connect(_on_player_card_pressed.bind(str(entry.get("name", ""))))
	pick.mouse_entered.connect(_on_card_hover.bind(card, true))
	pick.mouse_exited.connect(_on_card_hover.bind(card, false))
	card.add_child(pick)

func _first_frame(gender: String) -> AtlasTexture:
	var path: String = GIRL_PATH if gender == "girl" else BOY_PATH
	var texture: Texture2D = load(path) as Texture2D
	var atlas: AtlasTexture = AtlasTexture.new()
	atlas.atlas = texture
	if texture != null:
		atlas.region = Rect2(0.0, 0.0, texture.get_width() / 6.0, texture.get_height())
	return atlas

func _on_card_hover(card: Panel, active: bool) -> void:
	if card == null or not is_instance_valid(card):
		return
	card.modulate = Color(1.06, 1.02, 0.94, 1.0) if active else Color.WHITE

func _on_player_card_pressed(name_value: String) -> void:
	if name_value.strip_edges().is_empty():
		return
	if load_status == null or not is_instance_valid(load_status):
		return
	load_status.text = "Loading " + name_value + "..."
	GameState.load_game_for_name(name_value, Callable(self, "_on_load_result"))

func _on_load_result(success: bool, message: String) -> void:
	if not is_instance_valid(self):
		return
	if not success:
		if load_status != null and is_instance_valid(load_status):
			load_status.text = message
		return
	_close_load_modal()
	GameState.loaded_from_save = true
	SceneManager.go_to("res://scenes/game/Game.tscn")

func _close_load_modal() -> void:
	if load_modal != null and is_instance_valid(load_modal):
		load_modal.queue_free()
	load_modal = null
	load_search = null
	load_grid = null

func _modal_label(parent: Control, pos: Vector2, size_value: Vector2, text_value: String, font_size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.position = pos
	label.size = size_value
	label.text = text_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _glass_button(parent: Control, text_value: String, pos: Vector2, size_value: Vector2, font_size: int) -> Button:
	var b: Button = Button.new()
	b.position = pos
	b.size = size_value
	b.text = text_value
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_font_size_override("font_size", font_size)
	b.add_theme_color_override("font_color", CREAM)
	b.add_theme_color_override("font_hover_color", GOLD_LIGHT)
	b.add_theme_stylebox_override("normal", _glass_style(Color(0.16, 0.075, 0.03, 0.44), Color(0.92, 0.76, 0.46, 0.28), 11, 1, 5))
	b.add_theme_stylebox_override("hover", _glass_style(Color(0.22, 0.11, 0.045, 0.68), Color(0.98, 0.84, 0.60, 0.56), 11, 1, 7))
	parent.add_child(b)
	return b

func _line_style(bg: Color, border: Color, radius: int, width: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	return style

func _on_leaderboard_pressed() -> void:
	SceneManager.go_to("res://scenes/leaderboard/Leaderboard.tscn")

func _on_settings_pressed() -> void:
	SceneManager.go_to("res://scenes/settings/Settings.tscn")

func _on_credits_pressed() -> void:
	SceneManager.go_to("res://scenes/credits/Credits.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()


func _process(delta: float) -> void:
	if load_modal == null or not is_instance_valid(load_modal):
		return
	load_refresh_seconds += delta
	if load_refresh_seconds >= 3.0:
		load_refresh_seconds = 0.0
		GameState.get_player_profiles(Callable(self, "_on_player_profiles_received"))
