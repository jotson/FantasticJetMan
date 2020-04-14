extends RigidBody2D


export (Vector2) var force = Vector2(0, 0);
onready var player;
onready var anim = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play('idle')

func throw(direction, player_speed):
	print('Got a on throw treasure event')
	print(player_speed)
	# The direction depends on the player and is either 1 or -1
	force.x += player_speed
	force.x *= direction
	apply_impulse(Vector2(), force);
	
func bounce():
	print('called bounce')
	apply_impulse(Vector2(), Vector2(0, -180));

func _on_Treasure_body_entered(body):
	# Player has the method 'pick_up_treasure'
	if body.has_method('pick_up_treasure'):
		hide();
		body.pick_up_treasure()
		queue_free()
		
