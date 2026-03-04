extends Node

func _ready() -> void:
	Global.anomaly_manager = self
	
func try_anomaly_effect(anom:Global.anomaly_types):#used in world.gd
	match anom:
		Global.anomaly_types.FAST_SPEED:
			Global.player.set_fast_speed()
		Global.anomaly_types.SLOW_SPEED:
			Global.player.set_slow_speed()
		Global.anomaly_types.INVERT_GRAVITY:
			Global.player.invert_gravity()
		Global.anomaly_types.FOG:
			Global.world.set_fog()
		Global.anomaly_types.LIGHTS_OFF:
			Global.world.lights_off()
		Global.anomaly_types.HEAVY_TOY:
			Global.player.fall_camera()
		Global.anomaly_types.HYPEROPIA:
			Global.world.player_hyperopia=true
			
func clear_anomaly_effect(anom:Global.anomaly_types):#used in world.gd
	match anom:
		Global.anomaly_types.FAST_SPEED:
			Global.player.reset_speed()
		Global.anomaly_types.SLOW_SPEED:
			Global.player.reset_speed()
		Global.anomaly_types.INVERT_GRAVITY:
			Global.player.reset_gravity()
		Global.anomaly_types.FOG:
			Global.world.reset_fog()
		Global.anomaly_types.LIGHTS_OFF:
			Global.world.lights_on()
		Global.anomaly_types.HEAVY_TOY:
			Global.player.reset_camera_y()
		Global.anomaly_types.HYPEROPIA:
			Global.world.player_hyperopia=false
			Global.world.show_icons_in_boxes(true)

func clear_all_anomalies():
	Global.player.reset_speed()
	Global.player.reset_gravity()
	Global.world.reset_fog()
	Global.world.lights_on()
	Global.player.reset_camera_y()
