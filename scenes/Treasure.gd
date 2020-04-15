extends RigidBody2D


onready var force = Vector2(80, -60);
onready var bounce_force = Vector2(0, -360);
onready var anim = $AnimationPlayer
onready var queue_bounce = false;
onready var queue_throw = false;
onready var throw_direction = 1;

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play('idle')

func throw(direction):
	print('queued throw')
	queue_throw = true;
	throw_direction = direction;
	force.x *= throw_direction
	apply_impulse(Vector2(), force);
	# The direction depends on the player and is either 1 or -1
	
	
func bounce():
	queue_bounce = false;
	apply_impulse(Vector2(), bounce_force);
	queue_bounce = true;

func _on_Treasure_body_entered(body):
	# Player has the method 'pick_up_treasure'
	if body.has_method('pick_up_treasure'):
		hide();
		body.pick_up_treasure()
		queue_free()
		
