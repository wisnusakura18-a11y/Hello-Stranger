extends Area2D

const TARGET_WORLD_HEIGHT: float = 17.0
const INTERACT_SCALE: float = 1.03
const NAME_COLOR: Color = Color("#fff0c2")
const ROLE_COLOR: Color = Color(1.0, 0.84, 0.60, 0.72)

var npc_id: String = ""
var display_name: String = "NPC"
var role: String = ""
var location: String = ""
var sprite: Sprite2D
var name_label: Label
var role_label: Label
var quest_badge: Label
var _base_scale: Vector2 = Vector2.ONE
var _was_near: bool = false

func setup(data: Dictionary) -> void:
    npc_id = str(data.get("id", ""))
    display_name = str(data.get("name", "NPC"))
    role = str(data.get("role", ""))
    location = str(data.get("location", ""))
    var path: String = str(data.get("texture", ""))

    sprite = Sprite2D.new()
    sprite.name = "Character"
    sprite.texture = load(path) as Texture2D
    sprite.hframes = 3
    sprite.vframes = 1
    sprite.frame = 0
    sprite.position = Vector2(0.0, -4.5)
    _fit_sprite_to_target()
    sprite.z_index = 4
    add_child(sprite)

    name_label = _make_label(display_name, Vector2.ZERO, Vector2(130.0, 20.0), 15, NAME_COLOR)
    name_label.scale = Vector2(0.10, 0.10)
    name_label.z_index = 20
    add_child(name_label)

    role_label = _make_label(role, Vector2.ZERO, Vector2(100.0, 12.0), 5, ROLE_COLOR)
    role_label.top_level = true
    role_label.visible = false
    add_child(role_label)

    # Interaction badges live in the HUD now, so characters stay visually clean.
    quest_badge = null

    set_meta("location", location)
    set_meta("npc_id", npc_id)
    set_meta("display_name", display_name)
    _update_label_position()

func _process(_delta: float) -> void:
    _update_label_position()

func _update_label_position() -> void:
    if name_label != null and is_instance_valid(name_label):
        var frame_world_height: float = 0.0
        if sprite != null and sprite.texture != null:
            var frame_height: float = float(sprite.texture.get_height()) / float(maxi(1, sprite.vframes))
            frame_world_height = frame_height * sprite.scale.y
        var label_world_height: float = name_label.size.y * name_label.scale.y
        name_label.position = Vector2(-name_label.size.x * name_label.scale.x * 0.5, sprite.position.y - frame_world_height * 0.5 - label_world_height - 0.5)
    if role_label != null and is_instance_valid(role_label):
        role_label.global_position = global_position + Vector2(-10.0, -8.0)

func _make_label(value: String, pos: Vector2, size_value: Vector2, font_size: int, color: Color) -> Label:
    var label: Label = Label.new()
    label.position = pos
    label.size = size_value
    label.text = value
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.add_theme_color_override("font_color", color)
    label.add_theme_color_override("font_shadow_color", Color(0.10, 0.05, 0.02, 0.95))
    label.add_theme_color_override("font_outline_color", Color(0.10, 0.05, 0.02, 0.90))
    label.add_theme_constant_override("shadow_offset_x", 1)
    label.add_theme_constant_override("shadow_offset_y", 1)
    label.add_theme_constant_override("outline_size", 1)
    label.add_theme_font_size_override("font_size", font_size)
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    return label

func _fit_sprite_to_target() -> void:
    if sprite == null or sprite.texture == null:
        return
    var frame_height: float = float(sprite.texture.get_height()) / float(maxi(1, sprite.vframes))
    var fitted_scale: float = TARGET_WORLD_HEIGHT / maxf(1.0, frame_height)
    _base_scale = Vector2(fitted_scale, fitted_scale)
    sprite.scale = _base_scale

func set_quest_active(active: bool) -> void:
    # No floating key badge. The current action is shown in the HUD.
    if active:
        modulate = Color(1.05, 1.03, 0.96, 1.0)
    else:
        modulate = Color.WHITE

func set_interact_key(_key_value: String) -> void:
    pass

func set_player_near(near_player: bool) -> void:
    if role_label != null and is_instance_valid(role_label):
        role_label.visible = false
    if sprite == null or _was_near == near_player:
        return
    _was_near = near_player
    var target: Vector2 = _base_scale * (INTERACT_SCALE if near_player else 1.0)
    var tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD)
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(sprite, "scale", target, 0.10)
