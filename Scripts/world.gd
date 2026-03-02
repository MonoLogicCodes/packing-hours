extends Node3D

const TOY_BALL_SCENE:PackedScene = preload("res://Scenes/Toys/toy_ball.tscn")
const BOX_SCENE:PackedScene = preload("res://Scenes/Box/box.tscn")
var toy_script = load("res://Scripts/Toys.gd")

@onready var toy_spawn_locations = $Toy_locations.get_children()
@onready var box_spawn_locations = $Boxes_locations.get_children()
@onready var toys = $Toys
@onready var boxes = $Boxes

#Called from toys.gd too
var next_toy_spawn_location

func _ready() -> void:
	Global.world = self
	
func try_spawn_toy(toy_data:Array):#called from gamemanager
	if toys.get_child_count() >= toy_spawn_locations.size():return
	
	next_toy_spawn_location = toy_spawn_locations[toys.get_child_count()]
	Global.game_manager.toys_spawned_this_wave+=1
	
	var toy:Area3D = toy_data[0].instantiate()	
	toy.set_script(toy_script)
	toy.set_collision_layer_value(1,false)
	toy.set_collision_layer_value(2,true)
	toy.set_collision_mask_value(1,false)
	toy.set_collision_mask_value(9,true)
	
	toys.add_child(toy)
	toy.set_data(toy_data)
	toy.global_position = next_toy_spawn_location.global_position

func try_move_toy():#Should occur when i pick toy
	await get_tree().create_timer(0.4).timeout
	
	for i in toys.get_child_count():
		var curr_toy = toys.get_child(i)
		if curr_toy.global_position == toy_spawn_locations[i].global_position:
			continue
		curr_toy.global_position = toy_spawn_locations[i].global_position

func spawn_boxes(toys_data):
	var no_of_boxes = toys_data.size()
	if no_of_boxes>box_spawn_locations.size():return#I dont have that many boxes!
	
	for i in no_of_boxes:
		var box = BOX_SCENE.instantiate()
		boxes.add_child(box)
		box.set_data(toys_data[i])
		box.global_position = box_spawn_locations[i].global_position
		
func kill_all_toys_and_boxes():
	for toy in toys.get_children():
		toy.queue_free()
	for box in boxes.get_children():
		box.queue_free()
		
		
