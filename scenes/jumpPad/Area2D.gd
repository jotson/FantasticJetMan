extends Area2D


func _on_Area2D_body_entered(body):
	if body.has_method('bounce'):
		body.bounce();
	pass # Replace with function body.
