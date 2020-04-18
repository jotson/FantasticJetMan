extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(player):
	if player.is_carrying_treasure:
		player.can_exit_level = true;
		print('level end')
#		end_level();
	pass # Replace with function body.


func _on_Area2D_body_exited(player):
	player.can_exit_level = false;
	pass # Replace with function body.
