extends Node


func _on_load_game_pressed() -> void:
	Global.current_wave=1
	get_tree().change_scene_to_packed(Global.main)

func _on_quit_pressed() -> void:
	get_tree().quit(0)
