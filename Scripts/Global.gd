extends Node

var game_manager:Node#set by game_manager itself
var anomaly_manager:Node#set by anomaly_manager itself
var audio_manager:Node
var narration_manager:Node

var player:Node3D#set by player itself
var world:Node3D#set by world itself
#Scenes:PackedScenes
var main:PackedScene = preload("res://Scenes/main.tscn")
var main_screen:PackedScene = preload("res://Scenes/Screens/main_screen.tscn")
var win_screen:PackedScene = preload("res://Scenes/Screens/win_screen.tscn")

var first_time:bool=true
var last_time:bool = false
var current_wave:int=1#start with 1 only :)

var toy_models = {
	"ball":preload("res://Scenes/Toys_models/ball_1.tscn"),
	"car1":preload("res://Scenes/Toys_models/car_1.tscn"),
	"car2":preload("res://Scenes/Toys_models/car_2.tscn"),
	"car3":preload("res://Scenes/Toys_models/car_3.tscn"),
	"car4":preload("res://Scenes/Toys_models/car_4.tscn"),
	"ship1":preload("res://Scenes/Toys_models/ship_1.tscn"),
	"ship2":preload("res://Scenes/Toys_models/ship_2.tscn"),
	"train1":preload("res://Scenes/Toys_models/train_1.tscn"),
	"train2":preload("res://Scenes/Toys_models/train_2.tscn"),
}

var box_models = {
	"red":preload("res://Scenes/Box/GiftModels/redbox.tscn"),
	"blue":preload("res://Scenes/Box/GiftModels/bluebox.tscn"),
	"green":preload("res://Scenes/Box/GiftModels/greenbox.tscn"),
	"white":preload("res://Scenes/Box/GiftModels/whitebox.tscn"),
	"yellow":preload("res://Scenes/Box/GiftModels/yellowbox.tscn"),
}

var toy_icons = {
	"ball":preload("res://Assets/2D_icons/foot_ball.png"),
	"car1":preload("res://Assets/2D_icons/car_1.png"),
	"car2":preload("res://Assets/2D_icons/car_2.png"),
	"car3":preload("res://Assets/2D_icons/car_3.png"),
	"car4":preload("res://Assets/2D_icons/car_4.png"),
	"ship1":preload("res://Assets/2D_icons/ship_1.png"),
	"ship2":preload("res://Assets/2D_icons/ship_2.png"),
	"train1":preload("res://Assets/2D_icons/train_1.png"),
	"train2":preload("res://Assets/2D_icons/train_2.png"),	
}

var toy_pickup_sounds = {
	"ball":[preload("res://SFX/GameSounds/pickup_football.wav"),-20],
	"car1":[preload("res://SFX/GameSounds/pickup_plastic_toy.wav"),2],
	"car2":[preload("res://SFX/GameSounds/pickup_plastic_toy.wav"),2],
	"car3":[preload("res://SFX/GameSounds/pickup_plastic_toy.wav"),2],
	"car4":[preload("res://SFX/GameSounds/pickup_plastic_toy.wav"),2],
	"ship1":[preload("res://SFX/GameSounds/pickup_plastic_toy.wav"),2],
	"ship2":[preload("res://SFX/GameSounds/pickup_plastic_toy.wav"),2],
	"train1":[preload("res://SFX/GameSounds/pickup_plastic_toy.wav"),2],
	"train2":[preload("res://SFX/GameSounds/pickup_plastic_toy.wav"),2],	
}

enum anomaly_types {
	NONE,FAST_SPEED,INVERT_GRAVITY,FOG,LIGHTS_OFF,HEAVY_TOY,HYPEROPIA,ADAMANT_BOX\
	,CLUMSY_TOY,RED_LIGHT,CORRUPTED_TOY,MIMIC,WATCHER,THE_EYE
}
#Narration Globals
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
	[preload("res://SFX/Narration/b u still dow there.mp3"),0.2],
	[preload("res://SFX/Narration/p yeah.mp3"),0.5],
	[preload("res://SFX/Narration/b overtimee.mp3"),0.2],
	[preload("res://SFX/Narration/p-kidding-2.mp3"),0.1],
	[preload("res://SFX/Narration/b u r doin onemore.mp3"),0.1],
	[preload("res://SFX/Narration/p 2days 2.mp3"),0.3],
	[preload("res://SFX/Narration/b boxes dont pack themselves.mp3"),0.4],
	[preload("res://SFX/Narration/p breathe.mp3"),0],
	[preload("res://SFX/Narration/b conveyer in 10.mp3"),0]
]

var final_dialogue_text = [
	["(static noises)",""],
	["BOSS","Good Work.."],
	["BOSS","Alright.."],
	["BOSS","Next shift starting"],
	["YOU","WHAT!? But all the toys have been placed!"],
	["(Laughter)",""],
	["???","You sure?"],
	
]

var final_dialogue_audio = [
	[preload("res://SFX/Narration/static.mp3"),0],
	[preload("res://SFX/Narration/End/b-good-work.wav"),0.2],
	[preload("res://SFX/Narration/End/b-Alright.wav"),0.2],
	[preload("res://SFX/Narration/End/b-next shift s.wav"),0.1],
	[preload("res://SFX/Narration/End/p all toys placed.mp3"),0.1],
	[preload("res://SFX/Narration/End/b laugh.mp3"),1],
	[preload("res://SFX/Narration/End/b_usure.wav"),2],
]

var curr_dailogue_texts
var curr_dialogue_audios

func reset_game():
	first_time=false
	last_time=false
	current_wave=1
	curr_dailogue_texts = initial_dialogue_text
	curr_dialogue_audios = initial_dialogue_audio
