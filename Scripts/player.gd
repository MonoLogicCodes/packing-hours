extends CharacterBody3D

signal pause
signal game_over#also emited from box

@onready var ray_cast = $Head/Camera3D/RayCast3D
@onready var camera = $Head/Camera3D
@onready var hand = $Head/Camera3D/Hand
@onready var head = $Head

const SENSITIVITY: float = 0.004
const WALK_SPEED: float = 5.0
const GRAVITY:float = -16#-ve imp here
const BOB_FREQ = 5.0
const BOB_AMP = 0.01

var bob_time := 0.0
#ANOMALY DATAS
const FAST_SPEED:float = 15
const SLOW_SPEED:float = 2
const NORMAL_FOV:float = 75
const FAST_FOV:float = 110
const SLOW_FOV:float = 40
const MAX_CAM_FALL:float = -1.3

var speed:float = WALK_SPEED;
var curr_fov:float = NORMAL_FOV
var gravity:float = GRAVITY
var cam_fall:bool = false
var red_light_active:bool = false#used in world
var can_move:bool = true
var picked_toy:Object = null

var is_mimic_toy:bool = false
var mimic_toy:Area3D

func _ready() -> void:
	speed=WALK_SPEED
	Global.player = self

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("escape"):
		emit_signal("pause",true)
	if Input.is_action_just_pressed("right_click"):
		check_raycast_collider("right_click")
		
	if event is InputEventMouseMotion:#mouse_cap is removed as this will run only if paused=false
		rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x,deg_to_rad(-70),deg_to_rad(60))
	
func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	
func _handle_movement(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity*delta
	if gravity>0:
		velocity.y = -GRAVITY
	
	var input_dir = Input.get_vector("left","right","forward","backward")
	var move_dir  = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if move_dir:
		bob_time += delta * speed
		var y = sin(bob_time * BOB_FREQ) * BOB_AMP
		var x = cos(bob_time * BOB_FREQ * 0.5) * BOB_AMP
		head.position += Vector3(x, y, 0)
		
		if red_light_active and not can_move:emit_signal("game_over")
		if camera.fov!=curr_fov and not cam_fall:camera.fov=move_toward(camera.fov,curr_fov,speed)
		velocity.x = move_dir.x * speed
		velocity.z = move_dir.z * speed
	else:
		
		if curr_fov!=NORMAL_FOV and not cam_fall:camera.fov = move_toward(camera.fov,NORMAL_FOV,speed)
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed) 
		
	move_and_slide()
	if cam_fall:
		camera.position.y -= delta/4
		camera.fov = move_toward(camera.fov,SLOW_FOV,delta*10)
		if camera.position.y < MAX_CAM_FALL:
			cam_fall=false
			emit_signal("game_over")

	
func check_raycast_collider(event: String) -> void:
	if ray_cast.is_colliding():
		var obj = ray_cast.get_collider() as Object
		
		if event == "right_click":
			
			if obj.has_method("pick_up_toy") and not picked_toy:
				picked_toy = obj.pick_up_toy()#if active toy,return it
				if picked_toy:
					picked_toy.reparent(hand)
					picked_toy.global_position = hand.global_position
				
			if obj.has_method("deposit_toy"):#Box
				if picked_toy:
					picked_toy = obj.deposit_toy(picked_toy)

func drop_toy():
	picked_toy.reparent(Global.world)
	picked_toy.global_rotation = Vector3.ZERO
	picked_toy=null
	
#ANOMALY_FUNCTIONS
func set_fast_speed():
	speed=FAST_SPEED
	curr_fov = FAST_FOV

func set_slow_speed():
	speed=SLOW_SPEED
	curr_fov = SLOW_FOV

func reset_speed():
	speed=WALK_SPEED
	curr_fov = NORMAL_FOV
		
func invert_gravity():
	gravity = -GRAVITY
	camera.rotation_degrees.z=180
	
func reset_gravity():
	gravity = GRAVITY
	camera.rotation_degrees.z=0

func fall_camera():
	cam_fall=true
	
func reset_camera_y():
	cam_fall=false
	camera.position.y=0

func start_mimic_toy():
	is_mimic_toy=true
	while true:
		mimic_toy = Global.toy_models.values().pick_random().instantiate()
		hand.add_child(mimic_toy)
		await get_tree().create_timer(0.4).timeout
		if mimic_toy:mimic_toy.queue_free()
		if !is_mimic_toy:break

func stop_mimic_toy():
	is_mimic_toy=false
	if mimic_toy:mimic_toy.queue_free()
