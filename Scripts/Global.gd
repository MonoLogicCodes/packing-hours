extends Node

var game_manager:Node#set by game_manager itself
var player:Node3D
var world:Node3D

var toy_models = {
	"ball":preload("res://Scenes/Toys/toy_ball.tscn"),
	"car1":[],
	"car2":[],
	"lego":[],
	"boat":[],
	"car3":[],
	"train1":[],
	"train2":[],
	"ship1":[],
	"ship2":[],
}

enum anomaly_types {
	NONE,FAST_SPEED,SLOW_SPEED,COLOR_INVERSION
}

enum destinations {
	MUMBAI,CHENNAI,DELHI,KOLKATA
}
