extends Area3D

@export var type:String
@export var destination:String
@export var has_anomaly:bool = false

@export var active:bool = true#take cares locally

func pick_up_toy():#Called by player
	if not active:return null
	active = false
	return self

func get_destination():#Called by box
	return destination
	
func deactivate():#Called from box
	active=false
