extends Node2D


func _on_Area2D_body_entered(body):
	if body.has_method('get_hurt'):
		body.get_hurt();
	pass # Replace with function body.
