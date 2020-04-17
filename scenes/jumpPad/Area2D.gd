extends Area2D


func _on_Area2D_body_entered(body):
	print('Body entered')
	if body.has_method('bounce'):
		print('Body has bounce')
		body.bounce();
	pass # Replace with function body.
