extends KinematicBody2D


export (int) var jump_speed = -1800
export (int) var gravity = 4000
export (int) var max_ground_speed = 800;
export (int) var ground_acceleration = 100;
export (int) var ground_deceleration = 50;
export (int) var max_air_speed = 120;
export (int) var air_acceleration = 15;

var velocity = Vector2.ZERO
# animation
onready var anim = get_node("AnimationPlayer")
onready var playerSprite = get_node("Sprite");
# animation state
onready var current_anim;
onready var next_anim;

# States
onready var STATES = ['jump', 'airborne', 'throwing', 'idle', 'running', 'bounce'];

onready var next_state = 'idle';
onready var current_state = 'idle'; # just to set it to something;
onready var previous_state;
onready var is_jumping = false;
onready var is_throwing = false;
onready var bounce_in_queue = false;

# Signals

signal start_throwing;
signal confirm_throw;

### JUMP PAD

export (int) var placementSpeed = 5;
onready var jump_pad_scene = $"../JumpPadScene"
onready var jump_pad = jump_pad_scene.get_node("JumpPad")
onready var jump_pad_indicator = jump_pad_scene.get_node("JumpPadIndicator")

func move_jump_pad():
	if jump_pad_indicator:
		if Input.is_action_pressed("ui_right"):
			jump_pad_indicator.position.x += placementSpeed
		if Input.is_action_pressed("ui_left"):
			jump_pad_indicator.position.x -= placementSpeed
		if Input.is_action_pressed("ui_up"):
			jump_pad_indicator.position.y -= placementSpeed
		if Input.is_action_pressed("ui_down"):
			jump_pad_indicator.position.y += placementSpeed

func show_indicator():
	jump_pad_indicator.show()
	jump_pad.hide()

func swap_indicator_for_pad():
	if jump_pad_indicator.is_visible():
		jump_pad_indicator.hide()
		jump_pad.position = jump_pad_indicator.position
		jump_pad.show()
### 


func get_input():
	# Throw state
	if Input.is_action_just_pressed("throw_state"):
		next_state = 'throwing'
		is_throwing = true;

	if is_throwing and Input.is_action_just_pressed("confirm_throw"):
		emit_signal("confirm_throw")

func _physics_process(delta):
	# move
	velocity.x = lerp( velocity.x, 0, ground_deceleration * delta )
	velocity.y += gravity * delta;
	velocity = move_and_slide(velocity, Vector2.UP);
	# animate
	if current_anim != next_anim:
		current_anim = next_anim
		anim.play( current_anim )
			
	match next_state:
		'airborne':
			start_airborne_state(delta);
		'jump':
			start_jump_state(delta);
		'throwing':
			start_throwing_state(delta);
		'idle':
			start_idle_state(delta);
		'running':
			start_running_state(delta);
		'bounce':
			start_bounce_state(delta);
		'game_over':
			start_game_over_state(delta);


func queue_bounce_state():
	if next_state != 'bounce' and current_state != 'bounce':
		next_state = 'bounce';

func start_bounce_state(delta):
	current_state = 'bounce'
	velocity.y = jump_speed;
	next_state = 'airborne';
	

func start_idle_state(_delta):
	next_anim = 'idle';
	current_state = 'idle';
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left"):
		next_state = 'running'
	if Input.is_action_just_pressed("jump"):
		next_state = 'jump'
	if Input.is_action_just_pressed("throw_state"):
		next_state = 'throwing'
	pass

func start_running_state(delta):
	next_anim = 'running';
	current_state = 'running';
	if !is_on_floor():
		next_state = 'airborne';
		return;
	if Input.is_action_pressed("ui_right"):
		playerSprite.flip_h = false;
		velocity.x = lerp( velocity.x, max_ground_speed, ground_acceleration * delta )
	if Input.is_action_pressed("ui_left"):
		playerSprite.flip_h = true;
		velocity.x = lerp( velocity.x, -max_ground_speed, ground_acceleration * delta )
	if Input.is_action_just_pressed("jump"):
		next_state = 'jump'
	if Input.is_action_just_pressed("throw_state"):
			next_state = 'throwing'
	if velocity.x == 0:
		next_state = 'idle';	
		
	pass
func start_airborne_state(delta):
	next_anim = 'airborne'
	current_state = 'airborne'
	if Input.is_action_pressed("ui_right"):
		velocity.x = lerp( velocity.x, max_ground_speed, ground_acceleration * delta )
	if Input.is_action_pressed("ui_left"):
		velocity.x = lerp( velocity.x, -max_ground_speed, ground_acceleration * delta )
	if Input.is_action_just_pressed("throw_state"):
		next_state = 'throwing'
	if is_on_floor():
		next_state = 'idle';

func start_throwing_state(_delta):
	# store previous state to know what we have to go back to doing
	if current_state != 'throwing':
		previous_state = current_state;
	current_state = 'throwing'
	show_indicator()
	move_jump_pad();
	if is_on_floor():
		next_anim = 'idle';
	if Input.is_action_just_pressed("throw_state"):
		swap_indicator_for_pad();
		next_state = previous_state;
	if Input.is_action_just_pressed("confirm_throw"):
		swap_indicator_for_pad();
		next_state = previous_state;
	pass
	
func start_jump_state(delta):
	current_state = 'jump';
	if is_on_floor():
		velocity.y = jump_speed;
		next_state = 'airborne';
	pass

func start_game_over_state(delta):
	current_state = 'game_over'
	print('I died! I am in game over state!')

func _process(_delta):
	debug_exit_game()

func debug_exit_game():
	if Input.is_action_pressed("quit"):
		get_tree().quit();

func get_hurt():
	next_state = 'game_over';
