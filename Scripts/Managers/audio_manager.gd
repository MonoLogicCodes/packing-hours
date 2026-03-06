extends Node


@onready var ventillation: AudioStreamPlayer = $AmbientSounds/Ventillation
@onready var walking: AudioStreamPlayer = $GameSounds/walking
@onready var toy_picked: AudioStreamPlayer = $GameSounds/toy_picked
@onready var toy_placed: AudioStreamPlayer = $GameSounds/toy_placed
@onready var pop: AudioStreamPlayer = $GameSounds/pop
@onready var gift_wrap: AudioStreamPlayer = $GameSounds/gift_wrap
@onready var box_close: AudioStreamPlayer = $GameSounds/box_close
@onready var lose_screen: AudioStreamPlayer = $MenuSounds/lose_screen
@onready var the_eye: AudioStreamPlayer = $AmbientSounds/TheEye
@onready var watcher: AudioStreamPlayer = $AmbientSounds/Watcher
@onready var entity_appear: AudioStreamPlayer = $AmbientSounds/EntityAppear
@onready var swoosh: AudioStreamPlayer = $GameSounds/swoosh
@onready var swoosh_2: AudioStreamPlayer = $GameSounds/swoosh2
@onready var gravity: AudioStreamPlayer = $GameSounds/gravity
@onready var riser: AudioStreamPlayer = $GameSounds/riser
@onready var teleport: AudioStreamPlayer = $GameSounds/teleport
@onready var fall: AudioStreamPlayer = $GameSounds/fall
@onready var green_light: AudioStreamPlayer = $GameSounds/green_light
@onready var bulb_break: AudioStreamPlayer = $GameSounds/bulb_break


@onready var bgm_themes = {
	"normal":ventillation,
	"the_eye":the_eye,
	"watcher":watcher
}

func _ready() -> void:
	Global.audio_manager = self

func picked_up_toy(toy_model:String):
	toy_picked.stream=Global.toy_pickup_sounds[toy_model][0]
	toy_picked.volume_db=Global.toy_pickup_sounds[toy_model][1]
	toy_picked.play()

func play_current_main_theme(theme:String):
	for aud_name in bgm_themes.keys():
		if aud_name==theme:
			bgm_themes[aud_name].play()
			continue
		bgm_themes[aud_name].stop()
		
