extends Node
#Handles Waves, Win/Lose

signal game_won#used in this script itself as scene change only
signal game_lose(reason:String)#used in UI as overlay lose screen

@onready var wave_timer = $wave_timer
@onready var toy_spawn_freq = $toy_spawn_freq
@onready var inter_wave_timer = $inter_wave_timer

const WAVES:Dictionary = {#[no_of_toys,duration,anomaly_types]
	1:[4,35,[]],#no of toys MUST BE <= 8
	2:[6,50,[Global.anomaly_types.FOG,Global.anomaly_types.LIGHTS_OFF,Global.anomaly_types.FAST_SPEED,Global.anomaly_types.FAST_SPEED]],
	3:[7,70,[Global.anomaly_types.HYPEROPIA,Global.anomaly_types.HYPEROPIA,Global.anomaly_types.ADAMANT_BOX,Global.anomaly_types.CLUMSY_TOY]],
	4:[7,70,[Global.anomaly_types.HYPEROPIA,Global.anomaly_types.INVERT_GRAVITY,Global.anomaly_types.CORRUPTED_TOY,Global.anomaly_types.CORRUPTED_TOY]],
	5:[7,80,[Global.anomaly_types.INVERT_GRAVITY,Global.anomaly_types.CLUMSY_TOY,Global.anomaly_types.HYPEROPIA,Global.anomaly_types.ADAMANT_BOX,Global.anomaly_types.RED_LIGHT]],
	6:[7,105,[Global.anomaly_types.ADAMANT_BOX,Global.anomaly_types.CLUMSY_TOY,Global.anomaly_types.INVERT_GRAVITY,Global.anomaly_types.MIMIC,Global.anomaly_types.RED_LIGHT]],
	7:[8,100,[Global.anomaly_types.MIMIC,Global.anomaly_types.ADAMANT_BOX,Global.anomaly_types.HEAVY_TOY,Global.anomaly_types.RED_LIGHT,Global.anomaly_types.RED_LIGHT]],
	8:[8,100,[Global.anomaly_types.MIMIC,Global.anomaly_types.HEAVY_TOY,Global.anomaly_types.INVERT_GRAVITY,Global.anomaly_types.RED_LIGHT,Global.anomaly_types.THE_EYE]],
	9:[8,100,[Global.anomaly_types.THE_EYE,Global.anomaly_types.HEAVY_TOY,Global.anomaly_types.MIMIC,Global.anomaly_types.THE_EYE,Global.anomaly_types.INVERT_GRAVITY]],
	10:[8,110,[Global.anomaly_types.WATCHER,Global.anomaly_types.WATCHER,Global.anomaly_types.THE_EYE,Global.anomaly_types.FAST_SPEED,Global.anomaly_types.MIMIC]],
}
var curr_wave_details:Array=[]

var toys_spawned_this_wave:int=0#Changes from world.gd
var toys_left_to_place:int = 0#Changes from toys.gd

var toys_data:Array#Array of [model,anomaly]
var toy_models_this_wave:Array

func _ready() -> void:
	Global.game_manager = self
	game_won.connect(play_end_narration)
	
	if !Global.first_time:
		start_the_waves()
	else:
		Global.world.lights_off()
		await  get_tree().create_timer(2).timeout
		Global.world.show_boss()
		Global.curr_dailogue_texts = Global.initial_dialogue_text
		Global.curr_dialogue_audios = Global.initial_dialogue_audio
		Global.narration_manager.speak_next_line()

func start_game():#called from world
	Global.world.lights_on()
	
	await get_tree().create_timer(5).timeout
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
		emit_signal("game_lose","Time out","Place the toys before wave timer runs out")
		stop_wave_timers()
		return
	
	Global.world.pack_all_boxes()
	if inter_wave_timer.is_stopped():inter_wave_timer.start()
	stop_wave_timers()

func _on_inter_wave_timer_timeout() -> void:
	if Global.current_wave>=WAVES.size():return
	Global.current_wave+=1
	try_start_wave(Global.current_wave)
	
func _on_toy_spawn_freq_timeout() -> void:
	if toys_spawned_this_wave<curr_wave_details[0]:
		Global.world.try_spawn_toy(toys_data[toys_spawned_this_wave])
		
func stop_wave_timers():
	wave_timer.stop()
	toy_spawn_freq.stop()


func play_end_narration():
	Global.last_time=true
	Global.player.can_pause=false
	
	Global.world.lights_off()
	await  get_tree().create_timer(2).timeout
	
	Global.player.set_process_unhandled_input(false)
	Global.player.set_physics_process(false)
	Global.world.player_go_to_tv()
	Global.world.show_boss()
	
	Global.curr_dailogue_texts=Global.final_dialogue_text
	Global.curr_dialogue_audios=Global.final_dialogue_audio
	Global.narration_manager.curr_line_idx=0
	Global.narration_manager.speak_next_line()
