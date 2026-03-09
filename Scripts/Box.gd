extends Area3D

signal toy_placed(an:Global.anomaly_types)#used in world.gd

@onready var toy_location_marker = $toy_location
@onready var anim_player:AnimationPlayer = $AnimationPlayer
@onready var box_model:Node3D = $box
@onready var static_body_3d: StaticBody3D = $StaticBody3D
@onready var box_label: Label3D = $Label3D

var gift_box
var cb_pos:Vector3#for finally moving gift box to there
var model:String
var anomaly:Global.anomaly_types=Global.anomaly_types.NONE
var packed = false
var no_of_clicks_to_place:int=1

func deposit_toy(object:Object):
	if packed:return object
	if object.get_model()!=model:
		if object.get_anomaly() == Global.anomaly_types.MIMIC:
			Global.player.emit_signal("game_over","Mimic toy placed in wrong box","The real toy is the toy you picked")
		if object.get_anomaly() == Global.anomaly_types.HYPEROPIA:
			Global.player.emit_signal("game_over","Hyperopia Toy placed in wrong box","Correct boxes are visible only from toy pickup line")
		return object
		
	#for ADAMANT BOXES & THE_EYE ONLY
	if(no_of_clicks_to_place>1):
		if anomaly == Global.anomaly_types.ADAMANT_BOX:
			if(no_of_clicks_to_place==2):
				Global.world.teleport_box(self,true)
			else:
				Global.world.teleport_box(self)
		if(anomaly == Global.anomaly_types.THE_EYE):
			if Global.world.is_eye_watching():
				Global.player.emit_signal("game_over","The eye caught you placing toy","Place the toy when the eye closes")
				return object
			Global.audio_manager.toy_placed.play()
			anim_player.play("box_shake")
			box_label.text = "Place again"
		no_of_clicks_to_place-=1
		return object

	#for WATCHER ONLY
	if(anomaly == Global.anomaly_types.WATCHER):
		if Global.world.watcher:
			Global.player.emit_signal("game_over","The watcher is here","Can't place toy when the watcher is there")
			
	
	emit_signal("toy_placed",anomaly)
	
	Global.audio_manager.picked_up_toy(model)
	Global.audio_manager.toy_placed.play()
	
	object.visible=true
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
	
func set_data(data):
	model=data[0]
	anomaly=data[1]
	show_toy_icon()
	
	if anomaly==Global.anomaly_types.ADAMANT_BOX or anomaly == Global.anomaly_types.THE_EYE:
		no_of_clicks_to_place=randi_range(4,6)
	elif anomaly == Global.anomaly_types.HEAVY_TOY:
		static_body_3d.set_collision_layer_value(4,false)
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
	Global.audio_manager.box_close.play()
	await anim_player.animation_finished
	
	toy_location_marker.visible = false
	anim_player.play("box_pop")
	Global.audio_manager.gift_wrap.play()
	await anim_player.animation_finished
	
	Global.audio_manager.gift_wrap.stop()
	box_model.visible = false
	gift_box.visible = true
	Global.audio_manager.pop.play()
	await get_tree().create_timer(1).timeout
	
	Global.world.move_packed_box_back(self,cb_pos)

func set_conv_belt_pos(pos:Vector3):
	cb_pos = pos
	
