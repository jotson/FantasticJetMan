extends KinematicBody2D

export (int) var speed = 1200
export (int) var jump_speed = -1800
export (int) var gravity = 4000

var velocity = Vector2.ZERO
onready var anim_tree = $AnimationTree
onready var animState = anim_tree.get("parameters/playback")

onready var jump_pad = $"../JumpPad"

# States
onready var is_jumping = false;
onready var is_throwing = false;
onready var bounce_in_queue = false;

# Signals

signal start_throwing;
signal confirm_throw;

func _ready():
	# Start the animation state machine with idle animation
	animState.start('idle');
	# Set up signals from JumpPad
	jump_pad.connect("throw_confirmed", self, "_on_JumpPad_throw_confirmed");

func get_input():
	if !is_throwing:
		move_player();
	# Throw state
		if Input.is_action_just_pressed("throw_state"):
			Engine.time_scale = 0.1
			emit_signal("start_throwing");
			is_throwing = true;

	if is_throwing and Input.is_action_just_pressed("confirm_throw"):
		emit_signal("confirm_throw")

func _physics_process(delta):
	get_input()
	print(velocity.y)
	velocity.y += gravity * delta;
	velocity = move_and_slide(velocity, Vector2.UP);
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_speed;
	if bounce_in_queue:
		velocity.y = jump_speed;
		bounce_in_queue = false;
		
func _process(_delta):
	animate_player();
	debug_exit_game()

func move_player():
	velocity.x = 0
	if Input.is_action_pressed("ui_right"):
		velocity.x += speed
	if Input.is_action_pressed("ui_left"):
		velocity.x -= speed

func animate_player():
	if is_on_floor():
		if velocity.x != 0:
			animState.travel('run');
		else:
			animState.travel('idle');

func _on_JumpPad_throw_confirmed():
	is_throwing = false;

func bounce():
	bounce_in_queue = true;
	

func debug_exit_game():
	if Input.is_action_pressed("quit"):
		get_tree().quit();

