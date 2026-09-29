extends Node

const PROFILE_DIR: String = "user://hello_stranger_profiles"
const LEGACY_SAVE_PATH: String = "user://hello_stranger_save.json"
const SERVER_CONFIG_PATH: String = "res://data/server_config.json"
const DEFAULT_SERVER_URL: String = "http://127.0.0.1:8765"

var player_name: String = ""
var player_gender: String = "girl"
var current_day: int = 1
var total_score: int = 0
var total_time_seconds: float = 0.0
var quest_scores: Dictionary = {}
var completed_quests: Array = []
var player_position: Vector2 = Vector2(180.0, 320.0)
var active_quest_id: String = ""
var active_quest_elapsed: float = 0.0
var active_step: int = 0
var active_collected: Array = []
var active_live_points: int = 0
var active_return_to_npc: bool = false
var active_perfect_run: bool = true
var intro_seen: bool = false
var tutorial_seen: bool = false
var npc_positions: Dictionary = {}
var loaded_from_save: bool = false

var server_url: String = DEFAULT_SERVER_URL
var last_server_ok: bool = false

var master_volume: float = 0.85
var music_volume: float = 0.70
var sfx_volume: float = 0.85
var show_guide_arrow: bool = true
var auto_save: bool = true
var pending_load_callback: Callable = Callable()
var pending_load_name: String = ""
var pending_leaderboard_callback: Callable = Callable()
var leaderboard_request_in_flight: bool = false

func _ready() -> void:
    server_url = _read_server_url()
    _load_settings()
    _ensure_audio_buses()
    _apply_audio_settings()

func new_game(name_value: String, gender_value: String) -> void:
    player_name = name_value.strip_edges()
    player_gender = gender_value if gender_value in ["girl", "boy"] else "girl"
    current_day = 1
    total_score = 0
    total_time_seconds = 0.0
    quest_scores.clear()
    completed_quests.clear()
    player_position = Vector2(180.0, 320.0)
    active_quest_id = ""
    active_quest_elapsed = 0.0
    active_step = 0
    active_collected.clear()
    active_live_points = 0
    active_return_to_npc = false
    active_perfect_run = true
    intro_seen = false
    tutorial_seen = false
    npc_positions.clear()
    loaded_from_save = false
    save_game(player_position, "", 0.0, [], false, true, 0, 0, false)

func reset_scores() -> void:
    current_day = 1
    total_score = 0
    total_time_seconds = 0.0
    quest_scores.clear()
    completed_quests.clear()
    active_quest_id = ""
    active_quest_elapsed = 0.0
    active_step = 0
    active_collected.clear()
    active_live_points = 0
    active_return_to_npc = false
    active_perfect_run = true
    intro_seen = false
    tutorial_seen = false

func set_quest_score(quest_id: String, score: int, time_seconds: float) -> void:
    if completed_quests.has(quest_id):
        return
    quest_scores[quest_id] = {
        "score": maxi(score, 0),
        "time": maxf(time_seconds, 0.0)
    }
    completed_quests.append(quest_id)
    _recalculate_totals()

func get_quest_score(quest_id: String) -> int:
    if not quest_scores.has(quest_id):
        return 0
    var entry_value: Variant = quest_scores.get(quest_id, {})
    if entry_value is Dictionary:
        var entry: Dictionary = entry_value as Dictionary
        return int(entry.get("score", 0))
    return 0

func _recalculate_totals() -> void:
    total_score = 0
    total_time_seconds = 0.0
    for value in quest_scores.values():
        if value is Dictionary:
            var entry: Dictionary = value as Dictionary
            total_score += int(entry.get("score", 0))
            total_time_seconds += float(entry.get("time", 0.0))

func save_game(
    pos: Vector2 = player_position,
    active_id: String = active_quest_id,
    elapsed: float = active_quest_elapsed,
    collected_value: Array = active_collected,
    return_value: bool = active_return_to_npc,
    perfect_value: bool = active_perfect_run,
    step_value: int = active_step,
    live_points_value: int = active_live_points,
    intro_value: bool = intro_seen
) -> bool:
    player_position = pos
    active_quest_id = active_id
    active_quest_elapsed = maxf(elapsed, 0.0)
    active_collected = collected_value.duplicate()
    active_return_to_npc = return_value
    active_perfect_run = perfect_value
    active_step = maxi(step_value, 0)
    active_live_points = maxi(live_points_value, 0)
    intro_seen = intro_value

    var data: Dictionary = _snapshot()
    var local_ok: bool = _save_local(player_name, data)
    _sync_profile(data)
    return local_ok

func _snapshot() -> Dictionary:
    return {
        "version": 4,
        "player_name": player_name,
        "player_gender": player_gender,
        "current_day": current_day,
        "total_score": total_score,
        "total_time_seconds": total_time_seconds,
        "quest_scores": quest_scores,
        "completed_quests": completed_quests,
        "player_position": {"x": player_position.x, "y": player_position.y},
        "active_quest_id": active_quest_id,
        "active_quest_elapsed": active_quest_elapsed,
        "active_step": active_step,
        "active_collected": active_collected,
        "active_live_points": active_live_points,
        "active_return_to_npc": active_return_to_npc,
        "active_perfect_run": active_perfect_run,
        "intro_seen": intro_seen,
        "tutorial_seen": tutorial_seen,
        "npc_positions": npc_positions
    }

func has_save(name_value: String = "") -> bool:
    var use_name: String = name_value.strip_edges()
    if use_name.is_empty():
        use_name = player_name
    if not use_name.is_empty() and FileAccess.file_exists(_profile_path(use_name)):
        return true
    return FileAccess.file_exists(LEGACY_SAVE_PATH)

func load_game(name_value: String = "") -> bool:
    var use_name: String = name_value.strip_edges()
    if use_name.is_empty():
        use_name = player_name

    var path: String = _profile_path(use_name) if not use_name.is_empty() else LEGACY_SAVE_PATH
    if not FileAccess.file_exists(path):
        path = LEGACY_SAVE_PATH
    if not FileAccess.file_exists(path):
        return false

    var file: FileAccess = FileAccess.open(path, FileAccess.READ)
    if file == null:
        return false
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    file.close()
    if typeof(parsed) != TYPE_DICTIONARY:
        return false
    _apply_snapshot(parsed as Dictionary)
    loaded_from_save = true
    return true

func load_game_for_name(name_value: String, callback: Callable) -> void:
    var clean_name: String = name_value.strip_edges()
    if clean_name.is_empty():
        _call_if_alive(callback, [false, "Masukkan username dulu."])
        return
    pending_load_callback = callback
    pending_load_name = clean_name
    _request_remote_profile(clean_name)

func _apply_snapshot(data: Dictionary) -> void:
    player_name = str(data.get("player_name", "Stranger"))
    player_gender = str(data.get("player_gender", "girl"))
    current_day = clampi(int(data.get("current_day", 1)), 1, 8)
    total_score = maxi(int(data.get("total_score", 0)), 0)
    total_time_seconds = maxf(float(data.get("total_time_seconds", 0.0)), 0.0)

    var quest_scores_value: Variant = data.get("quest_scores", {})
    quest_scores = quest_scores_value as Dictionary if quest_scores_value is Dictionary else {}

    var completed_value: Variant = data.get("completed_quests", [])
    completed_quests = completed_value as Array if completed_value is Array else []

    var position_value: Variant = data.get("player_position", {})
    var p: Dictionary = position_value as Dictionary if position_value is Dictionary else {}
    player_position = Vector2(float(p.get("x", 180.0)), float(p.get("y", 320.0)))

    active_quest_id = str(data.get("active_quest_id", ""))
    active_quest_elapsed = maxf(float(data.get("active_quest_elapsed", 0.0)), 0.0)
    active_step = maxi(int(data.get("active_step", 0)), 0)
    var active_collected_value: Variant = data.get("active_collected", [])
    active_collected = active_collected_value as Array if active_collected_value is Array else []
    active_live_points = maxi(int(data.get("active_live_points", 0)), 0)
    active_return_to_npc = bool(data.get("active_return_to_npc", false))
    active_perfect_run = bool(data.get("active_perfect_run", true))
    intro_seen = bool(data.get("intro_seen", false))
    tutorial_seen = bool(data.get("tutorial_seen", false))
    var npc_positions_value: Variant = data.get("npc_positions", {})
    npc_positions = npc_positions_value as Dictionary if npc_positions_value is Dictionary else {}
    _recalculate_totals()

func set_server_url(url_value: String) -> void:
    var cleaned: String = url_value.strip_edges()
    if cleaned.is_empty():
        server_url = DEFAULT_SERVER_URL
    else:
        server_url = cleaned.trim_suffix("/")
    _save_server_url(server_url)

func get_server_url() -> String:
    return server_url

func get_server_status_text() -> String:
    return "LAN SYNC: ONLINE" if last_server_ok else "LAN SYNC: LOCAL / OFFLINE"

func get_leaderboard(callback: Callable = Callable()) -> Array:
    if callback.is_valid():
        _request_leaderboard(callback)
        return []
    return _local_leaderboard()

func add_leaderboard_entry() -> void:
    _sync_profile(_snapshot())

func _call_if_alive(callback: Callable, arguments: Array) -> void:
    if not callback.is_valid():
        return
    var target: Object = callback.get_object()
    if target != null and not is_instance_valid(target):
        return
    callback.callv(arguments)

func _request_remote_profile(name_value: String) -> void:
    var encoded: String = name_value.uri_encode()
    _http_get(server_url + "/api/profile?name=" + encoded, Callable(self, "_on_remote_profile_http"))

func _on_remote_profile_http(ok: bool, body_text: String) -> void:
    if not pending_load_callback.is_valid():
        return
    if not ok:
        last_server_ok = false
        var local_name: String = pending_load_name
        var callback_copy: Callable = pending_load_callback
        pending_load_callback = Callable()
        pending_load_name = ""
        if local_name.is_empty() or not load_game(local_name):
            _call_if_alive(callback_copy, [false, "Server LAN tidak merespons."])
        else:
            _call_if_alive(callback_copy, [true, "Server offline. Loaded local save."])
        return
    var parsed: Variant = JSON.parse_string(body_text)
    if typeof(parsed) != TYPE_DICTIONARY:
        last_server_ok = false
        var parse_callback: Callable = pending_load_callback
        pending_load_callback = Callable()
        pending_load_name = ""
        _call_if_alive(parse_callback, [false, "Data save server rusak."])
        return
    var response: Dictionary = parsed as Dictionary
    if not bool(response.get("ok", false)) or not (response.get("profile", null) is Dictionary):
        last_server_ok = true
        var missing_callback: Callable = pending_load_callback
        pending_load_callback = Callable()
        pending_load_name = ""
        _call_if_alive(missing_callback, [false, "Username belum punya save."])
        return
    _apply_snapshot(response.get("profile", {}) as Dictionary)
    loaded_from_save = true
    _save_local(player_name, _snapshot())
    last_server_ok = true
    var remote_callback: Callable = pending_load_callback
    pending_load_callback = Callable()
    pending_load_name = ""
    _call_if_alive(remote_callback, [true, "Loaded dari server LAN."])

func _request_leaderboard(callback: Callable) -> void:
    if leaderboard_request_in_flight:
        return
    pending_leaderboard_callback = callback
    leaderboard_request_in_flight = true
    _http_get(server_url + "/api/leaderboard", Callable(self, "_on_leaderboard_http"))

func _on_leaderboard_http(ok: bool, body_text: String) -> void:
    leaderboard_request_in_flight = false
    var callback: Callable = pending_leaderboard_callback
    pending_leaderboard_callback = Callable()
    if not callback.is_valid():
        return
    if not ok:
        last_server_ok = false
        _call_if_alive(callback, [_local_leaderboard(), false])
        return
    var parsed: Variant = JSON.parse_string(body_text)
    if typeof(parsed) != TYPE_DICTIONARY:
        last_server_ok = false
        _call_if_alive(callback, [_local_leaderboard(), false])
        return
    var response: Dictionary = parsed as Dictionary
    if not bool(response.get("ok", false)):
        last_server_ok = false
        _call_if_alive(callback, [_local_leaderboard(), false])
        return
    last_server_ok = true
    var entries_value: Variant = response.get("entries", [])
    if entries_value is Array:
        _call_if_alive(callback, [entries_value as Array, true])
    else:
        _call_if_alive(callback, [[], true])

func _sync_profile(data: Dictionary) -> void:
    if player_name.strip_edges().is_empty():
        return
    _http_post(server_url + "/api/profile", data, Callable(self, "_on_sync_profile_http"))

func _on_sync_profile_http(ok: bool, _body_text: String) -> void:
    last_server_ok = ok

func _http_get(url: String, callback: Callable) -> void:
    var http: HTTPRequest = HTTPRequest.new()
    http.timeout = 2.5
    add_child(http)
    http.request_completed.connect(_on_http_get_completed.bind(callback, http))
    var request_error: int = http.request(url)
    if request_error != OK:
        callback.call(false, "")
        http.queue_free()

func _on_http_get_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, callback: Callable, http: HTTPRequest) -> void:
    var success: bool = result == HTTPRequest.RESULT_SUCCESS and response_code >= 200 and response_code < 300
    var body_text: String = body.get_string_from_utf8()
    callback.call(success, body_text)
    if http != null and is_instance_valid(http):
        http.queue_free()

func _http_post(url: String, data: Dictionary, callback: Callable) -> void:
    var http: HTTPRequest = HTTPRequest.new()
    http.timeout = 2.5
    add_child(http)
    var headers: PackedStringArray = PackedStringArray(["Content-Type: application/json"])
    http.request_completed.connect(_on_http_post_completed.bind(callback, http))
    var request_error: int = http.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(data))
    if request_error != OK:
        callback.call(false, "")
        http.queue_free()

func _on_http_post_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, callback: Callable, http: HTTPRequest) -> void:
    var success: bool = result == HTTPRequest.RESULT_SUCCESS and response_code >= 200 and response_code < 300
    var body_text: String = body.get_string_from_utf8()
    callback.call(success, body_text)
    if http != null and is_instance_valid(http):
        http.queue_free()

func get_player_profiles(callback: Callable = Callable()) -> Array:
    if callback.is_valid():
        _request_leaderboard(callback)
        return []
    return _local_profile_list()

func _local_leaderboard() -> Array:
    return _local_profile_list()

func _local_profile_list() -> Array:
    var result: Array = []
    _ensure_profile_dir()
    var dir: DirAccess = DirAccess.open(PROFILE_DIR)
    if dir == null:
        return result
    dir.list_dir_begin()
    while true:
        var filename: String = dir.get_next()
        if filename.is_empty():
            break
        if dir.current_is_dir() or not filename.ends_with(".json"):
            continue
        var file: FileAccess = FileAccess.open(PROFILE_DIR + "/" + filename, FileAccess.READ)
        if file == null:
            continue
        var parsed: Variant = JSON.parse_string(file.get_as_text())
        file.close()
        if parsed is Dictionary:
            result.append(_leaderboard_entry_from_snapshot(parsed as Dictionary))
    dir.list_dir_end()
    result.sort_custom(Callable(self, "_sort_local_entries"))
    return result

func _sort_local_entries(a: Dictionary, b: Dictionary) -> bool:
    return str(a.get("name", "")).to_lower() < str(b.get("name", "")).to_lower()

func _leaderboard_entry_from_snapshot(data: Dictionary) -> Dictionary:
    var quests_value: Variant = data.get("completed_quests", [])
    var quests_done: int = quests_value.size() if quests_value is Array else 0
    return {
        "name": str(data.get("player_name", "STRANGER")),
        "gender": str(data.get("player_gender", "girl")),
        "score": int(data.get("total_score", 0)),
        "time": float(data.get("total_time_seconds", 0.0)),
        "quests": quests_done,
        "day": clampi(int(data.get("current_day", 1)), 1, 8)
    }

func _profile_path(name_value: String) -> String:
    _ensure_profile_dir()
    return PROFILE_DIR + "/" + _safe_name(name_value) + ".json"

func _safe_name(name_value: String) -> String:
    var lowered: String = name_value.strip_edges().to_lower()
    var safe: String = ""
    for i in lowered.length():
        var ch: String = lowered.substr(i, 1)
        if (ch >= "a" and ch <= "z") or (ch >= "0" and ch <= "9") or ch in ["_", "-"]:
            safe += ch
        elif ch == " ":
            safe += "_"
    if safe.is_empty():
        safe = "stranger"
    return safe.substr(0, 32)

func _ensure_profile_dir() -> void:
    var absolute_path: String = ProjectSettings.globalize_path(PROFILE_DIR)
    DirAccess.make_dir_recursive_absolute(absolute_path)

func _save_local(name_value: String, data: Dictionary) -> bool:
    if name_value.strip_edges().is_empty():
        return false
    var file: FileAccess = FileAccess.open(_profile_path(name_value), FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(JSON.stringify(data))
    file.close()
    return true

func _settings_path() -> String:
    return "user://hello_stranger_settings.json"

func _load_settings() -> void:
    var path: String = _settings_path()
    if not FileAccess.file_exists(path):
        return
    var file: FileAccess = FileAccess.open(path, FileAccess.READ)
    if file == null:
        return
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    file.close()
    if not (parsed is Dictionary):
        return
    var data: Dictionary = parsed as Dictionary
    master_volume = clampf(float(data.get("master_volume", master_volume)), 0.0, 1.0)
    music_volume = clampf(float(data.get("music_volume", music_volume)), 0.0, 1.0)
    sfx_volume = clampf(float(data.get("sfx_volume", sfx_volume)), 0.0, 1.0)
    show_guide_arrow = bool(data.get("show_guide_arrow", show_guide_arrow))
    auto_save = bool(data.get("auto_save", auto_save))

func save_settings() -> void:
    var data: Dictionary = {
        "master_volume": master_volume,
        "music_volume": music_volume,
        "sfx_volume": sfx_volume,
        "fullscreen": DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN,
        "show_guide_arrow": show_guide_arrow,
        "auto_save": auto_save
    }
    var file: FileAccess = FileAccess.open(_settings_path(), FileAccess.WRITE)
    if file != null:
        file.store_string(JSON.stringify(data))
        file.close()
    _apply_audio_settings()

func _ensure_audio_buses() -> void:
    var music_index: int = AudioServer.get_bus_index("Music")
    if music_index < 0:
        AudioServer.add_bus()
        music_index = AudioServer.get_bus_count() - 1
        AudioServer.set_bus_name(music_index, "Music")
        AudioServer.set_bus_send(music_index, "Master")
    var sfx_index: int = AudioServer.get_bus_index("SFX")
    if sfx_index < 0:
        AudioServer.add_bus()
        sfx_index = AudioServer.get_bus_count() - 1
        AudioServer.set_bus_name(sfx_index, "SFX")
        AudioServer.set_bus_send(sfx_index, "Master")

func _apply_audio_settings() -> void:
    _ensure_audio_buses()
    var master_index: int = AudioServer.get_bus_index("Master")
    if master_index >= 0:
        AudioServer.set_bus_volume_db(master_index, linear_to_db(maxf(master_volume, 0.001)))
    var music_index: int = AudioServer.get_bus_index("Music")
    if music_index >= 0:
        AudioServer.set_bus_volume_db(music_index, linear_to_db(maxf(music_volume, 0.001)))
    var sfx_index: int = AudioServer.get_bus_index("SFX")
    if sfx_index >= 0:
        AudioServer.set_bus_volume_db(sfx_index, linear_to_db(maxf(sfx_volume, 0.001)))

func _read_server_url() -> String:
    var user_path: String = "user://hello_stranger_server_url.txt"
    if FileAccess.file_exists(user_path):
        var user_file: FileAccess = FileAccess.open(user_path, FileAccess.READ)
        if user_file != null:
            var user_value: String = user_file.get_as_text().strip_edges()
            user_file.close()
            if not user_value.is_empty():
                return user_value.trim_suffix("/")
    if not FileAccess.file_exists(SERVER_CONFIG_PATH):
        return DEFAULT_SERVER_URL
    var file: FileAccess = FileAccess.open(SERVER_CONFIG_PATH, FileAccess.READ)
    if file == null:
        return DEFAULT_SERVER_URL
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    file.close()
    if typeof(parsed) == TYPE_DICTIONARY:
        var cfg: Dictionary = parsed as Dictionary
        var configured: String = str(cfg.get("url", DEFAULT_SERVER_URL)).strip_edges()
        return configured.trim_suffix("/") if not configured.is_empty() else DEFAULT_SERVER_URL
    return DEFAULT_SERVER_URL

func _save_server_url(url_value: String) -> void:
    var path: String = "user://hello_stranger_server_url.txt"
    var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
    if file != null:
        file.store_string(url_value)
        file.close()
