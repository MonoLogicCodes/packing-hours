extends Node3D

const BOX_SCENE:PackedScene = preload("res://Scenes/Box/box.tscn")
var toy_script = preload("res://Scripts/Toys.gd")

@onready var init_spawn_position = $Toy_locations.global_position
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
	
	var toy_scene = Global.toy_models[toy_data[0]]
	var toy:Area3D = toy_scene.instantiate()	
	toy.set_script(toy_script)
	toy.set_collision_layer_value(1,false)
	toy.set_collision_layer_value(2,true)
	toy.set_collision_mask_value(1,false)
	toy.set_collision_mask_value(9,true)
	
	toy.toy_picked.connect(Global.anomaly_manager.try_anomaly_effect)
	toys.add_child(toy)
	toy.set_data(toy_data)
	toy.global_position = init_spawn_position
	var tween = get_tree().create_tween()
	tween.tween_property(toy,"global_position", next_toy_spawn_location.global_position,0.2)\
	 .set_trans(Tween.TRANS_SINE)\
	 .set_ease(Tween.EASE_IN_OUT)

func try_move_toy():#Should occur when i pick toy
	await get_tree().create_timer(0.4).timeout
	
	for i in toys.get_child_count():
		var curr_toy = toys.get_child(i)
		if curr_toy.global_position == toy_spawn_locations[i].global_position:
			continue
		var tween = get_tree().create_tween()
		tween.tween_property(curr_toy,"global_position", toy_spawn_locations[i].global_position,0.1)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_IN_OUT)

func spawn_boxes(toys_data):
	var no_of_boxes = toys_data.size()
	if no_of_boxes>box_spawn_locations.size():return#I dont have that many boxes!
	
	for i in no_of_boxes:
		var box = BOX_SCENE.instantiate()
		box.toy_placed.connect(Global.anomaly_manager.clear_anomaly_effect)
		boxes.add_child(box)
		box.set_data(toys_data[i])
		box.global_position = box_spawn_locations[i].global_position
		
func kill_all_toys_and_boxes():
	for toy in toys.get_children():
		toy.queue_free()
	for box in boxes.get_children():
		box.queue_free()
		
		
