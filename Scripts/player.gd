extends CharacterBody3D

@onready var ray_cast = $Head/Camera3D/RayCast3D
@onready var camera = $Head/Camera3D
@onready var hand = $Hand

const SENSITIVITY: float = 0.004
const SPRINT_SPEED: float = 8.0
const WALK_SPEED: float = 5.0
var speed:float = WALK_SPEED;
var gravity:float = -16
var mouse_captured:bool = true

var picked_toy:Object = null

func _ready() -> void:
	mouse_capture(true)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("escape"):
		mouse_capture(!mouse_captured)
	if Input.is_action_just_pressed("right_click"):
		check_raycast_collider("right_click")
		
	if mouse_captured and event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x,deg_to_rad(-70),deg_to_rad(60))
	
func _physics_process(delta: float) -> void:
	if(mouse_captured):
		_handle_movement(delta)
	
func _handle_movement(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity*delta
		
	var input_dir = Input.get_vector("left","right","forward","backward")
	var move_dir  = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	
	if is_on_floor():
		if move_dir:
			velocity.x = move_dir.x * speed
			velocity.z = move_dir.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed) 
		
	move_and_slide()
	
func mouse_capture(val: bool):
	mouse_captured = val
	if val:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

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
				
		
		
