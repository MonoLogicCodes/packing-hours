extends Area3D

signal toy_placed(an:Global.anomaly_types)#used in world.gd

@onready var toy_location_marker = $toy_location
@onready var anim_player:AnimationPlayer = $AnimationPlayer
@onready var box_model:Node3D = $box

var gift_box
var cb_pos:Vector3#for finally moving gift box to there
var model:String
var anomaly:Global.anomaly_types=Global.anomaly_types.NONE
var packed = false
var no_of_clicks_to_place:int=1

func deposit_toy(object:Object):
	if packed:return object
	
	#for ADAMANT BOXES ONLY
	if(no_of_clicks_to_place>1):
		if(no_of_clicks_to_place==2):
			Global.world.teleport_box(self,true)
		else:
			Global.world.teleport_box(self)
		no_of_clicks_to_place-=1
		return object
	
	if(object.get_model()==model):
		emit_signal("toy_placed",anomaly)
		object.placed_in_box=true
		object.reparent(toy_location_marker)#so that we can toggle visibility
		object.global_position = toy_location_marker.global_position
		object.global_rotation = global_rotation
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
	anomaly=data[1]
	show_toy_icon()
	if anomaly==Global.anomaly_types.ADAMANT_BOX:
		no_of_clicks_to_place=randi_range(3,7)
	
	gift_box = Global.box_models.values().pick_random().instantiate()
	gift_box.visible = false
	add_child(gift_box)

func show_toy_icon():
	var tex = Global.toy_icons[model]
	$box/icon1.texture = tex
	$box/icon2.texture = tex
	$box/icon3.texture = tex
	$box/icon4.texture = tex
	
func show_icon(val:bool):#Called from world
	$box/icon1.visible = val
	$box/icon2.visible = val
	$box/icon3.visible = val
	$box/icon4.visible = val
	
func close_box():
	anim_player.play("flaps_close")
	await anim_player.animation_finished
	toy_location_marker.visible = false
	anim_player.play("box_pop")
	await anim_player.animation_finished
	box_model.visible = false
	gift_box.visible = true
	await get_tree().create_timer(1).timeout
	Global.world.move_packed_box_back(self,cb_pos)

func set_conv_belt_pos(pos:Vector3):
	cb_pos = pos
	
