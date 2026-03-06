extends Area3D

signal toy_picked(an:Global.anomaly_types) #used in world.gd

@export var model:String
@export var anomaly:Global.anomaly_types = Global.anomaly_types.NONE
var active:bool = true#take cares locally
#anomaly
var placed_in_box:bool = false
var times_to_fall_n_pick:int=1

func pick_up_toy():#Called by player
	if not active:return null
	
	Global.audio_manager.picked_up_toy(model)
	Global.world.try_move_toy()
	emit_signal("toy_picked",anomaly)
	
	#Only for CLUMSY TOYS
	if anomaly==Global.anomaly_types.CLUMSY_TOY:
		if times_to_fall_n_pick>1:
			times_to_fall_n_pick-=1
			try_dropping()
	#Only for MIMIC
	if anomaly==Global.anomaly_types.MIMIC:
		visible = false
	
	active = false
	return self

func get_model():
	return model

func deactivate():#Called from box
	active=false
	
func set_data(toy_data:Array):#called by world
	model = toy_data[0]
	anomaly = toy_data[1]
	#ONLY FOR CLUMSY TOYS
	if anomaly==Global.anomaly_types.CLUMSY_TOY:
		times_to_fall_n_pick = randi_range(7,10)
		print(times_to_fall_n_pick)
#Anomaly
func try_dropping():
	if placed_in_box:return
	await get_tree().create_timer(0.4).timeout
	if placed_in_box:return
	Global.player.drop_toy()
	active=true
	var tween = get_tree().create_tween()
	tween.tween_property(self,"global_position", Vector3(global_position.x,0,global_position.z),0.1)\
	 .set_trans(Tween.TRANS_SINE)\
	 .set_ease(Tween.EASE_IN_OUT)	
