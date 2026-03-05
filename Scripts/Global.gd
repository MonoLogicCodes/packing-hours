extends Node

var game_manager:Node#set by game_manager itself
var anomaly_manager:Node#set by anomaly_manager itself
var player:Node3D#set by player itself
var world:Node3D#set by world itself
#Scenes:PackedScenes
var main:PackedScene = preload("res://Scenes/main.tscn")
var main_screen:PackedScene = preload("res://Scenes/Screens/main_screen.tscn")
var win_screen:PackedScene = preload("res://Scenes/Screens/win_screen.tscn")

var current_wave=1#start with 1 only :)

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

enum anomaly_types {
	NONE,FAST_SPEED,SLOW_SPEED,INVERT_GRAVITY,FOG,LIGHTS_OFF,HEAVY_TOY,HYPEROPIA,ADAMANT_BOX\
	,CLUMSY_TOY,RED_LIGHT
}
