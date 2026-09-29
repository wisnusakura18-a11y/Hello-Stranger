extends Node2D

const WORLD_SCENE: PackedScene = preload("res://scenes/World.tscn")
const NPC_SCENE: PackedScene = preload("res://scenes/npc/NPC.tscn")
const ITEM_SCRIPT: Script = preload("res://scripts/QuestItem.gd")
const GRID_SCRIPT: Script = preload("res://scripts/ui/GlassGrid.gd")
const DIRECTION_ARROW_SCRIPT: Script = preload("res://scripts/ui/DirectionArrow.gd")

const GOLD: Color = Color("#edcb78")
const GOLD_LIGHT: Color = Color("#f9e8bb")

const INTERACT_RADIUS: float = 17.0
const OBJECTIVE_RADIUS: float = 13.0
const MAP_ZOOM: float = 11.25
const DAY_TIMES: Array = [300.0, 270.0, 240.0, 210.0, 180.0, 150.0, 120.0]

const QUESTS: Dictionary = {
	"q1": {
		"day": 1,
		"npc": "bu_imas",
		"title": "Dua Barang yang Nyelip",
		"location": "Kantin",
		"base": 260,
		"steps": [
			{"type": "items", "items": [
				{"id": "q1_notebook", "title": "Buku catatan", "kind": "book", "zone": "field"},
				{"id": "q1_receipt", "title": "Kertas pesanan", "kind": "paper", "zone": "field"}
			]},
			{"type": "optional_question", "question": "Di kantin ada 2 meja. Satu meja dipakai 3 orang, meja lain kosong. Kalau 1 orang dari meja ramai pindah ke meja kosong, berapa orang sekarang di meja kosong?", "options": ["0", "1", "2", "3"], "answer": 1},
			{"type": "return", "npc": "bu_imas"}
		]
	},
	"q2": {
		"day": 2,
		"npc": "bu_veyra",
		"title": "Kelas, Clue, dan Satu Jawaban",
		"location": "Kelas",
		"base": 300,
		"steps": [
			{"type": "items", "items": [
				{"id": "q2_note", "title": "Sticky note hijau", "kind": "note", "zone": "class"},
				{"id": "q2_chalk", "title": "Kapur tulis", "kind": "note", "zone": "class"}
			]},
			{"type": "talk", "npc": "orin"},
			{"type": "question", "question": "Ketua kelas mencatat 5 suara untuk A dan 2 suara untuk B. Dua orang yang memilih B pulang sebelum hasil dibacakan. Siapa yang tetap menang berdasarkan catatan suara yang sudah masuk?", "options": ["A", "B", "Tidak ada"], "answer": 0},
			{"type": "return", "npc": "bu_veyra"}
		]
	},
	"q3": {
		"day": 3,
		"npc": "eira",
		"title": "Pesanan, Meja, dan Tebakannya",
		"location": "Kantin",
		"base": 340,
		"steps": [
			{"type": "items", "items": [
				{"id": "q3_food_a", "title": "Kotak nasi", "kind": "food", "zone": "canteen"},
				{"id": "q3_food_b", "title": "Minuman", "kind": "bottle", "zone": "canteen"}
			]},
			{"type": "talk", "npc": "bu_imas"},
			{"type": "question", "question": "Eira bilang: ‘Pesanan ini bukan untuk meja yang punya warna sama dengan nampannya.’ Ada dua meja, meja merah dan meja biru. Nampannya merah. Jadi pesanan ini untuk meja mana?", "options": ["Merah", "Biru", "Keduanya"], "answer": 1},
			{"type": "return", "npc": "eira"}
		]
	},
	"q4": {
		"day": 4,
		"npc": "sora",
		"title": "Rak Rahasia",
		"location": "Perpustakaan",
		"base": 380,
		"steps": [
			{"type": "items", "items": [
				{"id": "q4_history", "title": "Buku sejarah", "kind": "book", "zone": "library"},
				{"id": "q4_science", "title": "Buku sains", "kind": "book", "zone": "library"},
				{"id": "q4_language", "title": "Buku bahasa", "kind": "book", "zone": "library"}
			]},
			{"type": "talk", "npc": "bu_veyra"},
			{"type": "question", "question": "Di meja ada 3 buku. Satu bukan buku sejarah. Satu bukan buku sains. Kalau setiap buku hanya punya satu kategori dan hanya ada sejarah, sains, bahasa, buku yang tidak bisa disebut sejarah maupun sains termasuk kategori apa?", "options": ["Sejarah", "Sains", "Bahasa"], "answer": 2},
			{"type": "return", "npc": "sora"}
		]
	},
	"q5": {
		"day": 5,
		"npc": "mika",
		"title": "Latihan Belum Dimulai",
		"location": "Lapangan",
		"base": 420,
		"steps": [
			{"type": "talk", "npc": "orin"},
			{"type": "items", "items": [
				{"id": "q5_ball", "title": "Bola latihan", "kind": "ball", "zone": "class"}
			]},
			{"type": "deliver", "zone": "field"},
			{"type": "items", "items": [
				{"id": "q5_cone_a", "title": "Cone 1", "kind": "cone", "zone": "field"},
				{"id": "q5_cone_b", "title": "Cone 2", "kind": "cone", "zone": "field"}
			]},
			{"type": "optional_question", "question": "Di acara sekolah, panitia bilang semua peserta harus melepas sepatu sebelum masuk aula. Kamu datang tanpa sepatu. Apa yang masih harus kamu lepas?", "options": ["Sepatu", "Kaos kaki", "Tidak ada", "Seragam"], "answer": 2},
			{"type": "return", "npc": "mika"}
		]
	},
	"q6": {
		"day": 6,
		"npc": "orin",
		"title": "Deadline dan Lima Potongan",
		"location": "Kelas",
		"base": 460,
		"steps": [
			{"type": "items", "items": [
				{"id": "q6_page_a", "title": "Halaman laporan A", "kind": "paper", "zone": "class"},
				{"id": "q6_page_b", "title": "Halaman laporan B", "kind": "paper", "zone": "class"}
			]},
			{"type": "talk", "npc": "bu_veyra"},
			{"type": "order", "pages": ["Sampul", "Pendahuluan", "Isi", "Kesimpulan", "Daftar Pustaka"]},
			{"type": "question", "question": "Bu Veyra bilang pengumpulan jam 10. Orin bilang dia datang jam 9 dan punya waktu satu jam untuk menyusun. Kalau sekarang tepat jam 9:40, sisa waktunya berapa menit?", "options": ["10", "20", "30"], "answer": 1},
			{"type": "return", "npc": "orin"}
		]
	},
	"q7": {
		"day": 7,
		"npc": "pa_adrian",
		"title": "Tujuh Hari, Tiga Barang, Satu Clue",
		"location": "Kelas",
		"base": 500,
		"steps": [
			{"type": "items", "items": [
				{"id": "q7_card", "title": "Kartu pelajar", "kind": "id_card", "zone": "library"},
				{"id": "q7_bottle", "title": "Botol minum", "kind": "bottle", "zone": "field"},
				{"id": "q7_cap", "title": "Topi", "kind": "cap", "zone": "canteen"}
			]},
			{"type": "talk", "npc": "sora"},
			{"type": "question", "question": "Sora memberi tiga clue: ‘Kartu ada di tempat yang biasanya tenang. Botol bukan di kantin. Topi bukan di perpustakaan.’ Tiga barang ada di tiga tempat berbeda: kantin, lapangan, perpustakaan. Jadi topi ada di mana?", "options": ["Kantin", "Lapangan", "Perpustakaan"], "answer": 0},
			{"type": "return", "npc": "pa_adrian"}
		]
	}
}

const NPC_DATA: Array = [
	{"id": "bu_imas", "name": "Bu Imas", "role": "Ibu Kantin", "location": "Kantin", "texture": "res://assets/custom/npc/BU IMAS.png", "zone": "canteen"},
	{"id": "eira", "name": "Eira", "role": "Siswa", "location": "Kantin", "texture": "res://assets/custom/npc/EIRA.png", "zone": "canteen"},
	{"id": "mika", "name": "Mika", "role": "Siswa", "location": "Lapangan", "texture": "res://assets/custom/npc/MIKA.png", "zone": "field"},
	{"id": "bu_veyra", "name": "Bu Veyra", "role": "Guru", "location": "Kelas", "texture": "res://assets/custom/npc/BU VEYRA.png", "zone": "class"},
	{"id": "orin", "name": "Orin", "role": "Siswa", "location": "Kelas", "texture": "res://assets/custom/npc/ORIN.png", "zone": "class"},
	{"id": "pa_adrian", "name": "Pa Adrian", "role": "Kepala Sekolah", "location": "Kelas", "texture": "res://assets/custom/npc/PA ADRIAN.png", "zone": "class"},
	{"id": "sora", "name": "Sora", "role": "Siswa", "location": "Perpustakaan", "texture": "res://assets/custom/npc/SORA.png", "zone": "library"}
]

const NPC_DIALOGUES: Dictionary = {
	"bu_imas": [
		["Bu Imas", "Eh, maaf. Kayaknya kita belum kenalan."],
		["PLAYER", "Saya baru pindahan. Nama saya {user}."],
		["Bu Imas", "Oh, {user}. Pantesan mukanya masih nyari arah."],
		["PLAYER", "Kelihatan banget ya, Bu?"],
		["Bu Imas", "Sedikit. Tapi santai, semua orang pernah jadi anak baru."],
		["Bu Imas", "Nah, sekalian kamu bisa bantu Ibu cari dua barang yang nyelip?"]
	],
	"bu_veyra": [
		["Bu Veyra", "Pagi. Aku kayaknya belum sempat kenalan sama kamu."],
		["PLAYER", "Saya {user}, Bu. Baru pindahan."],
		["Bu Veyra", "Welcome, {user}. Jangan khawatir kalau belum hafal tempat."],
		["Bu Veyra", "Kalau kamu bingung, tanya orang. Kalau terlalu yakin, kadang malah nyasar."],
		["Bu Veyra", "Ada sedikit urusan kelas yang bisa kamu bantu."]
	],
	"eira": [
		["Eira", "Eh, gue belum pernah lihat lo sebelumnya."],
		["PLAYER", "Gue {user}. Anak baru."],
		["Eira", "Oh. Fair. Gue Eira."],
		["Eira", "Ada pesanan gue yang nyasar. Kayaknya dua barangnya malah kepisah."],
		["PLAYER", "Classic hari sekolah."],
		["Eira", "Nah kan. Lo ngerti."]
	],
	"sora": [
		["Sora", "Kita belum kenal, ya?"],
		["PLAYER", "Belum. Aku {user}."],
		["Sora", "Sora. Kalau suka tempat sepi, perpustakaan aman."],
		["Sora", "Tapi hari ini malah berantakan. Tiga buku hilang dari raknya."]
	],
	"mika": [
		["Mika", "Kamu anak baru yang tadi lewat, kan?"],
		["PLAYER", "Iya. Gue {user}."],
		["Mika", "Mika. Good to know."],
		["Mika", "Gue mau mulai latihan, tapi perlengkapannya kayak punya agenda sendiri."],
		["PLAYER", "Kebetulan gue lagi senggang."],
		["Mika", "Sip. Jangan bilang gue nggak pernah bagi kerjaan."]
	],
	"orin": [
		["Orin", "Bro, kita pernah ketemu belum?"],
		["PLAYER", "Belum. Gue {user}."],
		["Orin", "Ohh anak baru. Orin."],
		["Orin", "Gue lagi dikejar deadline dan kertas gue pada menghilang."],
		["PLAYER", "Sounds healthy."],
		["Orin", "Gue tahu. Very academic."]
	],
	"pa_adrian": [
		["Pa Adrian", "Selamat siang. Sepertinya kita belum sempat berkenalan."],
		["PLAYER", "Saya {user}, Pak. Baru pindahan."],
		["Pa Adrian", "Selamat datang, {user}. Semoga betah."],
		["Pa Adrian", "Bapak sedang mencari tiga barang yang tertinggal."],
		["Pa Adrian", "Setelah kamu temukan semuanya, kembali ke Bapak. Ada satu pertanyaan terakhir."]
	]
}

const FRIENDLY_DIALOGUES: Dictionary = {
	"bu_imas": "Kantin masih buka. Jangan cuma bantu orang, makan juga.",
	"bu_veyra": "Kalau bingung, baca HUD. Dia tidak pernah bohong, cuma suka singkat.",
	"eira": "{user}, kalau pesanan gue nyasar lagi, gue panggil lo pertama.",
	"sora": "Perpustakaan lebih tenang kalau semua orang tidak panik.",
	"mika": "Cone sudah aman. Tinggal jangan diinjak.",
	"orin": "Dokumen gue akhirnya punya urutan. Rare event.",
	"pa_adrian": "Sampai jumpa lagi, {user}."
}

const ZONES: Dictionary = {
	"canteen": [Vector2(72, 430), Vector2(210, 455), Vector2(340, 435), Vector2(145, 485), Vector2(390, 470)],
	"field": [Vector2(70, 330), Vector2(190, 335), Vector2(315, 330), Vector2(420, 350), Vector2(120, 425), Vector2(280, 425), Vector2(395, 430)],
	"class": [Vector2(85, 430), Vector2(215, 430), Vector2(350, 430), Vector2(125, 475), Vector2(285, 475), Vector2(410, 475)],
	"library": [Vector2(275, 410), Vector2(390, 405), Vector2(455, 435), Vector2(330, 475), Vector2(455, 480)]
}

const ITEM_SPOTS: Dictionary = {
	"canteen": [Vector2(72, 430), Vector2(210, 455), Vector2(340, 435), Vector2(145, 485), Vector2(390, 470)],
	"class": [Vector2(85, 430), Vector2(145, 455), Vector2(220, 430), Vector2(305, 455), Vector2(390, 430), Vector2(120, 490)],
	"field": [Vector2(70, 330), Vector2(150, 360), Vector2(240, 335), Vector2(330, 360), Vector2(420, 330), Vector2(125, 425), Vector2(290, 425), Vector2(395, 430)],
	"library": [Vector2(275, 410), Vector2(350, 435), Vector2(420, 410), Vector2(320, 475), Vector2(440, 480)]
}

const PORTRAITS: Dictionary = {
	"Bu Imas": "res://assets/custom/npc/BU IMAS.png",
	"Bu Veyra": "res://assets/custom/npc/BU VEYRA.png",
	"Eira": "res://assets/custom/npc/EIRA.png",
	"Sora": "res://assets/custom/npc/SORA.png",
	"Mika": "res://assets/custom/npc/MIKA.png",
	"Orin": "res://assets/custom/npc/ORIN.png",
	"Pa Adrian": "res://assets/custom/npc/PA ADRIAN.png"
}

var world: Node2D
var player: CharacterBody2D
var npcs: Dictionary = {}
var objective_nodes: Dictionary = {}
var modal: Control
var day_visual: Control
var hud_layer: CanvasLayer
var dialog_box: Panel
var dialog_name: Label
var dialog_text: Label
var dialog_portrait: TextureRect
var hint_label: Label
var goal_label: Label
var timer_label: Label
var score_label: Label
var quest_label: Label
var quest_progress_label: Label
var save_status: Label
var day_label: Label
var run_points_label: Label
var transition_label: Label
var guide_card: Panel
var guide_label: Label
var guide_arrow: Control
var guide_button: Button
var inventory_label: Label
var menu_button: Button
var pause_modal: Control
var pause_settings_modal: Control
var pause_server_input: LineEdit
var pause_status: Label
var tutorial_modal: Control
var inventory_modal: Control
var pending_quest_start_id: String = ""
var pending_talk_npc_id: String = ""
var pending_return_npc_id: String = ""

var current_quest_id: String = ""
var failed_quest_id: String = ""
var quest_started_at_msec: int = 0
var quest_running: bool = false
var perfect_run: bool = true
var active_step: int = 0
var return_to_npc: bool = false
var collected: Dictionary = {}
var run_points: int = 0
var current_question: Dictionary = {}
var order_next: int = 0
var order_buttons: Array = []
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var dialog_lines: Array = []
var dialog_index: int = 0
var dialog_done: Callable = Callable()
var last_interact_msec: int = 0
var autosave_clock: float = 0.0

func _ready() -> void:
	rng.randomize()
	world = WORLD_SCENE.instantiate() as Node2D
	add_child(world)
	player = world.get_node("Player") as CharacterBody2D
	player.call("set_gender", GameState.player_gender)
	player.call("set_player_name", GameState.player_name)
	if GameState.loaded_from_save:
		player.position = GameState.player_position
	else:
		player.position = Vector2(180.0, 320.0)

	_configure_camera()
	_spawn_npcs()
	if GameState.loaded_from_save and _restore_saved_npc_positions(GameState.current_day):
		pass
	else:
		_randomize_npc_positions(GameState.current_day)
	_build_hud()
	_update_day_ui()

	if GameState.current_day > 7:
		_show_epilogue()
		return

	_show_day_visual(GameState.current_day)
	if GameState.active_quest_id != "":
		_resume_saved_quest()
		_maybe_show_tutorial()
	elif not GameState.intro_seen:
		GameState.intro_seen = true
		_show_dialogue(_intro_dialogue(), Callable(self, "_on_intro_finished"))
	else:
		_start_day_idle()
		_maybe_show_tutorial()

func _on_intro_finished() -> void:
	_start_day_idle()
	_maybe_show_tutorial()

func _intro_dialogue() -> Array:
	return _format_lines([
		["Bu Veyra", "Pagi. Kayaknya kita belum sempat kenalan."],
		["PLAYER", "Saya {user}. Baru pindahan."],
		["Bu Veyra", "Oh, {user}. Welcome. Pelan-pelan aja, nggak perlu hafal semuanya hari ini."],
		["PLAYER", "Siap, Bu. Makasih."],
		["Bu Veyra", "Kalau butuh arah, lihat petunjuk di layar. Sekolah ini lebih gampang kalau dijalani satu tempat dulu."]
	])

func _configure_camera() -> void:
	var camera: Camera2D = player.get_node_or_null("Camera2D") as Camera2D
	if camera == null:
		camera = Camera2D.new()
		camera.name = "Camera2D"
		player.add_child(camera)
	camera.zoom = Vector2(MAP_ZOOM, MAP_ZOOM)
	camera.position = Vector2(0.0, -4.0)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 10.0
	camera.limit_smoothed = true
	var tile_map: TileMap = world.get_node_or_null("TileMap") as TileMap
	if tile_map != null and tile_map.tile_set != null:
		var used_rect: Rect2i = tile_map.get_used_rect()
		var tile_size: Vector2i = tile_map.tile_set.tile_size
		camera.limit_left = used_rect.position.x * tile_size.x - 80
		camera.limit_top = used_rect.position.y * tile_size.y - 80
		camera.limit_right = (used_rect.position.x + used_rect.size.x) * tile_size.x + 80
		camera.limit_bottom = (used_rect.position.y + used_rect.size.y) * tile_size.y + 80

func _spawn_npcs() -> void:
	for data_value in NPC_DATA:
		var data: Dictionary = data_value as Dictionary
		var npc: Area2D = NPC_SCENE.instantiate() as Area2D
		world.add_child(npc)
		npc.call("setup", data)
		npc.call("set_quest_active", false)
		npcs[str(data["id"])] = npc

func _randomize_npc_positions(day: int) -> void:
	rng.seed = int(Time.get_unix_time_from_system()) + day * 7919 + GameState.player_name.hash()
	var grouped: Dictionary = {}
	for value in NPC_DATA:
		var data: Dictionary = value as Dictionary
		var zone: String = str(data.get("zone", "class"))
		if not grouped.has(zone):
			grouped[zone] = []
		(grouped[zone] as Array).append(str(data.get("id", "")))

	for zone_value in grouped.keys():
		var zone: String = str(zone_value)
		var ids: Array = grouped[zone] as Array
		var positions: Array = (ZONES.get(zone, []) as Array).duplicate()
		positions.shuffle()
		var chosen_positions: Array = []
		for position_value in positions:
			if not (position_value is Vector2):
				continue
			var candidate: Vector2 = position_value as Vector2
			var far_enough: bool = true
			for chosen_value in chosen_positions:
				if candidate.distance_to(chosen_value as Vector2) < 90.0:
					far_enough = false
					break
			if far_enough:
				chosen_positions.append(candidate)
			if chosen_positions.size() >= ids.size():
				break
		if chosen_positions.size() < ids.size():
			for position_value in positions:
				if position_value is Vector2 and not chosen_positions.has(position_value):
					chosen_positions.append(position_value as Vector2)
				if chosen_positions.size() >= ids.size():
					break
		for i in ids.size():
			var npc: Area2D = npcs.get(str(ids[i])) as Area2D
			if npc == null:
				continue
			if i < chosen_positions.size():
				npc.position = chosen_positions[i] as Vector2
	_remember_npc_positions(day)

func _restore_saved_npc_positions(day: int) -> bool:
	var day_key: String = str(day)
	if not GameState.npc_positions.has(day_key):
		return false
	var raw: Variant = GameState.npc_positions.get(day_key, {})
	if not (raw is Dictionary):
		return false
	var saved: Dictionary = raw as Dictionary
	var restored: int = 0
	for id_value in saved.keys():
		var npc: Area2D = npcs.get(str(id_value)) as Area2D
		var pos_value: Variant = saved.get(id_value, null)
		if npc != null and pos_value is Dictionary:
			var pos_data: Dictionary = pos_value as Dictionary
			npc.position = Vector2(float(pos_data.get("x", npc.position.x)), float(pos_data.get("y", npc.position.y)))
			restored += 1
	return restored == NPC_DATA.size()

func _remember_npc_positions(day: int) -> void:
	var day_key: String = str(day)
	var saved: Dictionary = {}
	for id_value in npcs.keys():
		var npc: Area2D = npcs.get(str(id_value)) as Area2D
		if npc != null and is_instance_valid(npc):
			saved[str(id_value)] = {"x": npc.position.x, "y": npc.position.y}
	GameState.npc_positions[day_key] = saved

func _build_hud() -> void:
	hud_layer = CanvasLayer.new()
	hud_layer.layer = 50
	add_child(hud_layer)

	var grid: Control = GRID_SCRIPT.new() as Control
	grid.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	grid.modulate.a = 0.018
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_layer.add_child(grid)

	# Compact warm glass HUD. It intentionally leaves most of the game view open.
	var day_card: Panel = _glass_panel(hud_layer, Vector2(24, 16), Vector2(145, 54), Color(0.12, 0.055, 0.018, 0.56), Color(0.95, 0.80, 0.50, 0.50), 13)
	day_label = _label(day_card, Vector2(5, 4), Vector2(135, 23), "DAY 1 / 7", 17, Color("#f8e4ae"))
	day_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var small: Label = _label(day_card, Vector2(5, 31), Vector2(135, 12), "seven days • seven strangers", 8, Color(1.0, 0.90, 0.73, 0.72))
	small.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var quest_card: Panel = _glass_panel(hud_layer, Vector2(181, 16), Vector2(430, 54), Color(0.12, 0.055, 0.018, 0.52), Color(0.92, 0.75, 0.45, 0.40), 13)
	_label(quest_card, Vector2(10, 5), Vector2(180, 10), "CURRENT QUEST", 8, Color(0.96, 0.83, 0.58, 0.78))
	quest_label = _label(quest_card, Vector2(10, 17), Vector2(410, 21), "Menunggu...", 16, Color("#fff3d3"))
	quest_label.clip_text = true
	quest_progress_label = _label(quest_card, Vector2(10, 41), Vector2(410, 10), "", 9, Color(1.0, 0.90, 0.73, 0.72))

	var stats: Panel = _glass_panel(hud_layer, Vector2(623, 16), Vector2(270, 54), Color(0.12, 0.055, 0.018, 0.56), Color(0.95, 0.80, 0.50, 0.50), 13)
	_label(stats, Vector2(6, 5), Vector2(56, 10), "TIME", 7, Color(0.96, 0.83, 0.58, 0.72)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label = _label(stats, Vector2(4, 15), Vector2(74, 28), "5:00", 24, Color("#f9e2a6"))
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label(stats, Vector2(70, 5), Vector2(62, 10), "SCORE", 7, Color(0.96, 0.83, 0.58, 0.72)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label = _label(stats, Vector2(82, 15), Vector2(64, 28), "0", 24, Color("#f8e4c2"))
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label(stats, Vector2(152, 5), Vector2(50, 10), "RUN", 8, Color(0.96, 0.83, 0.58, 0.72)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	run_points_label = _label(stats, Vector2(152, 15), Vector2(50, 28), "+0", 20, Color("#ecd5a3"))
	run_points_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_button = _glass_button(stats, "MENU", Vector2(214, 8), Vector2(48, 30), 9)
	menu_button.pressed.connect(_toggle_pause_menu)

	var hint_card: Panel = _glass_panel(hud_layer, Vector2(24, 78), Vector2(300, 30), Color(0.12, 0.055, 0.018, 0.40), Color(0.92, 0.74, 0.44, 0.30), 10)
	hint_label = _label(hint_card, Vector2(8, 3), Vector2(284, 24), "", 13, Color("#fff0cf"))
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	var goal_card: Panel = _glass_panel(hud_layer, Vector2(335, 78), Vector2(560, 30), Color(0.12, 0.055, 0.018, 0.40), Color(0.92, 0.74, 0.44, 0.30), 10)
	goal_label = _label(goal_card, Vector2(8, 3), Vector2(544, 24), "", 13, Color(1.0, 0.90, 0.73, 0.82))
	goal_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	goal_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	var save_card: Panel = _glass_panel(hud_layer, Vector2(930, 78), Vector2(318, 30), Color(0.12, 0.055, 0.018, 0.40), Color(0.92, 0.74, 0.44, 0.30), 10)
	save_status = _label(save_card, Vector2(8, 3), Vector2(302, 24), "F5 • SAVE • LAN SYNC", 13, Color(1.0, 0.90, 0.73, 0.82))
	save_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	save_status.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	var inventory_card: Panel = _glass_panel(hud_layer, Vector2(24, 670), Vector2(270, 34), Color(0.12, 0.055, 0.018, 0.50), Color(0.92, 0.74, 0.44, 0.34), 10)
	var inventory_title: Label = _label(inventory_card, Vector2(8, 4), Vector2(82, 25), "BAG / TAB", 14, GOLD)
	inventory_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inventory_label = _label(inventory_card, Vector2(96, 4), Vector2(165, 25), "Kosong", 14, Color("#fff0cf"))
	inventory_label.clip_text = true
	inventory_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	guide_card = _glass_panel(hud_layer, Vector2(310, 670), Vector2(620, 34), Color(0.12, 0.055, 0.018, 0.50), Color(0.92, 0.74, 0.44, 0.34), 10)
	_label(guide_card, Vector2(8, 3), Vector2(24, 25), "✦", 16, GOLD)
	guide_label = _label(guide_card, Vector2(38, 4), Vector2(500, 25), "Temui NPC untuk mulai.", 14, Color("#fff0cf"))
	guide_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	guide_label.clip_text = true
	guide_button = _glass_button(guide_card, "GUIDE", Vector2(543, 4), Vector2(66, 26), 9)
	guide_button.pressed.connect(_on_guide_button_pressed)

	var controls_card: Panel = _glass_panel(hud_layer, Vector2(946, 670), Vector2(310, 34), Color(0.12, 0.055, 0.018, 0.50), Color(0.92, 0.74, 0.44, 0.34), 10)
	var controls: Label = _label(controls_card, Vector2(6, 4), Vector2(298, 25), "WASD • E TALK • F TAKE • G GIVE", 14, Color(1.0, 0.90, 0.73, 0.82))
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	guide_arrow = DIRECTION_ARROW_SCRIPT.new() as Control
	guide_arrow.position = Vector2(1188, 628)
	guide_arrow.size = Vector2(46, 46)
	guide_arrow.pivot_offset = Vector2(23.0, 23.0)
	guide_arrow.scale = Vector2(0.62, 0.62)
	guide_arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	guide_arrow.visible = false
	hud_layer.add_child(guide_arrow)

	transition_label = Label.new()
	transition_label.position = Vector2(480, 320)
	transition_label.size = Vector2(320, 44)
	transition_label.text = ""
	transition_label.add_theme_font_size_override("font_size", 20)
	transition_label.add_theme_color_override("font_color", Color("#f8e4b0"))
	transition_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	transition_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_label.modulate.a = 0.0
	hud_layer.add_child(transition_label)

	_build_dialog_box()

func _build_dialog_box() -> void:
	dialog_box = Panel.new()
	dialog_box.position = Vector2(190, 398)
	dialog_box.size = Vector2(900, 242)
	dialog_box.visible = false
	dialog_box.z_index = 220
	dialog_box.add_theme_stylebox_override("panel", _glass_style(Color(0.10, 0.042, 0.014, 0.94), Color(0.94, 0.78, 0.46, 0.48), 18, 1, 12))
	hud_layer.add_child(dialog_box)

	var pcard: Panel = Panel.new()
	pcard.position = Vector2(12, 12)
	pcard.size = Vector2(220, 218)
	pcard.add_theme_stylebox_override("panel", _glass_style(Color(0.20, 0.10, 0.04, 0.28), Color(0.94, 0.78, 0.46, 0.28), 14, 1, 5))
	dialog_box.add_child(pcard)

	dialog_portrait = TextureRect.new()
	dialog_portrait.position = Vector2(6, 6)
	dialog_portrait.size = Vector2(208, 204)
	dialog_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	dialog_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	dialog_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pcard.add_child(dialog_portrait)

	dialog_name = _label(dialog_box, Vector2(250, 18), Vector2(610, 34), "", 24, Color("#f6d58f"))
	dialog_name.clip_text = true
	dialog_text = _label(dialog_box, Vector2(250, 62), Vector2(620, 128), "", 25, Color("#fff5de"))
	dialog_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialog_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var next: Label = _label(dialog_box, Vector2(590, 216), Vector2(270, 16), "E / ENTER / SPACE • NEXT", 11, Color(1.0, 0.90, 0.73, 0.70))
	next.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

func _glass_panel(parent: Node, pos: Vector2, size_value: Vector2, bg: Color, border: Color, radius: int) -> Panel:
	var panel: Panel = Panel.new()
	panel.position = pos
	panel.size = size_value
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _glass_style(bg, border, radius, 1, 10))
	parent.add_child(panel)
	return panel

func _glass_style(bg: Color, border: Color, radius: int, border_width: int = 1, shadow: int = 10) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.08, 0.03, 0.01, 0.30)
	style.shadow_size = shadow
	style.shadow_offset = Vector2(0, 4)
	return style

func _label(parent: Control, pos: Vector2, size_value: Vector2, text_value: String, font_size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.position = pos
	label.size = size_value
	label.text = text_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0.10, 0.04, 0.01, 0.86))
	label.add_theme_color_override("font_outline_color", Color(0.08, 0.03, 0.01, 0.72))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.add_theme_constant_override("outline_size", 1)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _glass_button(parent: Control, text_value: String, pos: Vector2, size_value: Vector2, font_size: int = 16) -> Button:
	var button: Button = Button.new()
	button.position = pos
	button.size = size_value
	button.text = text_value
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", Color("#fff2d0"))
	button.add_theme_color_override("font_hover_color", Color("#f8df9c"))
	button.add_theme_color_override("font_pressed_color", Color("#ffe9b8"))
	button.add_theme_stylebox_override("normal", _glass_style(Color(0.17, 0.08, 0.03, 0.44), Color(0.93, 0.77, 0.48, 0.24), 12, 1, 5))
	button.add_theme_stylebox_override("hover", _glass_style(Color(0.22, 0.11, 0.045, 0.68), Color(0.98, 0.84, 0.60, 0.54), 12, 1, 7))
	button.add_theme_stylebox_override("pressed", _glass_style(Color(0.25, 0.12, 0.05, 0.78), Color(1.0, 0.89, 0.68, 0.68), 12, 1, 7))
	parent.add_child(button)
	return button

func _start_day_idle() -> void:
	if GameState.current_day > 7:
		_show_epilogue()
		return
	current_quest_id = ""
	quest_running = false
	active_step = 0
	return_to_npc = false
	collected.clear()
	run_points = 0
	var quest_id: String = _quest_for_day(GameState.current_day)
	_set_quest_npc(str((QUESTS[quest_id] as Dictionary)["npc"]))
	quest_label.text = "Temui " + str(_npc_name(str((QUESTS[quest_id] as Dictionary)["npc"]))) + " untuk memulai."
	quest_progress_label.text = "Temui NPC • E bicara • F ambil • G serahkan"
	goal_label.text = "Lokasi awal • " + str((QUESTS[quest_id] as Dictionary)["location"])
	timer_label.text = _format_time(_day_limit(GameState.current_day))
	run_points_label.text = "+0"
	_clear_objectives()
	GameState.active_quest_id = ""
	GameState.active_step = 0

func _quest_for_day(day: int) -> String:
	for key_value in QUESTS.keys():
		var key: String = str(key_value)
		var quest: Dictionary = QUESTS[key] as Dictionary
		if int(quest.get("day", 0)) == day:
			return key
	return "q1"

func _day_limit(day: int) -> float:
	var index: int = clampi(day - 1, 0, DAY_TIMES.size() - 1)
	return float(DAY_TIMES[index])

func _npc_name(npc_id: String) -> String:
	var npc: Area2D = npcs.get(npc_id) as Area2D
	return str(npc.get("display_name")) if npc != null else npc_id

func _set_quest_npc(active_id: String) -> void:
	for value in npcs.values():
		var npc: Area2D = value as Area2D
		if npc != null and is_instance_valid(npc):
			var is_active: bool = str(npc.get("npc_id")) == active_id
			npc.call("set_quest_active", is_active)

func _update_timer() -> void:
	if not quest_running or current_quest_id.is_empty():
		return
	var elapsed: float = float(Time.get_ticks_msec() - quest_started_at_msec) / 1000.0
	var limit: float = _day_limit(GameState.current_day)
	var remaining: float = maxf(0.0, limit - elapsed)
	timer_label.text = _format_time(remaining)
	if remaining <= 10.0:
		timer_label.add_theme_color_override("font_color", Color("#ff9f9f"))
	elif remaining <= 30.0:
		timer_label.add_theme_color_override("font_color", Color("#ffd07b"))
	else:
		timer_label.add_theme_color_override("font_color", Color("#ffe7a7"))
	GameState.active_quest_elapsed = elapsed
	if elapsed >= limit:
		_fail_quest()

func _format_time(seconds_value: float) -> String:
	var total_seconds: int = maxi(0, int(ceil(seconds_value)))
	var minutes: int = floori(float(total_seconds) / 60.0)
	var seconds: int = total_seconds % 60
	return "%d:%02d" % [minutes, seconds]

func _update_nearby_hint() -> void:
	if player == null or hint_label == null:
		return
	var nearest_npc: Area2D = _nearest_npc()
	var nearest_objective: Node2D = _nearest_objective()

	for value in npcs.values():
		var npc: Area2D = value as Area2D
		if npc != null and is_instance_valid(npc):
			npc.call("set_player_near", npc == nearest_npc)
	for value in objective_nodes.values():
		var obj: Node2D = value as Node2D
		if obj != null and is_instance_valid(obj):
			obj.call("set_player_near", obj == nearest_objective)

	if nearest_objective != null:
		hint_label.text = "F  AMBIL • " + str(nearest_objective.get_meta("title", "item"))
		return
	if nearest_npc != null:
		var current_step: Dictionary = _current_step()
		if str(current_step.get("type", "")) == "return" and str(current_step.get("npc", "")) == str(nearest_npc.get("npc_id")):
			hint_label.text = "G  SERAHKAN • " + str(nearest_npc.get("display_name"))
		else:
			hint_label.text = "E  BICARA • " + str(nearest_npc.get("display_name"))
		return
	hint_label.text = ""

func _nearest_npc() -> Area2D:
	var best: Area2D = null
	var best_dist: float = INF
	for value in npcs.values():
		var npc: Area2D = value as Area2D
		if npc == null or not is_instance_valid(npc):
			continue
		var dist: float = player.global_position.distance_to(npc.global_position)
		if dist < INTERACT_RADIUS and dist < best_dist:
			best = npc
			best_dist = dist
	return best

func _nearest_objective() -> Node2D:
	var best: Node2D = null
	var best_dist: float = INF
	for value in objective_nodes.values():
		var obj: Node2D = value as Node2D
		if obj == null or not is_instance_valid(obj):
			continue
		var dist: float = player.global_position.distance_to(obj.global_position)
		if dist < OBJECTIVE_RADIUS and dist < best_dist:
			best = obj
			best_dist = dist
	return best

func _handle_interact() -> void:
	var now: int = Time.get_ticks_msec()
	if now - last_interact_msec < 120:
		return
	last_interact_msec = now

	if modal != null and is_instance_valid(modal):
		return
	if dialog_box != null and dialog_box.visible:
		_advance_dialogue()
		return

	var npc: Area2D = _nearest_npc()
	if npc != null:
		_interact_npc(npc)

func _handle_pickup() -> void:
	if modal != null and is_instance_valid(modal):
		return
	if dialog_box != null and dialog_box.visible:
		return
	var objective: Node2D = _nearest_objective()
	if objective == null:
		return
	_handle_objective(str(objective.get_meta("id", "")))

func _handle_submit() -> void:
	if modal != null and is_instance_valid(modal):
		return
	if dialog_box != null and dialog_box.visible:
		return
	if current_quest_id.is_empty():
		return
	var step: Dictionary = _current_step()
	if str(step.get("type", "")) != "return":
		return
	var npc_id: String = str(step.get("npc", ""))
	var npc: Area2D = npcs.get(npc_id) as Area2D
	if npc == null or not is_instance_valid(npc):
		return
	var distance: float = player.global_position.distance_to(npc.global_position)
	if distance > INTERACT_RADIUS:
		_toast("Dekati " + _npc_name(npc_id) + " dulu.")
		return
	pending_return_npc_id = npc_id
	_show_dialogue(_return_dialogue(npc_id), Callable(self, "_on_return_dialogue_finished"))

func _interact_npc(npc: Area2D) -> void:
	var npc_id: String = str(npc.get("npc_id"))
	if current_quest_id.is_empty():
		var quest_id: String = _quest_for_day(GameState.current_day)
		var starter: String = str((QUESTS[quest_id] as Dictionary)["npc"])
		if npc_id == starter:
			pending_quest_start_id = quest_id
			_show_dialogue(_quest_dialogue(quest_id), Callable(self, "_on_quest_dialogue_finished"))
		else:
			_show_dialogue(_friendly_dialogue(npc_id), Callable())
		return

	if _current_step_is_talk_for(npc_id):
		pending_talk_npc_id = npc_id
		_show_dialogue(_talk_step_dialogue(npc_id), Callable(self, "_on_talk_dialogue_finished"))
		return

	if _current_step_is_return_for(npc_id):
		pending_return_npc_id = npc_id
		_show_dialogue(_return_dialogue(npc_id), Callable(self, "_on_return_dialogue_finished"))
		return

	_show_dialogue(_friendly_dialogue(npc_id), Callable())

func _on_quest_dialogue_finished() -> void:
	var id: String = pending_quest_start_id
	pending_quest_start_id = ""
	if not id.is_empty():
		_begin_quest(id)

func _on_talk_dialogue_finished() -> void:
	pending_talk_npc_id = ""
	_advance_step()

func _on_return_dialogue_finished() -> void:
	pending_return_npc_id = ""
	_complete_quest()

func _current_step_is_talk_for(npc_id: String) -> bool:
	var step: Dictionary = _current_step()
	return str(step.get("type", "")) == "talk" and str(step.get("npc", "")) == npc_id

func _current_step_is_return_for(npc_id: String) -> bool:
	var step: Dictionary = _current_step()
	return str(step.get("type", "")) == "return" and str(step.get("npc", "")) == npc_id

func _quest_dialogue(id: String) -> Array:
	var raw: Array = NPC_DIALOGUES.get(str((QUESTS[id] as Dictionary)["npc"]), []) as Array
	return _format_lines(raw)

func _talk_step_dialogue(npc_id: String) -> Array:
	var lines: Array = []
	match npc_id:
		"orin":
			lines = [["Orin", "Clue? Ada."], ["Orin", "Kalau soal kelas, lihat yang paling dekat sama papan. Gue tadi mindahin sesuatu ke sana."], ["PLAYER", "Noted. Makasih, Rin."]]
		"bu_imas":
			lines = [["Bu Imas", "Oh, kamu cari petunjuk pesanan? Lihat meja yang paling dekat sama kasir."], ["PLAYER", "Oke, Bu."], ["Bu Imas", "Jangan sampai salah meja lagi, nanti kita semua makan misteri."]]
		"bu_veyra":
			lines = [["Bu Veyra", "Kalau mau cek aturan laporan, ingat urutannya harus kebaca masuk akal."], ["PLAYER", "Berarti ada pola ya, Bu."], ["Bu Veyra", "Exactly."]]
		"sora":
			lines = [["Sora", "Aku ingat posisi tiga barang itu. Aku juga sengaja kasih clue yang nggak langsung."], ["PLAYER", "Biar mikir dua kali?"], ["Sora", "Biar nggak asal nebak."]]
		_:
			lines = _friendly_dialogue(npc_id)
	return _format_lines(lines)

func _return_dialogue(npc_id: String) -> Array:
	return _format_lines([
		[_npc_name(npc_id), "Sudah kembali."],
		["PLAYER", "Semua beres, Pak. Ini sudah aku urus."],
		[_npc_name(npc_id), "Good. Tinggal satu hal terakhir."]
	])

func _friendly_dialogue(npc_id: String) -> Array:
	var npc_name: String = _npc_name(npc_id)
	var text_value: String = str(FRIENDLY_DIALOGUES.get(npc_id, "Nice ketemu lagi, {user}."))
	return _format_lines([[npc_name, text_value]])

func _format_lines(raw: Array) -> Array:
	var result: Array = []
	var safe_user: String = GameState.player_name.strip_edges()
	if safe_user.is_empty():
		safe_user = "Stranger"
	for value in raw:
		var pair: Array = value as Array
		if pair.size() < 2:
			continue
		var raw_speaker: String = str(pair[0])
		var speaker: String = raw_speaker
		var portrait_path: String = ""
		if raw_speaker == "PLAYER" or raw_speaker == "Player" or raw_speaker == "player":
			speaker = safe_user
			portrait_path = _player_portrait_path()
		else:
			speaker = raw_speaker.replace("{user}", safe_user)
			portrait_path = str(PORTRAITS.get(raw_speaker, ""))
		var text_value: String = str(pair[1]).replace("{user}", safe_user)
		result.append({
			"speaker": speaker,
			"text": text_value,
			"portrait": portrait_path
		})
	return result

func _player_portrait_path() -> String:
	return "res://assets/custom/mc/cewe_down.png" if GameState.player_gender == "girl" else "res://assets/custom/mc/cowo_down.png"

func _show_dialogue(lines: Array, after: Callable) -> void:
	if lines.is_empty():
		if after.is_valid():
			after.call()
		return
	dialog_lines = lines
	dialog_index = 0
	dialog_done = after
	dialog_box.visible = true
	player.call("set_locked", true)
	_render_dialogue_line()

func _render_dialogue_line() -> void:
	if dialog_index >= dialog_lines.size():
		_hide_dialogue()
		return
	var line: Dictionary = dialog_lines[dialog_index] as Dictionary
	var safe_user: String = GameState.player_name.strip_edges()
	if safe_user.is_empty():
		safe_user = "Stranger"
	dialog_name.text = str(line.get("speaker", "")).replace("{user}", safe_user)
	dialog_text.text = str(line.get("text", "")).replace("{user}", safe_user)
	var portrait_path: String = str(line.get("portrait", ""))
	if portrait_path.is_empty():
		dialog_portrait.texture = null
		return
	var texture: Texture2D = load(portrait_path) as Texture2D
	if texture == null:
		dialog_portrait.texture = null
		return
	var atlas: AtlasTexture = AtlasTexture.new()
	atlas.atlas = texture
	var frame_count: float = 6.0 if portrait_path.contains("/mc/") else 3.0
	atlas.region = Rect2(0.0, 0.0, texture.get_width() / frame_count, texture.get_height())
	dialog_portrait.texture = atlas

func _advance_dialogue() -> void:
	dialog_index += 1
	if dialog_index >= dialog_lines.size():
		_hide_dialogue()
		return
	_render_dialogue_line()

func _hide_dialogue() -> void:
	dialog_box.visible = false
	player.call("set_locked", false)
	if dialog_done.is_valid():
		var callback: Callable = dialog_done
		dialog_done = Callable()
		callback.call()

func _begin_quest(id: String) -> void:
	if not QUESTS.has(id) or GameState.completed_quests.has(id):
		return
	current_quest_id = id
	quest_running = true
	perfect_run = true
	active_step = 0
	return_to_npc = false
	collected.clear()
	run_points = 0
	quest_started_at_msec = Time.get_ticks_msec()
	_set_quest_npc("")
	_setup_current_step()
	var quest: Dictionary = QUESTS[id] as Dictionary
	quest_label.text = "DAY %d  •  %s" % [int(quest["day"]), str(quest["title"])]
	goal_label.text = "Challenge • %d:%02d" % [int(_day_limit(GameState.current_day) / 60.0), int(fmod(_day_limit(GameState.current_day), 60.0))]
	score_label.text = "%d" % GameState.total_score
	run_points_label.text = "+0"
	_save_progress()

func _resume_saved_quest() -> void:
	current_quest_id = GameState.active_quest_id
	if not QUESTS.has(current_quest_id):
		GameState.active_quest_id = ""
		_start_day_idle()
		return
	quest_running = true
	active_step = clampi(GameState.active_step, 0, _step_count(current_quest_id) - 1)
	perfect_run = GameState.active_perfect_run
	return_to_npc = GameState.active_return_to_npc
	run_points = GameState.active_live_points
	quest_started_at_msec = Time.get_ticks_msec() - int(GameState.active_quest_elapsed * 1000.0)
	collected.clear()
	for value in GameState.active_collected:
		collected[str(value)] = true
	_set_quest_npc("")
	_setup_current_step()
	_restore_collected_from_save()
	_update_quest_progress()

func _step_count(id: String) -> int:
	if not QUESTS.has(id):
		return 1
	var steps: Array = (QUESTS[id] as Dictionary).get("steps", []) as Array
	return maxi(1, steps.size())

func _current_step() -> Dictionary:
	if current_quest_id.is_empty() or not QUESTS.has(current_quest_id):
		return {}
	var steps: Array = (QUESTS[current_quest_id] as Dictionary).get("steps", []) as Array
	if active_step < 0 or active_step >= steps.size():
		return {}
	return steps[active_step] as Dictionary

func _setup_current_step() -> void:
	_clear_objectives()
	var step: Dictionary = _current_step()
	var step_type: String = str(step.get("type", ""))
	return_to_npc = step_type == "return"

	match step_type:
		"items":
			_spawn_step_items(step)
		"talk":
			_set_quest_npc(str(step.get("npc", "")))
		"deliver":
			_spawn_delivery_target(str(step.get("zone", "field")))
		"question", "optional_question":
			_show_question(step, step_type == "optional_question")
		"order":
			_show_order(step)
		"return":
			_set_quest_npc(str(step.get("npc", "")))
		_:
			pass
	_update_quest_progress()

func _spawn_step_items(step: Dictionary) -> void:
	var items: Array = step.get("items", []) as Array
	var used_spots: Dictionary = {}
	for item_value in items:
		var item_data: Dictionary = item_value as Dictionary
		var item_id: String = str(item_data.get("id", ""))
		if collected.has(item_id):
			continue
		var zone: String = str(item_data.get("zone", "class"))
		var spots: Array = (ITEM_SPOTS.get(zone, []) as Array).duplicate()
		if spots.is_empty():
			continue
		var spot_index: int = rng.randi_range(0, spots.size() - 1)
		if used_spots.has(zone):
			var tries: int = 0
			while used_spots[zone].has(spot_index) and tries < 10:
				spot_index = rng.randi_range(0, spots.size() - 1)
				tries += 1
		if not used_spots.has(zone):
			used_spots[zone] = []
		(used_spots[zone] as Array).append(spot_index)
		var item_position_value: Variant = spots[spot_index]
		if item_position_value is Vector2:
			_spawn_item(item_id, str(item_data.get("title", "Item")), str(item_data.get("kind", "sparkle")), item_position_value, zone)

func _spawn_item(item_id: String, title_value: String, kind: String, pos: Vector2, zone: String = "") -> void:
	var item: Area2D = Area2D.new()
	item.set_script(ITEM_SCRIPT)
	world.add_child(item)
	item.position = pos
	item.set_meta("zone", zone)
	item.call("setup", item_id, title_value, kind)
	objective_nodes[item_id] = item

func _spawn_delivery_target(zone: String) -> void:
	var spots: Array = ITEM_SPOTS.get(zone, []) as Array
	if spots.is_empty():
		return
	var marker_id: String = "delivery_target"
	var target_position_value: Variant = spots[0]
	if target_position_value is Vector2:
		_spawn_item(marker_id, "Taruh di sini", "sparkle", target_position_value, zone)

func _handle_objective(item_id: String) -> void:
	if current_quest_id.is_empty() or not objective_nodes.has(item_id):
		return
	var step: Dictionary = _current_step()
	var step_type: String = str(step.get("type", ""))
	var item: Node2D = objective_nodes.get(item_id) as Node2D
	var item_title: String = "Item"
	if item != null and is_instance_valid(item):
		item_title = str(item.get_meta("title", "Item"))
		item.queue_free()
	objective_nodes.erase(item_id)

	if step_type == "items":
		collected[item_id] = true
		run_points += 40
		_toast("+40 • " + item_title)
		var required: Array = step.get("items", []) as Array
		var done: int = 0
		for item_value in required:
			var data: Dictionary = item_value as Dictionary
			if collected.has(str(data.get("id", ""))):
				done += 1
		if done >= required.size():
			run_points += 60
			_advance_step()
			return
	elif step_type == "deliver":
		run_points += 80
		_advance_step()
		return
	_update_quest_progress()
	_save_progress()

func _restore_collected_from_save() -> void:
	var saved: Array = GameState.active_collected
	if saved.is_empty():
		return
	for value in saved:
		collected[str(value)] = true

func _advance_step() -> void:
	active_step += 1
	_clear_objectives()
	if current_quest_id.is_empty() or active_step >= _step_count(current_quest_id):
		_complete_quest()
		return
	_setup_current_step()
	_save_progress()

func _update_quest_progress() -> void:
	if current_quest_id.is_empty():
		quest_progress_label.text = "Menunggu..."
		_update_inventory_label()
		return
	var steps: Array = (QUESTS[current_quest_id] as Dictionary).get("steps", []) as Array
	var step_text: String = "%d / %d" % [active_step + 1, steps.size()]
	var step: Dictionary = _current_step()
	match str(step.get("type", "")):
		"items":
			var required: Array = step.get("items", []) as Array
			var got: int = 0
			for value in required:
				var data: Dictionary = value as Dictionary
				if collected.has(str(data.get("id", ""))):
					got += 1
			quest_progress_label.text = "ITEM %d/%d • STEP %s" % [got, required.size(), step_text]
			goal_label.text = "Cari sparkle • gunakan F untuk mengambil"
		"talk":
			quest_progress_label.text = "TEMUI " + _npc_name(str(step.get("npc", ""))) + " • STEP " + step_text
			goal_label.text = "Tanya NPC • dengarkan clue sebelum lanjut"
		"question", "optional_question":
			quest_progress_label.text = ("BONUS • " if str(step.get("type", "")) == "optional_question" else "LOGIKA • ") + step_text
			goal_label.text = "Baca cerita • pilih jawaban paling masuk akal"
		"order":
			quest_progress_label.text = "SUSUN %d/5 • STEP %s" % [order_next, step_text]
			goal_label.text = "Urutkan dari awal sampai akhir"
		"deliver":
			quest_progress_label.text = "TITIPKAN BARANG • STEP " + step_text
			goal_label.text = "Dekati sparkle tujuan • F untuk menaruh"
		"return":
			quest_progress_label.text = "SERAHKAN KE " + _npc_name(str(step.get("npc", "")))
			goal_label.text = "Bawa barang • dekati NPC • G untuk menyerahkan"
		_:
			quest_progress_label.text = "LANGKAH " + step_text
			goal_label.text = "Ikuti petunjuk"
	run_points_label.text = "+%d" % run_points
	_update_inventory_label()

func _update_inventory_label() -> void:
	if inventory_label == null or not is_instance_valid(inventory_label):
		return
	if collected.is_empty():
		inventory_label.text = "Kosong"
		return

	var names: Array[String] = []
	for key_value in collected.keys():
		var key: String = str(key_value)
		var found_name: String = key
		for quest_value in QUESTS.values():
			var quest_data: Dictionary = quest_value as Dictionary
			var steps: Array = quest_data.get("steps", []) as Array
			for step_value in steps:
				var step_data: Dictionary = step_value as Dictionary
				if str(step_data.get("type", "")) != "items":
					continue
				var item_values: Array = step_data.get("items", []) as Array
				for item_value in item_values:
					var item_data: Dictionary = item_value as Dictionary
					if str(item_data.get("id", "")) == key:
						found_name = str(item_data.get("title", key))
						break
				if found_name != key:
					break
			if found_name != key:
				break
		names.append(found_name)
	var joined: String = ""
	for name_value in names:
		if not joined.is_empty():
			joined += ", "
		joined += name_value
	inventory_label.text = joined

func _calculate_score(elapsed: float) -> Dictionary:
	var limit: float = _day_limit(GameState.current_day)
	var safe_elapsed: float = clampf(elapsed, 0.0, limit)
	var speed_bonus: int = 100
	var fast_cutoff: float = limit * 0.20
	var good_cutoff: float = limit * 0.40
	var fair_cutoff: float = limit * 0.60
	if safe_elapsed <= fast_cutoff:
		speed_bonus = 400
	elif safe_elapsed <= good_cutoff:
		speed_bonus = 300
	elif safe_elapsed <= fair_cutoff:
		speed_bonus = 200
	var completion_points: int = 300
	var perfect_bonus: int = 300 if perfect_run else 0
	var score: int = mini(1000, completion_points + speed_bonus + perfect_bonus)
	var remaining: float = maxf(0.0, limit - safe_elapsed)
	return {"score": score, "completion": completion_points, "speed": speed_bonus, "perfect": perfect_bonus, "remaining": remaining}

func _complete_quest() -> void:
	if current_quest_id.is_empty() or not quest_running:
		return
	var elapsed: float = minf(_day_limit(GameState.current_day), float(Time.get_ticks_msec() - quest_started_at_msec) / 1000.0)
	var details: Dictionary = _calculate_score(elapsed)
	var finished_id: String = current_quest_id
	GameState.set_quest_score(finished_id, int(details["score"]), elapsed)
	GameState.current_day += 1
	GameState.active_quest_id = ""
	GameState.active_collected = []
	GameState.active_step = 0
	GameState.active_live_points = 0
	GameState.active_return_to_npc = false
	GameState.active_perfect_run = true
	GameState.player_position = player.position
	GameState.save_game(player.position, "", 0.0, [], false, true, 0, 0, true)
	GameState.add_leaderboard_entry()
	quest_running = false
	current_quest_id = ""
	_clear_objectives()
	_set_quest_npc("")
	score_label.text = "%d" % GameState.total_score
	_show_score_popup(finished_id, int(details["score"]), elapsed, int(details["speed"]), int(details["perfect"]))

func _show_score_popup(finished_id: String, score_value: int, elapsed: float, speed_bonus: int, perfect_bonus: int) -> void:
	_clear_modal()
	modal = Control.new()
	modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal.mouse_filter = Control.MOUSE_FILTER_STOP
	modal.z_index = 200
	hud_layer.add_child(modal)
	player.call("set_locked", true)
	var dim: ColorRect = ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.16, 0.075, 0.025, 0.62)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	modal.add_child(dim)
	var panel: Panel = _glass_panel(modal, Vector2(250, 140), Vector2(780, 420), Color(0.14, 0.065, 0.025, 0.90), Color(0.92, 0.79, 0.50, 0.58), 28)
	var title: Label = _label(panel, Vector2(40, 28), Vector2(700, 42), "QUEST COMPLETE", 27, Color("#ffe4a1"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var name: Label = _label(panel, Vector2(55, 75), Vector2(670, 34), str((QUESTS[finished_id] as Dictionary)["title"]), 15, Color("#fff7e6"))
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var score: Label = _label(panel, Vector2(55, 122), Vector2(670, 74), "+%d" % score_value, 48, Color("#f3d58b"))
	score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var breakdown: Label = _label(panel, Vector2(55, 206), Vector2(670, 105), "Completion +300\nSpeed bonus +%d\nPerfect bonus +%d\nLimit %s • Time %s" % [speed_bonus, perfect_bonus, _format_time(_day_limit(GameState.current_day - 1)), _format_time(elapsed)], 15, Color(1.0, 0.92, 0.76, 0.84))
	breakdown.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	breakdown.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var continue_button: Button = _glass_button(panel, "NEXT DAY", Vector2(235, 330), Vector2(310, 54), 17)
	continue_button.pressed.connect(_on_next_day_pressed)

func _transition_to_next_day() -> void:
	_randomize_npc_positions(GameState.current_day)
	_update_day_ui()
	if GameState.current_day > 7:
		_show_epilogue()
		return
	_show_day_visual(GameState.current_day)
	transition_label.text = "DAY %d / 7" % GameState.current_day
	transition_label.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(transition_label, "modulate:a", 1.0, 0.25)
	tween.tween_interval(0.85)
	tween.tween_property(transition_label, "modulate:a", 0.0, 0.65)
	tween.tween_callback(_start_day_idle)

func _fail_quest() -> void:
	if current_quest_id.is_empty():
		return
	failed_quest_id = current_quest_id
	quest_running = false
	GameState.active_quest_elapsed = _day_limit(GameState.current_day)
	_save_progress()
	_clear_objectives()
	_show_game_over()

func _retry_failed_quest() -> void:
	var retry_id: String = failed_quest_id
	_clear_modal()
	if retry_id.is_empty():
		_start_day_idle()
		return
	current_quest_id = retry_id
	quest_running = true
	active_step = 0
	collected.clear()
	run_points = 0
	perfect_run = true
	return_to_npc = false
	quest_started_at_msec = Time.get_ticks_msec()
	_set_quest_npc("")
	_setup_current_step()
	_save_progress()

func _show_game_over() -> void:
	_clear_modal()
	modal = Control.new()
	modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal.mouse_filter = Control.MOUSE_FILTER_STOP
	modal.z_index = 200
	hud_layer.add_child(modal)
	player.call("set_locked", true)

	var dim: ColorRect = ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.18, 0.07, 0.025, 0.72)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	modal.add_child(dim)
	var grid: Control = GRID_SCRIPT.new() as Control
	grid.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	grid.modulate.a = 0.16
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	modal.add_child(grid)

	var panel: Panel = _glass_panel(modal, Vector2(320, 150), Vector2(640, 420), Color(0.15, 0.07, 0.025, 0.92), Color(0.96, 0.73, 0.42, 0.54), 28)
	var title: Label = _label(panel, Vector2(50, 35), Vector2(540, 42), "TIME'S UP", 33, Color("#ffd5dc"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var message: Label = _label(panel, Vector2(70, 95), Vector2(500, 70), "Waktu habis.\nTapi ceritanya belum selesai.", 19, Color("#fff6ea"))
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var retry: Button = _glass_button(panel, "RETRY QUEST", Vector2(155, 205), Vector2(330, 54), 17)
	retry.pressed.connect(_retry_failed_quest)
	var menu: Button = _glass_button(panel, "MAIN MENU", Vector2(155, 275), Vector2(330, 54), 17)
	menu.pressed.connect(_go_main_menu)

func _show_epilogue() -> void:
	_clear_modal()
	modal = Control.new()
	modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal.mouse_filter = Control.MOUSE_FILTER_STOP
	modal.z_index = 200
	hud_layer.add_child(modal)
	player.call("set_locked", true)
	var bg: TextureRect = TextureRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.texture = load("res://assets/custom/visuals/sunset.png") as Texture2D
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	modal.add_child(bg)
	var shade: ColorRect = ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.20, 0.08, 0.025, 0.42)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	modal.add_child(shade)
	var grid: Control = GRID_SCRIPT.new() as Control
	grid.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	grid.modulate.a = 0.12
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	modal.add_child(grid)

	var panel: Panel = _glass_panel(modal, Vector2(180, 70), Vector2(920, 580), Color(0.14, 0.065, 0.025, 0.82), Color(0.94, 0.78, 0.48, 0.46), 30)
	var title: Label = _label(panel, Vector2(45, 30), Vector2(830, 48), "HELLO, STRANGER", 34, Color("#f4d78b"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var story: Label = _label(panel, Vector2(70, 90), Vector2(780, 150), "Tujuh hari. Tujuh orang asing.\nSekarang sekolah ini nggak terasa asing lagi.\n\n" + GameState.player_name + " pulang membawa cerita, bukan cuma skor.", 20, Color("#fff5df"))
	story.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var score: Label = _label(panel, Vector2(70, 260), Vector2(780, 58), "TOTAL SCORE  %d" % GameState.total_score, 27, Color("#f4d78b"))
	score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var progress: Label = _label(panel, Vector2(70, 320), Vector2(780, 36), "QUESTS COMPLETED  7 / 7", 16, Color("#fff6dd"))
	progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var quote: Label = _label(panel, Vector2(90, 375), Vector2(740, 74), "‘Sekolahnya masih sama.\nTapi sekarang rasanya berbeda.’", 18, Color(0.95, 0.91, 0.80, 0.86))
	quote.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var back: Button = _glass_button(panel, "RETURN TO MAIN MENU", Vector2(305, 480), Vector2(310, 54), 17)
	back.pressed.connect(_go_main_menu)

func _show_day_visual(day: int) -> void:
	if day_visual != null and is_instance_valid(day_visual):
		day_visual.queue_free()
	var path: String = "res://scenes/visuals/Classroom.tscn"
	if day == 1:
		path = "res://scenes/visuals/Sunrise.tscn"
	elif day >= 7:
		path = "res://scenes/visuals/Sunset.tscn"
	if not ResourceLoader.exists(path):
		return
	day_visual = load(path).instantiate() as Control
	day_visual.z_index = 400
	hud_layer.add_child(day_visual)
	day_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	day_visual.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(day_visual, "modulate:a", 1.0, 0.18)
	tween.tween_interval(0.45)
	tween.tween_property(day_visual, "modulate:a", 0.0, 0.75)
	tween.tween_callback(_finish_day_visual)

func _update_day_ui() -> void:
	day_label.text = "DAY %d / 7" % GameState.current_day if GameState.current_day <= 7 else "DAY 7 / 7"
	score_label.text = "%d" % GameState.total_score
	timer_label.text = _format_time(_day_limit(GameState.current_day if GameState.current_day <= 7 else 7))

func _save_progress() -> void:
	if player == null or not is_instance_valid(player):
		return
	var elapsed: float = 0.0
	if quest_running:
		elapsed = minf(_day_limit(GameState.current_day), float(Time.get_ticks_msec() - quest_started_at_msec) / 1000.0)
	var saved: bool = GameState.save_game(player.position, current_quest_id, elapsed, collected.keys(), return_to_npc, perfect_run, active_step, run_points, GameState.intro_seen)
	save_status.text = "SAVED • " + GameState.get_server_status_text()
	if not saved:
		save_status.text = "SAVE FAILED • local"
	var tween: Tween = create_tween()
	tween.tween_interval(1.2)
	tween.tween_callback(_reset_save_status)

func _on_next_day_pressed() -> void:
	_clear_modal()
	_transition_to_next_day()

func _go_main_menu() -> void:
	_clear_modal()
	SceneManager.go_to("res://scenes/main/MainMenu.tscn")

func _finish_day_visual() -> void:
	if day_visual != null and is_instance_valid(day_visual):
		day_visual.queue_free()
	day_visual = null

func _reset_save_status() -> void:
	if save_status != null and is_instance_valid(save_status):
		save_status.text = "F5 • SAVE • LAN SYNC"

func _on_guide_button_pressed() -> void:
	_show_tutorial(true)

func _maybe_show_tutorial() -> void:
	if GameState.tutorial_seen:
		return
	_show_tutorial(false)

func _show_tutorial(manual_open: bool) -> void:
	if tutorial_modal != null and is_instance_valid(tutorial_modal):
		return
	tutorial_modal = Control.new()
	tutorial_modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tutorial_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	tutorial_modal.z_index = 300
	hud_layer.add_child(tutorial_modal)
	if player != null and is_instance_valid(player):
		player.call("set_locked", true)

	var dim: ColorRect = ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.08, 0.035, 0.012, 0.72)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tutorial_modal.add_child(dim)

	var panel: Panel = _glass_panel(tutorial_modal, Vector2(250, 88), Vector2(780, 548), Color(0.12, 0.055, 0.020, 0.92), Color(0.92, 0.76, 0.46, 0.60), 26)
	var title: Label = _label(panel, Vector2(35, 22), Vector2(710, 40), "HOW TO PLAY", 26, Color("#f4d78b"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var intro: Label = _label(panel, Vector2(65, 68), Vector2(650, 38), "Cari, tanya, mikir, lalu balik lagi. Petunjuknya selalu ada di HUD.", 12, Color(1.0, 0.91, 0.76, 0.82))
	intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var tips: Array = [
		["WASD / ARROWS", "Jalan keliling sekolah."],
		["E", "Bicara dengan NPC + lanjut dialog."],
		["F", "Ambil sparkle/item atau tempatkan barang pada target quest."],
		["G", "Serahkan quest ke NPC yang dituju."],
		["TAB", "Cek ringkasan barang yang sudah kamu bawa."],
		["F5 / ESC", "Simpan cepat / buka menu pause."],
	]
	for i in tips.size():
		var y: float = 122.0 + float(i) * 60.0
		var item_panel: Panel = _glass_panel(panel, Vector2(52, y), Vector2(676, 48), Color(0.08, 0.04, 0.018, 0.44), Color(0.92, 0.76, 0.46, 0.18), 13)
		var key_text: Label = _label(item_panel, Vector2(10, 7), Vector2(140, 34), str(tips[i][0]), 11, Color("#f4d78b"))
		key_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var body: Label = _label(item_panel, Vector2(164, 7), Vector2(490, 34), str(tips[i][1]), 10, Color("#fff8e9"))
		body.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var close_text: String = "MULAI • LET'S GO" if not manual_open else "TUTUP GUIDE"
	var close_button: Button = _glass_button(panel, close_text, Vector2(292, 491), Vector2(196, 40), 12)
	close_button.pressed.connect(_close_tutorial)

func _close_tutorial() -> void:
	if tutorial_modal != null and is_instance_valid(tutorial_modal):
		tutorial_modal.queue_free()
	tutorial_modal = null
	GameState.tutorial_seen = true
	if player != null and is_instance_valid(player):
		player.call("set_locked", false)
	_save_progress()

func _update_guidance() -> void:
	if guide_card == null or guide_label == null or player == null:
		return
	if tutorial_modal != null and is_instance_valid(tutorial_modal):
		guide_label.text = "Guide terbuka • tekan E untuk mulai/tutup."
		if guide_arrow != null:
			guide_arrow.visible = false
		return

	var target: Node2D = _guidance_target()
	if current_quest_id.is_empty():
		var qid: String = _quest_for_day(GameState.current_day)
		var q: Dictionary = QUESTS.get(qid, {}) as Dictionary
		var start_npc: String = str(q.get("npc", ""))
		guide_label.text = "Temui %s di %s • tekan E" % [_npc_name(start_npc), str(q.get("location", "area sekitar"))]
	elif target != null and is_instance_valid(target):
		var target_title: String = str(target.get_meta("title", "tujuan"))
		var target_zone: String = str(target.get_meta("zone", ""))
		var distance_px: int = maxi(0, int(round(player.global_position.distance_to(target.global_position))))
		var current_step: Dictionary = _current_step()
		var action: String = "G" if str(current_step.get("type", "")) == "return" else "F"
		guide_label.text = "%s  %s • %s • %dpx" % [action, _zone_hint(target_zone), target_title, distance_px]
	else:
		var step: Dictionary = _current_step()
		var kind: String = str(step.get("type", ""))
		match kind:
			"talk":
				guide_label.text = "Tanya %s dengan E • dia pegang clue berikutnya." % _npc_name(str(step.get("npc", "")))
			"question", "optional_question":
				guide_label.text = "Baca cerita sampai habis • logic dulu, baru klik jawaban."
			"order":
				guide_label.text = "Klik urutan yang benar • salah pilih akan reset."
			"return":
				guide_label.text = "Dekati %s • tekan G untuk menyerahkan." % _npc_name(str(step.get("npc", "")))
			_:
				guide_label.text = "Ikuti panah • cek BAG/TAB untuk item yang sudah diambil."

	if target != null and is_instance_valid(target) and GameState.show_guide_arrow:
		var direction: Vector2 = target.global_position - player.global_position
		guide_arrow.visible = direction.length() > 5.0
		guide_arrow.call("set_direction", direction)
	else:
		guide_arrow.visible = false

func _zone_hint(zone: String) -> String:
	match zone:
		"canteen":
			return "KANTIN • dekat area kasir / rak"
		"class":
			return "KELAS • sekitar meja / papan"
		"field":
			return "LAPANGAN • sekitar perlengkapan latihan"
		"library":
			return "PERPUSTAKAAN • sekitar rak"
		_:
			return "AREA TUJUAN"

func _guidance_target() -> Node2D:
	var objective: Node2D = _nearest_any_objective()
	if objective != null:
		return objective
	if current_quest_id.is_empty():
		var qid: String = _quest_for_day(GameState.current_day)
		var starter_id: String = str((QUESTS[qid] as Dictionary).get("npc", ""))
		return npcs.get(starter_id) as Node2D
	var step: Dictionary = _current_step()
	var npc_id: String = str(step.get("npc", ""))
	if step.get("type", "") in ["talk", "return"] and not npc_id.is_empty():
		return npcs.get(npc_id) as Node2D
	return null

func _nearest_any_objective() -> Node2D:
	var best: Node2D = null
	var best_dist: float = INF
	for value in objective_nodes.values():
		var obj: Node2D = value as Node2D
		if obj == null or not is_instance_valid(obj):
			continue
		var dist: float = player.global_position.distance_to(obj.global_position)
		if dist < best_dist:
			best = obj
			best_dist = dist
	return best

func _clear_objectives() -> void:
	for value in objective_nodes.values():
		var node: Node = value as Node
		if node != null and is_instance_valid(node):
			node.queue_free()
	objective_nodes.clear()

func _show_question(step: Dictionary, optional: bool) -> void:
	current_question = step.duplicate(true)
	_clear_modal()
	modal = Control.new()
	modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal.mouse_filter = Control.MOUSE_FILTER_STOP
	modal.z_index = 200
	hud_layer.add_child(modal)
	player.call("set_locked", true)
	var dim: ColorRect = ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.18, 0.075, 0.025, 0.64)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	modal.add_child(dim)
	var panel: Panel = _glass_panel(modal, Vector2(190, 90), Vector2(900, 540), Color(0.14, 0.065, 0.025, 0.94), Color(0.94, 0.78, 0.48, 0.46), 26)
	var tag_text: String = "BONUS • BOLEH LEWATI" if optional else "LOGIKA CERITA"
	var tag: Label = _label(panel, Vector2(40, 26), Vector2(820, 22), tag_text, 9, Color("#d8ba6e"))
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var q: Label = _label(panel, Vector2(55, 72), Vector2(790, 118), str(step.get("question", "")), 19, Color("#fff7e9"))
	q.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	q.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	q.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var options: Array = step.get("options", []) as Array
	for i in options.size():
		var col: int = i % 2
		var row: int = floori(float(i) / 2.0)
		var b: Button = _glass_button(panel, str(options[i]), Vector2(70 + col * 400, 220 + row * 92), Vector2(350, 64), 15)
		b.pressed.connect(_answer_question.bind(i, optional))
	if optional:
		var skip: Button = _glass_button(panel, "LEWATI BONUS", Vector2(310, 423), Vector2(280, 48), 12)
		skip.pressed.connect(_skip_optional_question)

func _answer_question(index: int, optional: bool) -> void:
	var correct: int = int(current_question.get("answer", 0))
	var ok: bool = index == correct
	if not ok:
		perfect_run = false
		run_points = maxi(0, run_points - 30)
		_toast("Jawabannya meleset. -30 run points")
		if optional:
			_clear_modal()
			_advance_step()
		return
	run_points += 130 if not optional else 90
	_toast("Benar. +%d" % (130 if not optional else 90))
	_clear_modal()
	_advance_step()

func _skip_optional_question() -> void:
	_clear_modal()
	_toast("Bonus dilewati. No pressure.")
	_advance_step()

func _show_order(step: Dictionary) -> void:
	order_next = 0
	order_buttons.clear()
	_clear_modal()
	modal = Control.new()
	modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal.mouse_filter = Control.MOUSE_FILTER_STOP
	modal.z_index = 200
	hud_layer.add_child(modal)
	player.call("set_locked", true)
	var dim: ColorRect = ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.18, 0.075, 0.025, 0.64)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	modal.add_child(dim)
	var panel: Panel = _glass_panel(modal, Vector2(190, 80), Vector2(900, 560), Color(0.14, 0.065, 0.025, 0.94), Color(0.94, 0.78, 0.48, 0.46), 26)
	var title: Label = _label(panel, Vector2(35, 25), Vector2(830, 36), "SUSUN LAPORAN", 25, Color("#f3d58b"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var hint: Label = _label(panel, Vector2(65, 68), Vector2(770, 60), "Klik satu per satu dalam urutan yang masuk akal.\nSalah pilih akan reset urutan.", 13, Color(1.0, 0.91, 0.75, 0.78))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var pages: Array = step.get("pages", []) as Array
	for i in pages.size():
		var x: float = 80.0 + float(i % 2) * 390.0
		var y: float = 160.0 + float(floori(float(i) / 2.0)) * 86.0
		var b: Button = _glass_button(panel, str(pages[i]), Vector2(x, y), Vector2(350, 60), 15)
		b.pressed.connect(_answer_order.bind(i, b))
		order_buttons.append(b)

func _answer_order(index: int, button: Button) -> void:
	if index == order_next:
		button.disabled = true
		order_next += 1
		run_points += 45
		if order_next >= order_buttons.size():
			_clear_modal()
			_advance_step()
		else:
			_update_quest_progress()
		return
	perfect_run = false
	order_next = 0
	for value in order_buttons:
		var b: Button = value as Button
		if b != null:
			b.disabled = false
	run_points = maxi(0, run_points - 40)
	_toast("Urutan reset. -40")
	_update_quest_progress()

func _toast(message: String) -> void:
	var toast: Panel = Panel.new()
	toast.position = Vector2(420, 620)
	toast.size = Vector2(440, 42)
	toast.z_index = 100
	toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast.add_theme_stylebox_override("panel", _glass_style(Color(0.16, 0.075, 0.025, 0.92), Color(0.96, 0.76, 0.44, 0.54), 15, 1, 8))
	hud_layer.add_child(toast)
	var label: Label = _label(toast, Vector2(8, 6), Vector2(424, 28), message, 11, Color("#fff6df"))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var tween: Tween = create_tween()
	tween.tween_interval(0.75)
	tween.tween_property(toast, "modulate:a", 0.0, 0.25)
	tween.tween_callback(toast.queue_free)

func _clear_modal() -> void:
	if modal != null and is_instance_valid(modal):
		modal.queue_free()
	modal = null
	if player != null and is_instance_valid(player):
		player.call("set_locked", false)

func _toggle_inventory() -> void:
	if inventory_modal != null and is_instance_valid(inventory_modal):
		_close_inventory()
		return
	_show_inventory()

func _show_inventory() -> void:
	if inventory_modal != null and is_instance_valid(inventory_modal):
		return
	inventory_modal = Control.new()
	inventory_modal.position = Vector2(26, 520)
	inventory_modal.size = Vector2(330, 125)
	inventory_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	inventory_modal.z_index = 250
	hud_layer.add_child(inventory_modal)

	var panel: Panel = _glass_panel(inventory_modal, Vector2(0, 0), Vector2(330, 125), Color(0.11, 0.048, 0.018, 0.90), Color(0.94, 0.78, 0.46, 0.44), 18)
	var title: Label = _label(panel, Vector2(14, 9), Vector2(302, 20), "✦  YOUR BAG", 11, Color("#f5dda1"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var description: Label = _label(panel, Vector2(18, 31), Vector2(294, 60), "", 8, Color("#fff3d5"))
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	if collected.is_empty():
		description.text = "Belum ada barang. Cari sparkle kuning lalu tekan F."
	else:
		description.text = "Barang yang kamu bawa:"
		for key_value in collected.keys():
			description.text += "\n• " + str(key_value)


	var close: Button = _glass_button(panel, "TAB / CLOSE", Vector2(112, 96), Vector2(106, 22), 6)
	close.pressed.connect(_close_inventory)
	if player != null and is_instance_valid(player):
		player.call("set_locked", true)

func _close_inventory() -> void:
	if inventory_modal != null and is_instance_valid(inventory_modal):
		inventory_modal.queue_free()
	inventory_modal = null
	if player != null and is_instance_valid(player):
		player.call("set_locked", false)

func _toggle_pause_menu() -> void:
	if pause_modal != null and is_instance_valid(pause_modal):
		_close_pause_menu()
		return
	_show_pause_menu()

func _show_pause_menu() -> void:
	if inventory_modal != null and is_instance_valid(inventory_modal):
		_close_inventory()
	if pause_modal != null and is_instance_valid(pause_modal):
		return
	pause_modal = Control.new()
	pause_modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_modal.z_index = 300
	hud_layer.add_child(pause_modal)
	if player != null and is_instance_valid(player):
		player.call("set_locked", true)

	var dim: ColorRect = ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.14, 0.06, 0.02, 0.48)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pause_modal.add_child(dim)

	var panel: Panel = _glass_panel(pause_modal, Vector2(430, 148), Vector2(420, 424), Color(0.14, 0.065, 0.025, 0.88), Color(0.94, 0.78, 0.48, 0.42), 24)
	var title: Label = _label(panel, Vector2(24, 16), Vector2(372, 34), "✦  CAMPUS MENU", 19, Color("#f7e2ae"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var info: Label = _label(panel, Vector2(42, 54), Vector2(336, 42), "Simpan progress kapan saja.\nLAN sync ikut jalan saat save.", 9, Color(1.0, 0.90, 0.73, 0.66))
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var save_btn: Button = _glass_button(panel, "SAVE PROGRESS", Vector2(55, 108), Vector2(310, 44), 10)
	save_btn.pressed.connect(_pause_save)
	var settings_btn: Button = _glass_button(panel, "SETTINGS", Vector2(55, 163), Vector2(310, 44), 10)
	settings_btn.pressed.connect(_show_pause_settings)
	var guide_btn: Button = _glass_button(panel, "HOW TO PLAY", Vector2(55, 218), Vector2(310, 44), 10)
	guide_btn.pressed.connect(_pause_guide)
	var exit_btn: Button = _glass_button(panel, "SAVE & EXIT", Vector2(55, 273), Vector2(310, 44), 10)
	exit_btn.pressed.connect(_pause_exit)

	var close: Button = _glass_button(panel, "CLOSE", Vector2(145, 343), Vector2(130, 34), 9)
	close.pressed.connect(_close_pause_menu)

func _pause_save() -> void:
	_save_progress()
	_toast("Progress tersimpan ✦")

func _pause_guide() -> void:
	_close_pause_menu()
	_show_tutorial(true)

func _pause_exit() -> void:
	_save_progress()
	_close_pause_menu()
	SceneManager.go_to("res://scenes/main/MainMenu.tscn")

func _show_pause_settings() -> void:
	if pause_settings_modal != null and is_instance_valid(pause_settings_modal):
		return
	pause_settings_modal = Control.new()
	pause_settings_modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_settings_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_settings_modal.z_index = 320
	hud_layer.add_child(pause_settings_modal)

	var panel: Panel = _glass_panel(pause_settings_modal, Vector2(350, 70), Vector2(580, 600), Color(0.14, 0.065, 0.025, 0.94), Color(0.94, 0.78, 0.48, 0.46), 24)
	var title: Label = _label(panel, Vector2(28, 16), Vector2(524, 32), "SETTINGS", 20, Color("#f7e2ae"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	_label(panel, Vector2(42, 62), Vector2(160, 20), "Master Volume", 10, Color("#fff1ce"))
	var master: HSlider = HSlider.new()
	master.position = Vector2(215, 58)
	master.size = Vector2(280, 24)
	master.min_value = 0.0
	master.max_value = 100.0
	master.step = 1.0
	master.value = GameState.master_volume * 100.0
	master.value_changed.connect(_on_pause_master_changed)
	panel.add_child(master)

	_label(panel, Vector2(42, 104), Vector2(160, 20), "Music", 10, Color("#fff1ce"))
	var music: HSlider = HSlider.new()
	music.position = Vector2(215, 100)
	music.size = Vector2(280, 24)
	music.min_value = 0.0
	music.max_value = 100.0
	music.step = 1.0
	music.value = GameState.music_volume * 100.0
	music.value_changed.connect(_on_pause_music_changed)
	panel.add_child(music)

	_label(panel, Vector2(42, 146), Vector2(160, 20), "Sound Effects", 10, Color("#fff1ce"))
	var sfx: HSlider = HSlider.new()
	sfx.position = Vector2(215, 142)
	sfx.size = Vector2(280, 24)
	sfx.min_value = 0.0
	sfx.max_value = 100.0
	sfx.step = 1.0
	sfx.value = GameState.sfx_volume * 100.0
	sfx.value_changed.connect(_on_pause_sfx_changed)
	panel.add_child(sfx)

	_label(panel, Vector2(42, 194), Vector2(170, 20), "Guide Arrow", 10, Color("#fff1ce"))
	var guide: CheckButton = CheckButton.new()
	guide.position = Vector2(215, 189)
	guide.text = "ON / OFF"
	guide.button_pressed = GameState.show_guide_arrow
	guide.toggled.connect(_on_pause_guide_toggle)
	panel.add_child(guide)

	_label(panel, Vector2(42, 236), Vector2(170, 20), "Auto Save", 10, Color("#fff1ce"))
	var auto: CheckButton = CheckButton.new()
	auto.position = Vector2(215, 231)
	auto.text = "ON / OFF"
	auto.button_pressed = GameState.auto_save
	auto.toggled.connect(_on_pause_autosave_toggle)
	panel.add_child(auto)

	_label(panel, Vector2(42, 282), Vector2(160, 20), "Fullscreen", 10, Color("#fff1ce"))
	var fullscreen: CheckButton = CheckButton.new()
	fullscreen.position = Vector2(215, 276)
	fullscreen.text = "ON / OFF"
	fullscreen.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fullscreen.toggled.connect(_on_pause_fullscreen_toggle)
	panel.add_child(fullscreen)

	_label(panel, Vector2(42, 328), Vector2(160, 20), "LAN Server", 10, Color("#fff1ce"))
	pause_server_input = LineEdit.new()
	pause_server_input.position = Vector2(170, 322)
	pause_server_input.size = Vector2(325, 38)
	pause_server_input.text = GameState.get_server_url()
	pause_server_input.add_theme_font_size_override("font_size", 9)
	pause_server_input.add_theme_color_override("font_color", Color("#fff4db"))
	pause_server_input.add_theme_stylebox_override("normal", _glass_style(Color(0.08, 0.03, 0.012, 0.56), Color(0.92, 0.74, 0.44, 0.24), 10, 1, 3))
	panel.add_child(pause_server_input)

	pause_status = _label(panel, Vector2(45, 376), Vector2(490, 24), "", 8, Color("#ecdba7"))
	pause_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var apply: Button = _glass_button(panel, "SAVE SETTINGS", Vector2(80, 434), Vector2(185, 40), 9)
	apply.pressed.connect(_save_pause_settings)
	var close: Button = _glass_button(panel, "BACK", Vector2(315, 434), Vector2(185, 40), 9)
	close.pressed.connect(_close_pause_settings)

func _on_pause_fullscreen_toggle(enabled: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED)

func _on_pause_master_changed(value: float) -> void:
	GameState.master_volume = clampf(value / 100.0, 0.0, 1.0)
	GameState._apply_audio_settings()

func _on_pause_music_changed(value: float) -> void:
	GameState.music_volume = clampf(value / 100.0, 0.0, 1.0)
	GameState._apply_audio_settings()

func _on_pause_sfx_changed(value: float) -> void:
	GameState.sfx_volume = clampf(value / 100.0, 0.0, 1.0)
	GameState._apply_audio_settings()

func _on_pause_guide_toggle(enabled: bool) -> void:
	GameState.show_guide_arrow = enabled

func _on_pause_autosave_toggle(enabled: bool) -> void:
	GameState.auto_save = enabled

func _save_pause_settings() -> void:
	if pause_server_input != null and is_instance_valid(pause_server_input):
		GameState.set_server_url(pause_server_input.text.strip_edges())
	GameState.save_settings()
	if pause_status != null and is_instance_valid(pause_status):
		pause_status.text = "SAVED • " + GameState.get_server_status_text()

func _close_pause_settings() -> void:
	if pause_settings_modal != null and is_instance_valid(pause_settings_modal):
		pause_settings_modal.queue_free()
	pause_settings_modal = null

func _close_pause_menu() -> void:
	_close_pause_settings()
	if pause_modal != null and is_instance_valid(pause_modal):
		pause_modal.queue_free()
	pause_modal = null
	if player != null and is_instance_valid(player):
		player.call("set_locked", false)

func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key: InputEventKey = event as InputEventKey
	if not key.pressed or key.echo:
		return

	if tutorial_modal != null and is_instance_valid(tutorial_modal):
		if key.keycode in [KEY_E, KEY_ENTER, KEY_SPACE]:
			_close_tutorial()
			get_viewport().set_input_as_handled()
		return

	if key.keycode in [KEY_E, KEY_ENTER, KEY_SPACE]:
		_handle_interact()
		get_viewport().set_input_as_handled()
		return
	if key.keycode == KEY_F:
		_handle_pickup()
		get_viewport().set_input_as_handled()
		return
	if key.keycode == KEY_G:
		_handle_submit()
		get_viewport().set_input_as_handled()
		return
	if key.keycode == KEY_F5:
		_save_progress()
		get_viewport().set_input_as_handled()
		return
	if key.keycode == KEY_TAB:
		_toggle_inventory()
		get_viewport().set_input_as_handled()
		return
	if key.keycode == KEY_ESCAPE:
		if pause_settings_modal != null and is_instance_valid(pause_settings_modal):
			_close_pause_settings()
		elif pause_modal != null and is_instance_valid(pause_modal):
			_close_pause_menu()
		elif modal != null and is_instance_valid(modal):
			_clear_modal()
			if quest_running and not current_quest_id.is_empty():
				call_deferred("_setup_current_step")
		else:
			_show_pause_menu()
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	_update_nearby_hint()
	_update_guidance()
	_update_timer()
	if player != null and GameState.loaded_from_save:
		GameState.player_position = player.position
	if GameState.auto_save and player != null and not (modal != null and is_instance_valid(modal)) and not (pause_modal != null and is_instance_valid(pause_modal)):
		autosave_clock += delta
		if autosave_clock >= 20.0:
			autosave_clock = 0.0
			_save_progress()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and GameState.auto_save and player != null and is_instance_valid(player):
		_save_progress()
