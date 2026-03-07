extends Node

@export var audio_player:AudioStreamPlayer
@export var subtitle_label:Label

var initial_dialogue_text = [
	["(static noises)",""],
	["BOSS","Hey...You still awake down there?"],
	["YOU","...yeah?"],
	["BOSS","Good.. Listen..We've got a backlog of orders tonight..so your gonna have to work overtime."],
	["YOU","You've got to be kidding..I've already worked three shifts!"],
	["BOSS","and you are doing one more."],
	["YOU","I've been here...two days straight..."],
	["BOSS","Boxes don't pack themselves..We've got orders piling up! NO TIME TO WASTE!"],
	["YOU","..."],
	["BOSS","Conveyer starts in 10 seconds.. Try not to fall asleep again."]
]
var initial_dialogue_audio = [
	[preload("res://SFX/Narration/static.mp3"),0],
	[preload("res://SFX/Narration/b u still dow there.mp3"),0.4],
	[preload("res://SFX/Narration/p yeah.mp3"),1],
	[preload("res://SFX/Narration/b overtimee.mp3"),0.2],
	[preload("res://SFX/Narration/p-kidding-2.mp3"),0.1],
	[preload("res://SFX/Narration/b u r doin onemore.mp3"),0.1],
	[preload("res://SFX/Narration/p 2days 2.mp3"),0.3],
	[preload("res://SFX/Narration/b boxes dont pack themselves.mp3"),0.4],
	[preload("res://SFX/Narration/p breathe.mp3"),0],
	[preload("res://SFX/Narration/b conveyer in 10.mp3"),0]
]
var curr_dailogue_texts
var curr_dialogue_audios
var curr_line_idx=0

func _ready() -> void:
	subtitle_label.get_parent().visible = false
	curr_dailogue_texts = initial_dialogue_text
	curr_dialogue_audios = initial_dialogue_audio
	Global.narration_manager = self
	
	await  get_tree().create_timer(2).timeout
	
	if Global.first_time:
		Global.world.show_boss()
		subtitle_label.get_parent().visible = true
		speak_next_line()
	
func speak_next_line():
	subtitle_label.text = curr_dailogue_texts[curr_line_idx][0]
	if !curr_dailogue_texts[curr_line_idx][1] == "":subtitle_label.text +=" : " + curr_dailogue_texts[curr_line_idx][1]
	audio_player.stream = curr_dialogue_audios[curr_line_idx][0]
	audio_player.play()

func _on_audio_stream_player_finished() -> void:
	await get_tree().create_timer(curr_dialogue_audios[curr_line_idx][1]).timeout
	if curr_line_idx<curr_dailogue_texts.size()-1:
		curr_line_idx+=1
		speak_next_line()
	else:
		hide_subtitles()
		if Global.first_time:
			Global.world.hide_boss()
			Global.first_time=false

func hide_subtitles():
	subtitle_label.get_parent().visible = false
	subtitle_label.text = ""
