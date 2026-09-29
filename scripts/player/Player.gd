extends CharacterBody2D

const SPEED: float = 28.0
const FRAME_TIME: float = 0.16
const TARGET_WORLD_HEIGHT: float = 17.0
const NAME_COLOR: Color = Color("#fff0c2")

const GIRL_TEXTURES: Dictionary = {
	"down": "res://assets/custom/mc/cewe_down.png",
	"up": "res://assets/custom/mc/cewe_up.png",
	"left": "res://assets/custom/mc/cewe_left.png",
	"right": "res://assets/custom/mc/cewe_right.png"
}
const BOY_TEXTURES: Dictionary = {
	"down": "res://assets/custom/mc/cowo_down.png",
	"up": "res://assets/custom/mc/cowo_up.png",
	"left": "res://assets/custom/mc/cowo_left.png",
	"right": "res://assets/custom/mc/cowo_right.png"
}

var gender: String = "girl"
var locked: bool = false
var facing: String = "down"
var sprite: Sprite2D
var frame_clock: float = 0.0
var player_name_label: Label

func _ready() -> void:
	collision_layer = 1
	collision_mask = 1

	sprite = Sprite2D.new()
	sprite.name = "PlayerSprite"
	sprite.centered = true
	sprite.position = Vector2(0.0, -5.0)
	sprite.z_index = 5
	add_child(sprite)

	player_name_label = Label.new()
	player_name_label.name = "PlayerName"
	player_name_label.size = Vector2(130.0, 20.0)
	player_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	player_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	player_name_label.add_theme_font_size_override("font_size", 15)
	player_name_label.scale = Vector2(0.10, 0.10)
	player_name_label.add_theme_color_override("font_color", NAME_COLOR)
	player_name_label.add_theme_color_override("font_shadow_color", Color(0.10, 0.05, 0.02, 0.95))
	player_name_label.add_theme_constant_override("shadow_offset_x", 1)
	player_name_label.add_theme_constant_override("shadow_offset_y", 1)
	player_name_label.add_theme_constant_override("outline_size", 1)
	player_name_label.add_theme_color_override("font_outline_color", Color(0.10, 0.05, 0.02, 0.90))
	player_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	player_name_label.z_index = 20
	add_child(player_name_label)

	set_gender(GameState.player_gender)
	set_player_name(GameState.player_name)
	_update_name_position()

func set_player_name(value: String) -> void:
	if player_name_label == null:
		return
	var clean: String = value.strip_edges()
	var display_name: String = clean if not clean.is_empty() else "Stranger"
	if display_name.length() > 14:
		display_name = display_name.substr(0, 14) + "…"
	player_name_label.text = display_name
	_update_name_position()

func set_gender(value: String) -> void:
	gender = value if value in ["girl", "boy"] else "girl"
	if sprite == null:
		return
	var paths: Dictionary = GIRL_TEXTURES if gender == "girl" else BOY_TEXTURES
	sprite.texture = load(str(paths.get(facing, paths["down"]))) as Texture2D
	sprite.hframes = 6
	sprite.vframes = 1
	sprite.frame = 0
	_fit_sprite_to_target()

func set_locked(value: bool) -> void:
	locked = value
	if locked:
		velocity = Vector2.ZERO

func _process(_delta: float) -> void:
	_update_name_position()

func _fit_sprite_to_target() -> void:
	if sprite == null or sprite.texture == null:
		return
	var frame_height: float = float(sprite.texture.get_height()) / float(maxi(1, sprite.vframes))
	var fitted_scale: float = TARGET_WORLD_HEIGHT / maxf(1.0, frame_height)
	sprite.scale = Vector2(fitted_scale, fitted_scale)

func _update_name_position() -> void:
	if player_name_label == null or not is_instance_valid(player_name_label):
		return
	var frame_world_height: float = 0.0
	if sprite != null and sprite.texture != null:
		var frame_height: float = float(sprite.texture.get_height()) / float(maxi(1, sprite.vframes))
		frame_world_height = frame_height * sprite.scale.y
	var label_world_height: float = player_name_label.size.y * player_name_label.scale.y
	player_name_label.position = Vector2(-player_name_label.size.x * player_name_label.scale.x * 0.5, sprite.position.y - frame_world_height * 0.5 - label_world_height - 0.5)

func _physics_process(delta: float) -> void:
	if locked:
		velocity = Vector2.ZERO
		return

	var input_x: float = Input.get_axis("ui_left", "ui_right")
	var input_y: float = Input.get_axis("ui_up", "ui_down")
	if Input.is_key_pressed(KEY_A):
		input_x -= 1.0
	if Input.is_key_pressed(KEY_D):
		input_x += 1.0
	if Input.is_key_pressed(KEY_W):
		input_y -= 1.0
	if Input.is_key_pressed(KEY_S):
		input_y += 1.0
	var input_vector: Vector2 = Vector2(clampf(input_x, -1.0, 1.0), clampf(input_y, -1.0, 1.0))
	if input_vector.length() > 0.0:
		input_vector = input_vector.normalized()
		velocity = input_vector * SPEED
		if absf(input_vector.x) > absf(input_vector.y):
			facing = "right" if input_vector.x > 0.0 else "left"
		else:
			facing = "down" if input_vector.y > 0.0 else "up"
		_set_direction_texture()
		frame_clock += delta
		if frame_clock >= FRAME_TIME:
			frame_clock = 0.0
			if sprite != null:
				sprite.frame = (sprite.frame + 1) % 6
	else:
		velocity = Vector2.ZERO
		frame_clock = 0.0
		if sprite != null:
			sprite.frame = 0

	move_and_slide()

func _set_direction_texture() -> void:
	if sprite == null:
		return
	var paths: Dictionary = GIRL_TEXTURES if gender == "girl" else BOY_TEXTURES
	var wanted: Texture2D = load(str(paths[facing])) as Texture2D
	if sprite.texture != wanted:
		sprite.texture = wanted
		sprite.hframes = 6
		sprite.vframes = 1
		sprite.frame = 0
		_fit_sprite_to_target()
