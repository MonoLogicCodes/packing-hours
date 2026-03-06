extends Node

func _ready() -> void:
	Global.anomaly_manager = self
	
func try_anomaly_effect(anom:Global.anomaly_types):#used in world.gd
	match anom:
		Global.anomaly_types.FAST_SPEED:
			Global.player.set_fast_speed()
		Global.anomaly_types.INVERT_GRAVITY:
			Global.player.invert_gravity()
		Global.anomaly_types.FOG:
			Global.world.set_fog()
		Global.anomaly_types.LIGHTS_OFF:
			Global.world.lights_off()
		Global.anomaly_types.HEAVY_TOY:
			Global.player.fall_camera()
			Global.player.set_slow_speed()
		Global.anomaly_types.HYPEROPIA:
			Global.world.player_hyperopia=true
		Global.anomaly_types.ADAMANT_BOX:#handled in box itself
			pass
		Global.anomaly_types.CLUMSY_TOY:#handled in toy itself
			pass
		Global.anomaly_types.RED_LIGHT:
			Global.world.start_red_light()
		Global.anomaly_types.CORRUPTED_TOY:#Logic at box.gd
			pass
		Global.anomaly_types.MIMIC:
			Global.player.start_mimic_toy()
		Global.anomaly_types.WATCHER:
			Global.world.lights_off()
			Global.world.spawn_watcher()
		Global.anomaly_types.THE_EYE:
			Global.audio_manager.play_current_main_theme("the_eye")
			Global.world.lights_off()
			Global.world.spawn_eye()
			
func clear_anomaly_effect(anom:Global.anomaly_types):#used in world.gd
	match anom:
		Global.anomaly_types.FAST_SPEED:
			Global.player.reset_speed()
		Global.anomaly_types.INVERT_GRAVITY:
			Global.player.reset_gravity()
		Global.anomaly_types.FOG:
			Global.world.reset_fog()
		Global.anomaly_types.LIGHTS_OFF:
			Global.world.lights_on()
		Global.anomaly_types.HEAVY_TOY:
			Global.player.reset_camera_y()
			Global.player.reset_speed()
		Global.anomaly_types.HYPEROPIA:
			Global.world.player_hyperopia=false
			Global.world.show_icons_in_boxes(true)
		Global.anomaly_types.ADAMANT_BOX:
			pass#Handled in box
		Global.anomaly_types.CLUMSY_TOY:#handled in toy itself
			pass
		Global.anomaly_types.RED_LIGHT:
			Global.world.stop_red_light()
		Global.anomaly_types.CORRUPTED_TOY:
			Global.world.remove_trash_box()
		Global.anomaly_types.MIMIC:
			Global.player.stop_mimic_toy()
		Global.anomaly_types.WATCHER:#despawn mechanic in world itself
			Global.world.lights_on()
		Global.anomaly_types.THE_EYE:
			Global.audio_manager.play_current_main_theme("normal")
			Global.audio_manager.entity_appear.play()
			Global.world.lights_on()
			Global.world.despawn_eye()

func clear_all_anomalies():#No use yet maybe in the future(boss level?)
	Global.player.reset_speed()
	Global.player.reset_gravity()
	Global.world.reset_fog()
	Global.world.lights_on()
	Global.player.reset_camera_y()
	Global.world.show_icons_in_boxes(true)
	Global.world.stop_red_light()
