extends Node
#Handles Waves, Win/Lose

@onready var wave_timer = $wave_timer
@onready var toy_spawn_freq = $toy_spawn_freq
@onready var inter_wave_timer = $inter_wave_timer

const WAVES:Dictionary = {#[no_of_toys,anomaly_types]
	1:[4,[]],
	2:[7,[Global.anomaly_types.FAST_SPEED,Global.anomaly_types.COLOR_INVERSION]],
}
var curr_wave_details:Array=[]
var current_wave:int=0

var toys_spawned_this_wave:int=0#Changes from world.gd
var toys_left_to_place:int = 0#Changes from toys.gd

var toys_data:Array#Array of [model,active,destination,anomaly]
var toy_models_this_wave:Array

func _ready() -> void:
	Global.game_manager = self
	
	current_wave=1
	try_start_wave(current_wave)

func start_waves_timer():
	if wave_timer.is_stopped():wave_timer.start()

func start_toy_spawn_freq_timer():
	if toy_spawn_freq.is_stopped():toy_spawn_freq.start()

func try_start_wave(wave_no:int):
	if toys_left_to_place!=0:
		stop_all_timers()
		current_wave-=1#TO start back from the wave in which u lose
		print("You Lose!")
		return#u lose: did not pick up all by time
	
	if current_wave > WAVES.size():
		stop_all_timers()
		print("You Won!")
		return
	
	print("New wave")
	
	Global.world.kill_all_toys_and_boxes()
	await get_tree().create_timer(0.5).timeout
	
	curr_wave_details = WAVES[wave_no]
	toys_left_to_place = curr_wave_details[0]
	toys_spawned_this_wave=0
	toys_data = []
	toy_models_this_wave=[]
	
	randomize_toy_data()
	start_waves_timer()
	start_toy_spawn_freq_timer()
	
	Global.world.spawn_boxes(toys_data)
	
func randomize_toy_data():#Toy model,Toy active,Toy destination,Toy anomaly
	toy_models_this_wave = Global.toy_models.keys().duplicate()
	toy_models_this_wave.shuffle()
	toy_models_this_wave = toy_models_this_wave.slice(0,curr_wave_details[0])
	
	var destins = Global.destinations.values()
	var anoms = curr_wave_details[1].duplicate()
	for j in range(anoms.size(),curr_wave_details[0]):
		anoms.append(Global.anomaly_types.NONE)
	for i in curr_wave_details[0]:
		toys_data.append([toy_models_this_wave[i],true,destins.pick_random(),anoms[i]])
	
	toys_data.shuffle()

func check_if_all_placed():#Called by box.gd : Everytime u deposit toy
	if toys_left_to_place==0:#check later
		print("ALL TOYS PLACED THIS WAVE")

func _on_wave_timer_timeout() -> void:
	if inter_wave_timer.is_stopped():inter_wave_timer.start()
	print("Wave DONE! Waiting for 3 seconds")
	stop_all_timers()

func _on_inter_wave_timer_timeout() -> void:
	current_wave+=1
	try_start_wave(current_wave)
	
func _on_toy_spawn_freq_timeout() -> void:
	if toys_spawned_this_wave<curr_wave_details[0]:
		Global.world.try_spawn_toy(toys_data[toys_spawned_this_wave])
	$"../../UI/time_left".text = str(round(wave_timer.time_left))#Temp
		
func stop_all_timers():
	wave_timer.stop()
	toy_spawn_freq.stop()
