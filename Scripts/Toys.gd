extends Area3D

signal toy_picked(an:Global.anomaly_types) #used in world.gd

@export var model:String
@export var anomaly:Global.anomaly_types = Global.anomaly_types.NONE
var active:bool = true#take cares locally

func pick_up_toy():#Called by player
	if not active:return null
	
	Global.world.try_move_toy()
	emit_signal("toy_picked",anomaly)
	
	active = false
	return self

func get_model():
	return model

func deactivate():#Called from box
	active=false
	
func set_data(toy_data:Array):#called by world
	model = toy_data[0]
	anomaly = toy_data[1]

	
