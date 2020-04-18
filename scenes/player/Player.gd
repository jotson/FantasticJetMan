extends KinematicBody2D


onready var jump_speed = 300
onready var bounce_modifier = 1.5;
onready var gravity = 1000;
onready var fall_gravity = 2000;
onready var max_ground_speed = 400;
onready var ground_acceleration = 50;
onready var ground_deceleration = 25;
onready var air_acceleration = 40;
onready var air_resistance = 25;
onready var wall_bounce_speed = 30;


# collisions
onready var collideRight = get_node("CollideRight")
onready var collideLeft = get_node("CollideLeft")
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
# Possible states are 
# 'jump', 'airborne', 'idle', 'running', 'bounce'
onready var next_state = 'idle';
onready var current_state = 'idle'; # just to set it to something;
onready var previous_state;

# More states
# These are some extra special "meta" states that can overlap with the other states
#  'not_shooting', 'start_shooting', 'is_shooting', 'stopped_shooting'
onready var shooting_state = 'not_shooting'
onready var is_carrying_treasure = false;
onready var was_shooting = false #need to keep track of this to only call some functions once

# Exit level

onready var can_exit_level = false;

### The Gun

onready var gun = $"TheGun";

### Jump Pad
onready var jump_pad_scene = $"../JumpPadScene"
onready var jump_pad_default_position = $"JumpPadDefaultPosition"

func _ready():
	gun.hide()

func _physics_process(delta):
	# Check for level exit
	check_for_exit_level();
	# Throw treasure ... or don't
	throw_treasure(delta)
	# Slow down when running!
	if current_state != 'airborne':
		velocity.x = lerp( velocity.x, 0, ground_deceleration * delta )
	# Apply gravity
	if velocity.y < 0:
		# if still going up, apply more gentle gravity
		velocity.y = velocity.y + gravity * delta
	else:
		velocity.y = velocity.y + fall_gravity * delta
	
	velocity = move_and_slide(velocity, Vector2.UP);
	# Queue animations
	if current_anim != next_anim:
		current_anim = next_anim
		anim.play( current_anim )
	if shooting_state == 'not_shooting':
		if Input.is_action_just_pressed("shooting_state"):
			shooting_state = 'start_shooting'
	if shooting_state == 'start_shooting' or shooting_state == 'is_shooting':
		start_shooting_state(delta)
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
	velocity.y = -jump_speed * bounce_modifier;
	if Input.is_action_pressed("ui_right") and velocity.x < 0:
		print('reverse_direction')
		velocity.x = -velocity.x;
		velocity = move_and_slide(velocity, Vector2.UP);
	if Input.is_action_pressed("ui_left") and velocity.x > 0:
		print('reverse_direction')
		velocity.x = -velocity.x;
		velocity = move_and_slide(velocity, Vector2.UP);
	next_state = 'airborne';
	

func start_idle_state(_delta):
	next_anim = 'idle';
	current_state = 'idle';
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left"):
		next_state = 'running'
	if Input.is_action_just_pressed("jump"):
		next_state = 'jump'
	pass

func start_running_state(delta):
	next_anim = 'running';
	current_state = 'running';
	if !is_on_floor():
		next_state = 'airborne';
		return;
	# Only move when not shooting
	if shooting_state == 'not_shooting':
		if Input.is_action_pressed("ui_right"):
			playerSprite.flip_h = false;
			velocity.x = lerp( velocity.x, max_ground_speed, ground_acceleration * delta )
		if Input.is_action_pressed("ui_left"):
			playerSprite.flip_h = true;
			velocity.x = lerp( velocity.x, -max_ground_speed, ground_acceleration * delta )
		if Input.is_action_just_pressed("jump"):
			next_state = 'jump'
	if abs(velocity.x) < 20:
		next_state = 'idle';
	pass

func start_airborne_state(delta):
	next_anim = 'airborne'
	current_state = 'airborne'
	if velocity.x > 0:
		velocity.x = lerp( velocity.x, max_ground_speed, air_acceleration * delta )
	elif velocity.x < 0:
		velocity.x = lerp( velocity.x, -max_ground_speed, air_acceleration * delta )

	check_switch_direction(delta);
	# Apply air resistance
	velocity.x = lerp( velocity.x, 0, air_resistance * delta )
	if is_on_floor():
		next_state = 'idle';

func start_shooting_state(delta):
	# The following should be called once, when shooting btn is pressed
	if shooting_state == 'start_shooting':
		gun.show()
		jump_pad_scene.start_aiming(jump_pad_default_position.global_position);
		shooting_state = 'is_shooting'
		return

	if shooting_state == 'is_shooting':
		# This should only be called when we have been shooting and want to stop shooting
		if Input.is_action_just_pressed("shooting_state") or Input.is_action_just_pressed("shoot"):
			gun.hide()
			jump_pad_scene.finish_aiming();
			shooting_state = 'not_shooting'
	pass
	
func start_jump_state(delta):
	current_state = 'jump';
	if is_on_floor():
		print("Jumped")
		velocity.y = -jump_speed;
		next_state = 'airborne';
	pass

func start_game_over_state(delta):
	Engine.time_scale = 1
	current_state = 'game_over'
	next_anim = 'death'

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
		
func check_switch_direction(delta):
	if collideLeft.is_colliding():
		velocity.x = lerp( velocity.x, max_ground_speed, wall_bounce_speed * delta )
	elif collideRight.is_colliding():
		velocity.x = lerp( velocity.x, -max_ground_speed, wall_bounce_speed * delta )

func check_for_exit_level():
	if Input.is_action_pressed("ui_up") and can_exit_level:
		Game.load_next_level()

func show_game_over_screen():
	Game.show_game_over_scene()
