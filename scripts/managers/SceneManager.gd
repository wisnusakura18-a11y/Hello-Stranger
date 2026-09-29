extends Node

func go_to(scene_path: String) -> void:
    if ResourceLoader.exists(scene_path):
        get_tree().change_scene_to_file(scene_path)

func restart() -> void:
    get_tree().reload_current_scene()
