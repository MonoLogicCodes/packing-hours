extends Node

@onready var controls_panel: Panel = $CanvasLayer/controls_panel
@onready var assets_panel: Panel = $CanvasLayer/assets_panel
@onready var start_game_panel: Panel = $CanvasLayer/start_game_panel

@onready var about: Label = $CanvasLayer/Label2

func _ready() -> void:
	controls_panel.visible=false
	assets_panel.visible=false
	start_game_panel.visible=false
	
func _on_load_game_pressed() -> void:
	controls_panel.visible=false
	assets_panel.visible=false
	start_game_panel.visible = !start_game_panel.visible

func _on_quit_pressed() -> void:
	get_tree().quit(0)

func _on_controls_pressed() -> void:
	controls_panel.visible = !controls_panel.visible
	assets_panel.visible=false
	start_game_panel.visible=false

func _on_credits_pressed() -> void:
	assets_panel.visible=!assets_panel.visible
	controls_panel.visible=false
	start_game_panel.visible=false

func _on_start_pressed() -> void:
	Global.current_wave=1
	get_tree().change_scene_to_packed(Global.main)
