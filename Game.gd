extends Node

var current_scene = null
var level_string = 'Level-'
var current_level = 0;
var file = File.new()

onready var game_over_scene_path = "res://scenes/menus/GameOver.tscn"

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	
func start_game():
	var level_path = return_level_path(current_level)
	goto_scene(level_path)
	
func load_next_level():
	current_level = current_level + 1;
	var level_path = return_level_path(current_level)
	goto_scene(level_path)
	
func retry():
	var level_path = return_level_path(current_level)
	goto_scene(level_path)

func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:

	call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path):
	# It is now safe to remove the current scene
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instance()

	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)
	
func show_game_over_scene():
	goto_scene(game_over_scene_path);
	
func return_level_path(level_nr):
	var scene_path = "res://scenes/levels/Level-%s.tscn"
	var path = scene_path % str(level_nr)
	if file.file_exists(path):
		print(path)
		return path; 
