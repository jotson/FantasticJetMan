extends StaticBody2D

onready var anim = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play('idle')
	pass # Replace with function body.

