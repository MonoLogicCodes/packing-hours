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
			
func clear_anomaly_effect(anom:Global.anomaly_types):#used in world.gd
	match anom:
		Global.anomaly_types.FAST_SPEED:
			Global.player.reset_speed()
		Global.anomaly_types.SLOW_SPEED:
			Global.player.reset_speed()
		Global.anomaly_types.INVERT_GRAVITY:
			Global.player.reset_gravity()

func clear_all_anomalies():
	Global.player.reset_speed()
	Global.player.reset_gravity()
