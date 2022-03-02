extends StaticBody2D




@onready var movement = Classes.world_movement.new()

var target_pos =Vector2.ZERO
func _ready():
	movement.root = self
	target_pos=position


#moves the player based on inputs
func _input(_event):
	if position!=target_pos:return
	
	
	var move_dir = Vector2.ZERO
	move_dir.x =int(Input.is_action_just_pressed("d"))-int(Input.is_action_just_pressed("a"))
	move_dir.y =int(Input.is_action_just_pressed("s"))-int(Input.is_action_just_pressed("w"))
	if move_dir==Vector2.ZERO:return
	
	#updates the movement direction if it can, and will update target pos as well if it does move
	var did_move = movement.move_in_direction(move_dir)
	
	if did_move:target_pos+=move_dir*movement.world_tile_size
