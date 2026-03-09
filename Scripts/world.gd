extends Node3D

@export var environment:WorldEnvironment
@export var lights:Node3D
@export var lights_anim_player:AnimationPlayer

const BOX_SCENE:PackedScene = preload("res://Scenes/Box/box.tscn")
const WATCHER_SCENE:PackedScene = preload("res://Scenes/Entities/watcher.tscn")
const THE_EYE:PackedScene = preload("res://Scenes/Entities/the_eye.tscn")
var toy_script = preload("res://Scripts/Toys.gd")
var bulb_mat:BaseMaterial3D = preload("res://Assets/3D_models/bulb/bulbmat.tres")

@onready var toy_init_spawn_pos = $Toy_locations.global_position
@onready var box_init_spawn_pos = $Boxes_locations.global_position 
@onready var trash_box_pos = $Random_locations/rloc6.global_position
@onready var watcher_pos =$Random_locations/rloc5.global_position
@onready var the_eye_pos = $the_eye_pos.global_position
@onready var toy_spawn_locations = $Toy_locations.get_children()
@onready var box_spawn_locations = $Boxes_locations.get_children()
@onready var random_locations = $Random_locations.get_children()
@onready var toys = $Toys
@onready var boxes = $Boxes
@onready var boss_anim_player = $boss/AnimationPlayer
@onready var fwatcher: Node3D = $fwatcher

#Anomaly
var player_in_pickup_zone:bool = false
var player_hyperopia:bool = false#Set in anomaly manager
var teleported_box_init_pos:Vector3=Vector3.ZERO#used only for adamant boxes
var t_box#used later to delete t_box once placed

var watcher:Node3D#used as ref in box.gd too
var watcher_visibility_box:VisibleOnScreenNotifier3D
var watcher_timer:Timer
var saw_watcher:bool = false #initiates the 'watching' game
var watcher_in_view:bool = false
var times_to_see_watcher:int

var the_eye:Node3D
#Called from toys.gd too
var next_toy_spawn_location

func _ready() -> void:
	print("world loaded")
	#await get_tree().physics_frame
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.world = self
	#reset_fog()
	bulb_mat.emission_energy_multiplier=1#reset material
	
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
	Global.audio_manager.swoosh_2.play()

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
		box.scale = Vector3(0.01,0.01,0.01)
		box.global_position = box_init_spawn_pos
		
		var tween = get_tree().create_tween()
		tween.tween_property(box,"global_position", box_spawn_locations[i].get_child(0).global_position,1)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_IN_OUT)
		tween.parallel().tween_property(box,"scale",Vector3(1,1,1),1)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(box,"global_position", box_spawn_locations[i].global_position,0.2)\
		 .set_trans(Tween.TRANS_BACK)
		

func move_packed_box_back(box,pos):#Called from box
	var tween = get_tree().create_tween()
	tween.tween_property(box,"global_position", pos,0.2)\
	 .set_trans(Tween.TRANS_SINE)\
	 .set_ease(Tween.EASE_IN_OUT)
	Global.audio_manager.swoosh.play()
	tween.tween_property(box,"global_position", box_init_spawn_pos ,0.8)\
	 .set_trans(Tween.TRANS_SINE)\
	 .set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(box,"scale",Vector3(0.01,0.01,0.01),0.8)\
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
func spawn_trash_box(data):
	if t_box!=null:return#only 1 t_box possible
	t_box = BOX_SCENE.instantiate()
	t_box.toy_placed.connect(Global.anomaly_manager.clear_anomaly_effect)
	add_child(t_box)
	t_box.global_position = trash_box_pos
	t_box.set_data(data)
	t_box.is_trash_box=true
	Global.audio_manager.teleport.play()

func remove_trash_box():
	t_box.queue_free()
	t_box = null

#func set_fog():
	#var tween = get_tree().create_tween()
	#tween.tween_property(environment.environment,"fog_density",0.6,1)\
		 #.set_trans(Tween.TRANS_SINE)\
		 #.set_ease(Tween.EASE_IN_OUT)
	
#func reset_fog():
	#var tween = get_tree().create_tween()
	#tween.tween_property(environment.environment,"fog_density",0.01,1)\
		 #.set_trans(Tween.TRANS_SINE)\
		 #.set_ease(Tween.EASE_IN_OUT)
	#environment.environment.fog_light_color = Color("8e8e80")

func lights_off():
	lights.visible = false
	bulb_mat.emission_energy_multiplier=0.0
func lights_on():
	lights.visible = true
	bulb_mat.emission_energy_multiplier=1

func _on_pickup_zone_body_entered(_body: Node3D) -> void:
	if player_hyperopia:
		show_icons_in_boxes(true)
		Global.audio_manager.pop.play()
func _on_pickup_zone_body_exited(_body: Node3D) -> void:
	if player_hyperopia:
		Global.audio_manager.pop.play()
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
	Global.audio_manager.teleport.play()
	if back_to_init:
		box.global_position = teleported_box_init_pos
		teleported_box_init_pos=Vector3.ZERO
		return
	var to_loc = random_locations.pick_random().global_position
	box.global_position = to_loc

func start_red_light():
	Global.audio_manager.green_light.play()
	lights_anim_player.play("lights_flicker")
	await lights_anim_player.animation_finished
	
	Global.audio_manager.green_light.stop()
	Global.audio_manager.bulb_break.play()
	
	Global.player.red_light_active=true
	Global.player.can_move=true#as lights off when anim finishes
	
	while Global.player.red_light_active:
		await get_tree().create_timer(randf_range(0.4,1)).timeout
		if !Global.player.red_light_active:break
		
		Global.audio_manager.green_light.play()
		lights_anim_player.play("lights_flicker")
		await lights_anim_player.animation_finished
		Global.audio_manager.green_light.stop()
		if !Global.player.red_light_active:break

		lights_on()
		Global.player.can_move=false
		await get_tree().create_timer(randf_range(1,1.5)).timeout
		if !Global.player.red_light_active:break
		Global.audio_manager.green_light.play()
		lights_anim_player.play("lights_flicker")
		await lights_anim_player.animation_finished
		Global.audio_manager.green_light.stop()
		Global.audio_manager.bulb_break.play()
		if !Global.player.red_light_active:break
		Global.player.can_move=true
	
	lights_anim_player.play("RESET")
	lights_on()
		
func stop_red_light():
	Global.player.red_light_active=false
	Global.player.can_move=true
	Global.audio_manager.green_light.stop()
	lights_on()
	lights_anim_player.play("RESET")

#WATCHER
func spawn_watcher():
	if watcher:return#only 1 watcher
	Global.audio_manager.entity_appear.play()
	Global.audio_manager.play_current_main_theme("watcher")
	
	#var tween = get_tree().create_tween()
	#tween.tween_property(environment.environment,"fog_density",0.1,1)\
		 #.set_trans(Tween.TRANS_SINE)\
		 #.set_ease(Tween.EASE_IN_OUT)
	#tween.parallel().tween_property(environment.environment,"fog_light_color",Color("580000ff"),1)
	
	watcher = WATCHER_SCENE.instantiate()
	add_child(watcher)
	watcher.global_position = watcher_pos
	
	watcher_visibility_box = watcher.get_node("VisibleOnScreenNotifier3D")
	watcher_timer = watcher.get_node("Timer")
	watcher_visibility_box.screen_entered.connect(seeing_watcher)
	watcher_visibility_box.screen_exited.connect(not_seeing_watcher)
	watcher_timer.timeout.connect(is_player_seeing_watcher)
	
	times_to_see_watcher = randi_range(10,15)
	print(times_to_see_watcher)
	
func despawn_watcher():
	#reset_fog()
	Global.audio_manager.entity_appear.play()
	Global.audio_manager.watcher.stop()
	if not watcher:return
	watcher.queue_free()
	watcher_visibility_box = null
	watcher_in_view=false
	watcher_timer=null
	saw_watcher=false
	times_to_see_watcher=5#garbage!=1
	Global.audio_manager.play_current_main_theme("normal")

func seeing_watcher():
	if not saw_watcher:saw_watcher=true
	watcher_in_view=true
func not_seeing_watcher():
	watcher_in_view=false

func is_player_seeing_watcher():
	if not saw_watcher:return
	if !watcher_in_view:
		Global.player.emit_signal("game_over","Did not see watcher teleport","make sure you have an eye on the watcher just as it teleports")
	times_to_see_watcher-=1
	if times_to_see_watcher==0:despawn_watcher()
	Global.audio_manager.teleport.play()
	watcher.global_position = random_locations.pick_random().global_position
	
func spawn_eye():
	if the_eye:return#only 1 eye
	the_eye = THE_EYE.instantiate()
	add_child(the_eye)
	the_eye.global_position = the_eye_pos
	
func despawn_eye():
	if not the_eye_pos:return
	the_eye.queue_free()

func is_eye_watching():
	if not the_eye:return false
	return the_eye.get_node("is_watching").visible
	
#Boss
func show_boss():
	boss_anim_player.play("boss_appear")
	
func hide_boss():
	Global.audio_manager.green_light.play()
	boss_anim_player.play_backwards("boss_appear")
	await boss_anim_player.animation_finished
	Global.audio_manager.green_light.stop()
	Global.game_manager.start_game()

func play_last_transition():
	Global.audio_manager.the_eye.play()
	fwatcher.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(Global.player,"rotation_degrees", Vector3(0,-180,0),3)\
	 .set_trans(Tween.TRANS_SINE)\
	 .set_ease(Tween.EASE_IN_OUT)
	
func player_go_to_tv():#Called from game_manager
	print("go to tv")
	var final_pos = Vector3(0.076,0.222,-5.515)
	var tween = get_tree().create_tween()
	tween.tween_property(Global.player,"global_position", final_pos,2)\
	 .set_trans(Tween.TRANS_SINE)\
	 .set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(Global.player.camera,"rotation", Vector3.ZERO,2)\
	 .set_trans(Tween.TRANS_SINE)\
	 .set_ease(Tween.EASE_IN_OUT)	
	tween.parallel().tween_property(Global.player,"rotation", Vector3.ZERO,2)\
	 .set_trans(Tween.TRANS_SINE)\
	 .set_ease(Tween.EASE_IN_OUT)
