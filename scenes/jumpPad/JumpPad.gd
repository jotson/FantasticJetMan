extends Node2D

# Bounce Player up!! when player enters Area2D

onready var indicator = $"JumpPadIndicator"
onready var jump_pad = $"JumpPad"
onready var is_aiming = false;
export (int) var placementSpeed = 5;

func _ready():
	jump_pad.hide();

func start_aiming():
	Engine.time_scale = 0.1
	is_aiming = true;
	indicator.show();
	pass
	
func finish_aiming():
	Engine.time_scale = 1
	is_aiming = false;
	indicator.hide();
	jump_pad.position = indicator.position
	jump_pad.show();
	pass

func _physics_process(delta):
	if is_aiming:
		if Input.is_action_pressed("ui_right"):
			indicator.position.x += placementSpeed
		if Input.is_action_pressed("ui_left"):
			indicator.position.x -= placementSpeed
		if Input.is_action_pressed("ui_up"):
			indicator.position.y -= placementSpeed
		if Input.is_action_pressed("ui_down"):
			indicator.position.y += placementSpeed

func _on_Area2D_body_entered(body):
	if body.has_method('bounce'):
		body.queue_bounce_state()
		pass
