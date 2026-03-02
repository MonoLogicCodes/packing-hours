extends Node

var game_manager:Node#set by game_manager itself
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

enum anomaly_types {
	NONE,FAST_SPEED,SLOW_SPEED,COLOR_INVERSION
}

enum destinations {
	MUMBAI,CHENNAI,DELHI,KOLKATA
}
