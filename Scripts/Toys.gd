extends Area3D

@export var active:bool = true#take cares locally
@export var destination:Global.destinations
@export var anomaly:Global.anomaly_types = Global.anomaly_types.NONE

func pick_up_toy():#Called by player
	if not active:return null
	
	Global.world.try_move_toy()
		
	active = false
	return self

func get_destination():#Called by box
	return destination
	
func deactivate():#Called from box
	active=false
	
func set_data(toy_data:Array):#called by world
	active = toy_data[1]
	destination = toy_data[2]
	anomaly = toy_data[3]
	#print(self.name, " to ",Global.destinations.keys()[destination], " has ", Global.anomaly_types.keys()[anomaly], ";Active:",active)
	#temp
	#var mat = $MeshInstance3D.get_active_material(0).duplicate()
	#mat.albedo_color = Color(randf(),randf(),randf()) 
	#$MeshInstance3D.material_override = mat
	
