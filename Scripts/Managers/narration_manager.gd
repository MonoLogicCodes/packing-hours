extends Node

@export var narration_ui:Control
@export var audio_player:AudioStreamPlayer
@export var subtitle_label:Label

var curr_line_idx=0

func _ready() -> void:
	narration_ui.visible=true
	subtitle_label.get_parent().visible = false
	Global.narration_manager = self
	
func speak_next_line():
	subtitle_label.text = Global.curr_dailogue_texts[curr_line_idx][0]
	subtitle_label.get_parent().visible = true
	if !Global.curr_dailogue_texts[curr_line_idx][1] == "":subtitle_label.text +=" : " + Global.curr_dailogue_texts[curr_line_idx][1]
	audio_player.stream = Global.curr_dialogue_audios[curr_line_idx][0]
	audio_player.play()

func _on_audio_stream_player_finished() -> void:
	
	if curr_line_idx<Global.curr_dailogue_texts.size()-1:
		#Final transition
		if Global.last_time and curr_line_idx==Global.curr_dailogue_texts.size()-3:
			Global.world.play_last_transition()
			
		await get_tree().create_timer(Global.curr_dialogue_audios[curr_line_idx][1]).timeout
		curr_line_idx+=1
		speak_next_line()
	else:
		hide_subtitles()
		if Global.first_time:
			Global.world.hide_boss()
			Global.first_time=false
			
		if Global.last_time:#End of game code
			Global.reset_game()
			await get_tree().create_timer(1.8).timeout
			var tween = get_tree().create_tween()
			Global.world.final_fade.visible=true
			tween.tween_property(Global.world.final_fade,"color",Color("000000"),1.5)
			await tween.finished
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			await get_tree().process_frame
			get_tree().change_scene_to_packed(Global.win_screen)
			

func hide_subtitles():
	subtitle_label.get_parent().visible = false
	subtitle_label.text = ""

func skip_narration():
	curr_line_idx=Global.curr_dailogue_texts.size()-1
	_on_audio_stream_player_finished()
