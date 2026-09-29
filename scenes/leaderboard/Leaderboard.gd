extends Control

const GOLD: Color = Color("#edcb78")
const GOLD_SOFT: Color = Color("#f5e2ae")
const CREAM: Color = Color("#fff4d6")
const MUTED: Color = Color(0.96, 0.89, 0.75, 0.72)
const BG_PATH: String = "res://assets/backgrounds/main_menu_bg.png"
const TITLE_PATH: String = "res://assets/custom/ui/leaderboard_title.png"

var rows_root: Control
var status_label: Label
var player_count_label: Label
var refresh_clock: float = 0.0
var request_token: int = 0

func _ready() -> void:
    _build_background()
    _build_board()
    _refresh_from_server()

func _build_background() -> void:
    var bg: TextureRect = TextureRect.new()
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    bg.texture = load(BG_PATH) as Texture2D
    bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(bg)

    var shade: ColorRect = ColorRect.new()
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.color = Color(0.10, 0.045, 0.018, 0.40)
    shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(shade)

func _build_board() -> void:
    var title: TextureRect = TextureRect.new()
    title.position = Vector2(100, -32)
    title.size = Vector2(1080, 275)
    title.texture = load(TITLE_PATH) as Texture2D
    title.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    title.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    title.mouse_filter = Control.MOUSE_FILTER_IGNORE
    title.z_index = 2
    add_child(title)

    var subtitle: Label = _label(Vector2(250, 111), Vector2(780, 24), "LIVE SCORE • QUEST 1–7 • TOTAL TIME", 9, MUTED)
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.z_index = 3

    var live: Label = _label(Vector2(1065, 18), Vector2(170, 24), "• LIVE • 2s", 9, GOLD_SOFT)
    live.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    live.z_index = 3

    var board: Panel = _glass_panel(Vector2(62, 145), Vector2(1156, 500), Color(0.10, 0.048, 0.020, 0.60), Color(0.93, 0.77, 0.46, 0.45), 28)
    board.z_index = 1

    var note: Label = _child_label(board, Vector2(24, 14), Vector2(1108, 20), "Semakin cepat dan semakin banyak quest selesai, semakin tinggi score.", 9, MUTED)
    note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

    var table: Panel = _child_panel(board, Vector2(20, 46), Vector2(1116, 392), Color(0.05, 0.022, 0.010, 0.28), Color(0.93, 0.77, 0.48, 0.16), 18)

    _header(table, "PLAYER", Vector2(18, 12), Vector2(245, 26))
    _header(table, "SCORE", Vector2(270, 12), Vector2(115, 26))
    for i in 7:
        _header(table, "Q%d" % (i + 1), Vector2(390 + i * 66, 12), Vector2(66, 26))
    _header(table, "TIME", Vector2(855, 12), Vector2(110, 26))
    _header(table, "DAY", Vector2(970, 12), Vector2(126, 26))

    rows_root = Control.new()
    rows_root.position = Vector2(12, 49)
    rows_root.size = Vector2(1092, 330)
    rows_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    table.add_child(rows_root)

    status_label = _label(Vector2(54, 666), Vector2(760, 22), "LAN OFFLINE • local fallback", 9, GOLD_SOFT)
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    status_label.add_theme_color_override("font_shadow_color", Color(1.0, 0.75, 0.30, 0.78))
    status_label.add_theme_constant_override("shadow_offset_x", 0)
    status_label.add_theme_constant_override("shadow_offset_y", 0)
    player_count_label = _label(Vector2(950, 666), Vector2(270, 22), "0 players", 9, GOLD)
    player_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    player_count_label.add_theme_color_override("font_shadow_color", Color(1.0, 0.75, 0.30, 0.82))
    player_count_label.add_theme_constant_override("shadow_offset_x", 0)
    player_count_label.add_theme_constant_override("shadow_offset_y", 0)

    var refresh: Button = _button(board, "REFRESH", Vector2(892, 459), Vector2(112, 30), 9)
    refresh.pressed.connect(_refresh_from_server)
    var back: Button = _button(board, "BACK", Vector2(1014, 459), Vector2(94, 30), 9)
    back.pressed.connect(_on_back_pressed)


func _refresh_from_server() -> void:
    request_token += 1
    var token: int = request_token
    GameState.get_leaderboard(Callable(self, "_on_leaderboard_received").bind(token))

func _on_leaderboard_received(entries: Array, online: bool, token: int) -> void:
    if token != request_token:
        return
    if not is_instance_valid(self):
        return
    if rows_root == null or not is_instance_valid(rows_root):
        return
    _render(entries)
    if status_label != null and is_instance_valid(status_label):
        status_label.text = "LAN SYNC ONLINE • auto refresh 2 detik" if online else "LAN OFFLINE • local fallback"

func _sort_entries(a: Dictionary, b: Dictionary) -> bool:
    var score_a: int = int(a.get("score", 0))
    var score_b: int = int(b.get("score", 0))
    if score_a == score_b:
        return float(a.get("time", 999999.0)) < float(b.get("time", 999999.0))
    return score_a > score_b

func _on_back_pressed() -> void:
    SceneManager.go_to("res://scenes/main/MainMenu.tscn")

func _render(entries: Array) -> void:
    if rows_root == null or not is_instance_valid(rows_root):
        return
    _clear_rows()

    var sorted_entries: Array = entries.duplicate()
    sorted_entries.sort_custom(Callable(self, "_sort_entries"))
    if player_count_label != null and is_instance_valid(player_count_label):
        player_count_label.text = "%d player%s" % [sorted_entries.size(), "" if sorted_entries.size() == 1 else "s"]

    if sorted_entries.is_empty():
        var empty: Label = _child_label(rows_root, Vector2(0, 24), Vector2(1092, 45), "Belum ada save. Jadilah stranger pertama. ✦", 11, MUTED)
        empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        return

    var shown: int = mini(7, sorted_entries.size())
    for i in shown:
        var value: Variant = sorted_entries[i]
        if value is Dictionary:
            _add_row(value as Dictionary, i)

func _clear_rows() -> void:
    var old_children: Array[Node] = rows_root.get_children()
    for child: Node in old_children:
        rows_root.remove_child(child)
        child.queue_free()

func _add_row(entry: Dictionary, index: int) -> void:
    var row: Panel = Panel.new()
    row.position = Vector2(0, index * 45)
    row.size = Vector2(1092, 39)
    var is_current: bool = str(entry.get("name", "")) == GameState.player_name and not GameState.player_name.is_empty()
    var row_bg: Color = Color(0.22, 0.11, 0.045, 0.42) if is_current else Color(0.16, 0.075, 0.028, 0.24)
    var row_border: Color = Color(0.94, 0.78, 0.48, 0.42) if is_current else Color(0.94, 0.78, 0.48, 0.12)
    row.add_theme_stylebox_override("panel", _style(row_bg, row_border, 10, 1, 2))
    rows_root.add_child(row)

    var name_value: String = str(entry.get("name", "STRANGER"))
    if is_current:
        name_value = "YOU • " + name_value
    _cell(row, name_value, Vector2(14, 1), Vector2(245, 37), 10, CREAM).horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    _cell(row, "%d" % int(entry.get("score", 0)), Vector2(270, 1), Vector2(115, 37), 13, GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

    var quest_count: int = int(entry.get("quest_count", 0))
    var quests_value: Variant = entry.get("quests", quest_count)
    if quests_value is Array:
        quest_count = (quests_value as Array).size()
    elif quests_value is int:
        quest_count = int(quests_value)
    elif quests_value is float:
        quest_count = int(quests_value)

    for i in 7:
        var done: bool = i < quest_count
        var mark_color: Color = GOLD if done else Color(0.95, 0.86, 0.70, 0.18)
        var mark: Label = _cell(row, "✦" if done else "·", Vector2(390 + i * 66, 1), Vector2(66, 37), 12, mark_color)
        mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

    var time_label: Label = _cell(row, "%0.1fs" % float(entry.get("time", 0.0)), Vector2(855, 1), Vector2(110, 37), 9, MUTED)
    time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    var day_label: Label = _cell(row, "%d / 7" % mini(int(entry.get("day", 1)), 7), Vector2(970, 1), Vector2(122, 37), 9, MUTED)
    day_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _cell(parent: Control, text_value: String, pos: Vector2, size_value: Vector2, font_size: int, color: Color) -> Label:
    return _child_label(parent, pos, size_value, text_value, font_size, color)

func _header(parent: Control, text_value: String, pos: Vector2, size_value: Vector2) -> void:
    var label: Label = _child_label(parent, pos, size_value, text_value, 8, Color(0.98, 0.88, 0.66, 0.82))
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _label(pos: Vector2, size_value: Vector2, text_value: String, font_size: int, color: Color) -> Label:
    return _child_label(self, pos, size_value, text_value, font_size, color)

func _child_label(parent: Control, pos: Vector2, size_value: Vector2, text_value: String, font_size: int, color: Color) -> Label:
    var label: Label = Label.new()
    label.position = pos
    label.size = size_value
    label.text = text_value
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    label.add_theme_color_override("font_shadow_color", Color(0.08, 0.03, 0.01, 0.92))
    label.add_theme_constant_override("shadow_offset_x", 1)
    label.add_theme_constant_override("shadow_offset_y", 1)
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(label)
    return label

func _child_panel(parent: Control, pos: Vector2, size_value: Vector2, bg: Color, border: Color, radius: int) -> Panel:
    var panel: Panel = Panel.new()
    panel.position = pos
    panel.size = size_value
    panel.add_theme_stylebox_override("panel", _style(bg, border, radius, 1, 5))
    parent.add_child(panel)
    return panel

func _glass_panel(pos: Vector2, size_value: Vector2, bg: Color, border: Color, radius: int) -> Panel:
    return _child_panel(self, pos, size_value, bg, border, radius)

func _button(parent: Control, text_value: String, pos: Vector2, size_value: Vector2, font_size: int) -> Button:
    var button: Button = Button.new()
    button.position = pos
    button.size = size_value
    button.text = text_value
    button.focus_mode = Control.FOCUS_NONE
    button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    button.add_theme_font_size_override("font_size", font_size)
    button.add_theme_color_override("font_color", CREAM)
    button.add_theme_color_override("font_hover_color", GOLD_SOFT)
    button.add_theme_stylebox_override("normal", _style(Color(0.16, 0.075, 0.028, 0.48), Color(0.93, 0.77, 0.46, 0.22), 10, 1, 3))
    button.add_theme_stylebox_override("hover", _style(Color(0.24, 0.12, 0.045, 0.72), Color(0.98, 0.84, 0.60, 0.58), 10, 1, 5))
    parent.add_child(button)
    return button

func _style(bg: Color, border: Color, radius: int, width: int, shadow: int) -> StyleBoxFlat:
    var style: StyleBoxFlat = StyleBoxFlat.new()
    style.bg_color = bg
    style.border_color = border
    style.set_border_width_all(width)
    style.set_corner_radius_all(radius)
    style.shadow_color = Color(0.08, 0.035, 0.01, 0.30)
    style.shadow_size = shadow
    style.shadow_offset = Vector2(0, 3)
    return style

func _exit_tree() -> void:
    request_token += 1

func _process(delta: float) -> void:
    refresh_clock += delta
    if refresh_clock >= 2.0:
        refresh_clock = 0.0
        _refresh_from_server()
