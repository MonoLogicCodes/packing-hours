extends Area3D

@export var destination:Global.destinations
@export var anomaly:Global.anomaly_types=Global.anomaly_types.NONE
var packed = false

func deposit_toy(object:Object):
	if packed:return object
	
	if(object.get_destination() == destination):
		object.reparent(self)
		object.global_position = self.global_position
		object.deactivate()
		packed=true
		
		if Global.game_manager.toys_left_to_place>0:
			Global.game_manager.toys_left_to_place-=1
		Global.game_manager.check_if_all_placed()
		
		return null#now picked_toy will be null
	else:#wrong destination(reject back toy)
		return object
	
func set_data(data):
	destination=data[2]
	anomaly=data[3]
	#print(self.name, " to ",Global.destinations.keys()[destination], " has ", Global.anomaly_types.keys()[anomaly])
