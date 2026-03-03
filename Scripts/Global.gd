extends Node

var game_manager:Node#set by game_manager itself
var anomaly_manager:Node#set by anomaly_manager itself
var player:Node3D
var world:Node3D

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

var toy_icons = {
	"ball":preload("res://icon.svg"),
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
	NONE,FAST_SPEED,SLOW_SPEED,INVERT_CAMERA,INVERT_GRAVITY,INVERT_COLOR
}
