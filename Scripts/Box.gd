extends Node

@export var destination:String
var packed = false

func deposit_toy(object:Object):
	if packed:return object
	
	if(object.get_destination() == destination):
		object.reparent(self)
		object.global_position = self.global_position
		object.deactivate()
		packed=true
		
		return null#now picked_toy will be null
	else:#wrong destination(reject back toy)
		return object
