extends KinematicBody2D

export (int) var speed = 1200
export (int) var jump_speed = -1800
export (int) var gravity = 4000

var velocity = Vector2.ZERO
onready var anim_tree = $AnimationTree
onready var animState = anim_tree.get("parameters/playback")

func _ready():
	animState.start('idle');

func get_input():
	velocity.x = 0
	if Input.is_action_pressed("ui_right"):
		velocity.x += speed
	if Input.is_action_pressed("ui_left"):
		velocity.x -= speed

func _physics_process(delta):
	get_input()
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_speed

func _process(_delta):
	animatePlayer();
	

func animatePlayer():
	if is_on_floor():
		if velocity.x != 0:
			animState.travel('run');
		else:
			animState.travel('idle');