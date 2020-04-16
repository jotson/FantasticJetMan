extends KinematicBody2D


export (int) var jump_speed = -400
export (int) var gravity = 1600
export (int) var max_ground_speed = 800;
export (int) var ground_acceleration = 100;
export (int) var ground_deceleration = 50;
export (int) var air_deceleration = 200;

var velocity = Vector2.ZERO
# animation
onready var anim = get_node("AnimationPlayer")
onready var playerSprite = get_node("Sprite");
# animation state
onready var current_anim;
onready var next_anim;

# Treasure Assets
onready var treasureSprite = get_node("Treasure")
onready var treasureScene = preload("res://scenes/player/Treasure.tscn");

# States
onready var STATES = ['jump', 'airborne', 'shooting', 'idle', 'running', 'bounce'];
onready var next_state = 'idle';
onready var current_state = 'idle'; # just to set it to something;
onready var previous_state;
onready var is_carrying_treasure = false;

### The Gun

onready var gun = $"TheGun";

### Jump Pad
onready var jump_pad_scene = $"../JumpPadScene"

func _ready():
	gun.hide()

func _physics_process(delta):
	throw_treasure(delta)
	# Move horizontally
	velocity.x = lerp( velocity.x, 0, ground_deceleration * delta )
	# Apply gravity
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
		'shooting':
			start_shooting_state(delta);
		'idle':
			start_idle_state(delta);
		'running':
			start_running_state(delta);
		'bounce':
			start_bounce_state(delta);
		'game_over':
			start_game_over_state(delta);


func bounce():
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
	if Input.is_action_just_pressed("shooting_state"):
		next_state = 'shooting'
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
	if Input.is_action_just_pressed("shooting_state"):
		next_state = 'shooting'
	if abs(velocity.x) < 20:
		next_state = 'idle';	
		
	pass
func start_airborne_state(delta):
	next_anim = 'airborne'
	current_state = 'airborne'
	if velocity.x > 0:
		velocity.x = lerp( velocity.x, max_ground_speed, ground_acceleration * delta )
	else:
		velocity.x = lerp( velocity.x, -max_ground_speed, ground_acceleration * delta )

	if Input.is_action_pressed("ui_right"):
		print('entered')
		print('vel x ', velocity.x)
		velocity.x += air_deceleration
	if Input.is_action_pressed("ui_left"):
		velocity.x -= air_deceleration
	if Input.is_action_just_pressed("shooting_state"):
		next_state = 'shooting'
	if is_on_floor():
		next_state = 'idle';

func start_shooting_state(_delta):
	gun.show()
	# store previous state to know what we have to go back to doing
	if current_state != 'shooting':
		previous_state = current_state;
	current_state = 'shooting'
	jump_pad_scene.start_aiming();
	
	if is_on_floor():
		next_anim = 'idle';
	if Input.is_action_just_pressed("shooting_state"):
		gun.hide()
		jump_pad_scene.finish_aiming();
		next_state = previous_state;
	if Input.is_action_just_pressed("shoot"):
		gun.hide();
		jump_pad_scene.finish_aiming();
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
	next_anim = 'death'
	print('I died! I am in game over state!')

func _process(_delta):
	debug_exit_game()

func debug_exit_game():
	if Input.is_action_pressed("quit"):
		get_tree().quit();

func get_hurt():
	next_state = 'game_over';

func pick_up_treasure():
	treasureSprite.show()
	is_carrying_treasure = true;
	pass

func throw_treasure(delta):
	if Input.is_action_just_pressed("throw_treasure") and is_carrying_treasure:
		var treasureInstance = treasureScene.instance()
		treasureInstance.position = treasureSprite.position
		add_child(treasureInstance)
		var direction = 1;
		if playerSprite.flip_h:
			direction = -1;
		treasureInstance.throw(direction);
		treasureSprite.hide()
		is_carrying_treasure = false;
