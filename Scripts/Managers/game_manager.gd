extends Node
#Handles Waves, Win/Lose

signal game_won#used in this script itself as scene change only
signal game_lose(reason:String)#used in UI as overlay lose screen

@onready var wave_timer = $wave_timer
@onready var toy_spawn_freq = $toy_spawn_freq
@onready var inter_wave_timer = $inter_wave_timer

const WAVES:Dictionary = {#[no_of_toys,duration,anomaly_types]
	1:[6,60,[]],#no of toys MUST BE <= 8
	2:[6,60,[Global.anomaly_types.FOG]],
	3:[2,15,[]],
}
var curr_wave_details:Array=[]

var toys_spawned_this_wave:int=0#Changes from world.gd
var toys_left_to_place:int = 0#Changes from toys.gd

var toys_data:Array#Array of [model,anomaly]
var toy_models_this_wave:Array

func _ready() -> void:
	Global.game_manager = self
	game_won.connect(go_to_win_screen)
	
	if !Global.first_time:start_the_waves()
	else:
		Global.world.lights_off()

func start_game():#called from world
	Global.world.lights_on()
	
	await get_tree().create_timer(7).timeout
	start_the_waves()

func start_the_waves():
	try_start_wave(Global.current_wave)

func start_waves_timer():
	if wave_timer.is_stopped():wave_timer.start()

func start_toy_spawn_freq_timer():
	if toy_spawn_freq.is_stopped():toy_spawn_freq.start()

func try_start_wave(wave_no:int):	
	if Global.current_wave > WAVES.size():
		return
	
	Global.world.kill_all_toys_and_boxes()
	await get_tree().create_timer(0.5).timeout
	
	curr_wave_details = WAVES[wave_no]
	toys_left_to_place = curr_wave_details[0]
	wave_timer.wait_time=curr_wave_details[1]
	toys_spawned_this_wave=0
	toys_data = []
	toy_models_this_wave=[]
	
	randomize_toy_data()
	start_waves_timer()
	start_toy_spawn_freq_timer()
	
	Global.world.spawn_boxes(toys_data)
	
func randomize_toy_data():#Toy model,Toy active,Toy anomaly
	toy_models_this_wave = Global.toy_models.keys().duplicate()
	toy_models_this_wave.shuffle()
	toy_models_this_wave = toy_models_this_wave.slice(0,curr_wave_details[0])
	
	var anoms = curr_wave_details[2].duplicate()
	for j in range(anoms.size(),curr_wave_details[0]):
		anoms.append(Global.anomaly_types.NONE)
	for i in curr_wave_details[0]:
		toys_data.append([toy_models_this_wave[i],anoms[i]])
	
	toys_data.shuffle()

func check_if_all_placed():#Called by box.gd : Everytime u deposit toy
	if toys_left_to_place==0:#check later
		Global.world.pack_all_boxes()
		stop_wave_timers()
		if inter_wave_timer.is_stopped():inter_wave_timer.start()
		
		if Global.current_wave==WAVES.size():
			stop_wave_timers()
			emit_signal("game_won")
			return

func _on_wave_timer_timeout() -> void:
	if toys_left_to_place!=0:
		emit_signal("game_lose","Time out")
		stop_wave_timers()
		return
	
	Global.world.pack_all_boxes()
	if inter_wave_timer.is_stopped():inter_wave_timer.start()
	stop_wave_timers()

func _on_inter_wave_timer_timeout() -> void:
	Global.current_wave+=1
	try_start_wave(Global.current_wave)
	
func _on_toy_spawn_freq_timeout() -> void:
	if toys_spawned_this_wave<curr_wave_details[0]:
		Global.world.try_spawn_toy(toys_data[toys_spawned_this_wave])
		
func stop_wave_timers():
	wave_timer.stop()
	toy_spawn_freq.stop()


func go_to_win_screen():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_packed(Global.win_screen)
