extends CanvasLayer

@export var wave_timer:Timer
@export var inter_wave_timer:Timer

@export_category("Effects")
@export var eff_anim_player:AnimationPlayer

@export_category("HUD")
@export var hud:Control
@export var hud_wave_timer_label:Label
@export var hud_wave_progress_bar:TextureProgressBar
@export var hud_inter_wave_timer_label:Label
@export var hud_inter_wave_timer_panel:PanelContainer
@export var hud_curr_wave_number:Label

@export_category("Pause Menu")
@export var pause_menu:Control

@export_category("Lose Screen")
@export var lose_screen:Control
@export var lose_reason_label:Label
@export var lose_what_to_do_label:Label
@export var lose_anomaly_manager:ScrollContainer
@export var lose_need_help:Button

func _ready() -> void:
		
	lose_reason_label.text = ""
	lose_what_to_do_label.text = ""
	hud_new_wave_started()
	lose_screen.visible=false
	lose_anomaly_manager.visible=false
	pause_game(false)
	#For effects
	eff_anim_player.play("RESET")
	#for HUD
	wave_timer.timeout.connect(reset_hud_wave_timer_label)
	inter_wave_timer.timeout.connect(hud_new_wave_started)
	#for PauseScreen
	Global.player.pause.connect(pause_game)
	#For LoseScreen
	Global.player.game_over.connect(game_lose)
	Global.game_manager.game_lose.connect(game_lose)
	set_hud_wave_timer_max()
	
func _process(_delta: float) -> void:
	#HUD
	if not wave_timer.is_stopped():
		var time_left = wave_timer.time_left
		hud_wave_progress_bar.value = time_left
		hud_wave_timer_label.text = str(ceili(time_left))
	if not inter_wave_timer.is_stopped():
		hud_inter_wave_timer_panel.visible = true
		hud_inter_wave_timer_label.text = str(ceili(inter_wave_timer.time_left))

#Effects functions

#HUD functions
func set_hud_wave_timer_max():
	hud_wave_progress_bar.max_value = wave_timer.wait_time
	
func hud_new_wave_started():
	hud_inter_wave_timer_panel.visible = false
	hud_curr_wave_number.text = str(Global.current_wave)
	
func reset_hud_wave_timer_label():
	hud_wave_timer_label.text = "0"
#Pause Menu functions
func pause_game(to_pause:bool):
	if to_pause:Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)	
	pause_menu.visible = to_pause
	get_tree().paused = to_pause

func pause_without_ui():

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true

func _on_resume_pressed() -> void:
	pause_game(false)

func _on_reload_pressed() -> void:
	reload_scene(false)
	
func _on_pstart_over_pressed() -> void:#seperate function cuz to add transition
	pause_without_ui()
	reload_scene(true)
	
func _on_main_menu_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_packed(Global.main_screen)
	
#Lose Screen functions
func game_lose(reason:String = "",what_to_do:String = ""):
	pause_without_ui()
	Global.audio_manager.lose_screen.play()
	eff_anim_player.play("lose_fade")
	await eff_anim_player.animation_finished
	lose_reason_label.text = reason
	lose_what_to_do_label.text = what_to_do
	show_lose_screen(true)
	
func show_lose_screen(val:bool):
	if val:Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	lose_screen.visible = val

func reload_scene(full_reload:bool):
	if full_reload:Global.current_wave=1
	get_tree().reload_current_scene()
	
func _on_go_to_menu_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_packed(Global.main_screen)
	
func _on_start_over_pressed() -> void:
	pause_without_ui()
	reload_scene(true)

func _on_needhellp_toggled(_toggled_on: bool) -> void:
	lose_anomaly_manager.visible = !lose_anomaly_manager.visible
