extends Node3D

@export var environment:WorldEnvironment
@export var lights:Node3D
@export var lights_anim_player:AnimationPlayer

const BOX_SCENE:PackedScene = preload("res://Scenes/Box/box.tscn")
var toy_script = preload("res://Scripts/Toys.gd")

@onready var toy_init_spawn_pos = $Toy_locations.global_position
@onready var box_init_spawn_pos = $Boxes_locations.global_position - Vector3(0,1,0)
@onready var toy_spawn_locations = $Toy_locations.get_children()
@onready var box_spawn_locations = $Boxes_locations.get_children()
@onready var random_locations = $Random_locations.get_children()
@onready var toys = $Toys
@onready var boxes = $Boxes

#Anomaly
var player_in_pickup_zone:bool = false
var player_hyperopia:bool = false#Set in anomaly manager
var teleported_box_init_pos:Vector3=Vector3.ZERO#used only for adamant boxes

#Called from toys.gd too
var next_toy_spawn_location

func _ready() -> void:
	Global.world = self
	reset_fog()
	
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
	toy.global_position = toy_init_spawn_pos
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

func spawn_boxes(toys_data:Array):
	var shuff_toys_data = toys_data.duplicate()
	shuff_toys_data.shuffle()
	
	var no_of_boxes = shuff_toys_data.size()
	if no_of_boxes>box_spawn_locations.size():return#I dont have that many boxes!
	
	for i in no_of_boxes:
		var box = BOX_SCENE.instantiate()
		box.toy_placed.connect(Global.anomaly_manager.clear_anomaly_effect)
		boxes.add_child(box)
		box.set_data(shuff_toys_data[i])
		box.set_conv_belt_pos(box_spawn_locations[i].get_child(0).global_position)
		
		box.global_position = box_init_spawn_pos
		var tween = get_tree().create_tween()
		tween.tween_property(box,"global_position", box_spawn_locations[i].get_child(0).global_position,1)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(box,"global_position", box_spawn_locations[i].global_position,0.2)\
		 .set_trans(Tween.TRANS_BACK)
		

func move_packed_box_back(box,pos):#Called from box
	var tween = get_tree().create_tween()
	tween.tween_property(box,"global_position", pos,0.2)\
	 .set_trans(Tween.TRANS_SINE)\
	 .set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(box,"global_position", box_init_spawn_pos ,0.8)\
	 .set_trans(Tween.TRANS_SINE)\
	 .set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	box.visible = false
	
func kill_all_toys_and_boxes():
	for toy in toys.get_children():
		toy.queue_free()
	for box in boxes.get_children():
		box.queue_free()

#anomalies		
func set_fog():
	var tween = get_tree().create_tween()
	tween.tween_property(environment.environment,"fog_density",0.6,1)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_IN_OUT)
	
func reset_fog():
	var tween = get_tree().create_tween()
	tween.tween_property(environment.environment,"fog_density",0.01,1)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_IN_OUT)

func lights_off():
	lights.visible = false
func lights_on():
	lights.visible = true

func _on_pickup_zone_body_entered(_body: Node3D) -> void:
	if player_hyperopia:
		show_icons_in_boxes(true)
func _on_pickup_zone_body_exited(_body: Node3D) -> void:
	if player_hyperopia:
		show_icons_in_boxes(false)

func show_icons_in_boxes(val:bool):
	if boxes.get_children():
		for box in boxes.get_children():
			box.show_icon(val)

func pack_all_boxes():#Called from gamemanager
	if boxes.get_children():
		for box in boxes.get_children():
			box.close_box()

func teleport_box(box:Area3D,back_to_init:bool = false):
	if !teleported_box_init_pos:teleported_box_init_pos=box.global_position
	if back_to_init:
		box.global_position = teleported_box_init_pos
		teleported_box_init_pos=Vector3.ZERO
		return
	var to_loc = random_locations.pick_random().global_position
	box.global_position = to_loc

func start_red_light():
	lights_anim_player.play("lights_flicker")
	await lights_anim_player.animation_finished
	Global.player.red_light_active=true
	Global.player.can_move=true#as lights off when anim finishes
	
	while Global.player.red_light_active:
		await get_tree().create_timer(randf_range(0.4,1)).timeout
		if !Global.player.red_light_active:break
		lights_anim_player.play("lights_flicker")
		await lights_anim_player.animation_finished
		if !Global.player.red_light_active:break
		lights_on()
		Global.player.can_move=false
		await get_tree().create_timer(randf_range(1,1.5)).timeout
		if !Global.player.red_light_active:break
		lights_anim_player.play("lights_flicker")
		await lights_anim_player.animation_finished
		if !Global.player.red_light_active:break
		Global.player.can_move=true
	
	lights_anim_player.play("RESET")
	lights_on()
		
func stop_red_light():
	Global.player.red_light_active=false
	Global.player.can_move=true
	lights_on()
	lights_anim_player.play("RESET")
		
