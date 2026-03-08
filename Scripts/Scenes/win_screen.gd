extends Node

func _ready() -> void:
	$AudioStreamPlayer.play(6.93866682052612)

func _on_title_pressed() -> void:
	get_tree().change_scene_to_packed(Global.main_screen)
