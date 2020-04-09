extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (int) var placementSpeed = 200;

onready var jumpPadSprite = $JumpPad
onready var jumpPadIndicatorSprite = $JumpPadIndicator

# Get player instance
onready var player = $'../Player'

# Signals

signal throw_confirmed;

func _ready():
	# Set up signals from player
	player.connect("start_throwing", self, "_on_Player_start_throwing")
	

func get_input():
	if(player.is_throwing):
		if Input.is_action_pressed("ui_right"):
			position.x += placementSpeed
		if Input.is_action_pressed("ui_left"):
			position.x -= placementSpeed
		if Input.is_action_pressed("confirm_throw"):
			emit_signal("throw_confirmed");
			toggleIndicator()

func _physics_process(delta):
	get_input();


func _on_Player_start_throwing():
	toggleIndicator()

func toggleIndicator():
	if jumpPadIndicatorSprite.is_visible():
		jumpPadIndicatorSprite.hide()
		jumpPadSprite.show()
	else:
		jumpPadIndicatorSprite.show()
		jumpPadSprite.hide()

# Bounce Player up!! when player enters Area2D
func _on_Area2D_body_entered(body):
	if body.has_method('bounce'):
		body.bounce()
		pass # Replace with function body.
