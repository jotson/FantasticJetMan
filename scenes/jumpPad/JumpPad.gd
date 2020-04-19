extends Node2D

# Bounce Player up!! when player enters Area2D

onready var indicator;
onready var jump_pad = preload("res://scenes/jumpPad/IndividualJumpPad.tscn");
onready var is_aiming = false;
onready var list_of_jump_pads = [];
onready var max_number_of_jump_pads = 2;
export (int) var placement_speed = 5;

func _ready():
	indicator = $"TargetIndicator";

func start_aiming(position):
	print('called start aiming')
	Engine.time_scale = 0.1
	is_aiming = true;
	indicator.global_position = position
	indicator.show();
	pass
	
func finish_aiming():
	Engine.time_scale = 1
	is_aiming = false;
	indicator.hide();
	var jump_pad_instance = instantiate(jump_pad);
	jump_pad_instance.position = indicator.position
	list_of_jump_pads.append(jump_pad_instance)
	if list_of_jump_pads.size() > max_number_of_jump_pads:
		var first_jump_pad = list_of_jump_pads.pop_front();
		first_jump_pad.queue_free()
	pass

func _physics_process(delta):
	if is_aiming:
		if Input.is_action_pressed("ui_right"):
			indicator.position.x += placement_speed
		if Input.is_action_pressed("ui_left"):
			indicator.position.x -= placement_speed
		if Input.is_action_pressed("ui_up"):
			indicator.position.y -= placement_speed
		if Input.is_action_pressed("ui_down"):
			indicator.position.y += placement_speed

#func _on_Area2D_body_entered(body):
#	if body.has_method('bounce'):
#		body.queue_bounce_state()
#		pass

func instantiate(preloadedScene):
	var preloadedSceneInstance = preloadedScene.instance()
	add_child(preloadedSceneInstance)
	return preloadedSceneInstance
