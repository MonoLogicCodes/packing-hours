extends Area3D

signal toy_placed(an:Global.anomaly_types)#used in world.gd

@onready var toy_location_marker = $toy_location
@export var model:String
@export var anomaly:Global.anomaly_types=Global.anomaly_types.NONE
var packed = false

func deposit_toy(object:Object):
	if packed:return object
	
	if(object.get_model()==model):
		emit_signal("toy_placed",anomaly)
		object.reparent(self)
		object.global_position = toy_location_marker.global_position
		object.deactivate()
		packed=true
		
		if Global.game_manager.toys_left_to_place>0:
			Global.game_manager.toys_left_to_place-=1
		Global.game_manager.check_if_all_placed()
		
		return null#now picked_toy will be null
	else:#wrong destination(reject back toy)
		return object
	
func set_data(data):
	model=data[0]
	anomaly=data[2]
	show_toy_icon()
	
func show_toy_icon():
	var tex = Global.toy_icons[model]
	$icon1.texture = tex
	$icon2.texture = tex
	$icon3.texture = tex
	$icon4.texture = tex
	
	
	
