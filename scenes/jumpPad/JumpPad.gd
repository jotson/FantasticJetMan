extends Node2D

# Bounce Player up!! when player enters Area2D
func _on_Area2D_body_entered(body):
	if body.has_method('bounce'):
		body.queue_bounce_state()
		pass # Replace with function body.
