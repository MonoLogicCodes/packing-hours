extends CanvasLayer

@export var wave_timer:Timer
@export var inter_wave_timer:Timer

@export_category("HUD")
@export var hud:Control
@export var hud_wave_timer_label:Label
@export var hud_wave_progress_bar:TextureProgressBar
@export var hud_inter_wave_timer_label:Label
@export var hud_inter_wave_timer_panel:PanelContainer
@export var hud_curr_wave_number:Label

@export_category("Pause Menu")
@export var pause_menu:Control

func _ready() -> void:
	hud_new_wave_started()
	pause_game(false)
	#for HUD
	wave_timer.timeout.connect(reset_hud_wave_timer_label)
	inter_wave_timer.timeout.connect(hud_new_wave_started)
	#for PauseScreen
	Global.player.pause.connect(pause_game)
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
		
func _on_resume_pressed() -> void:
	pause_game(false)
