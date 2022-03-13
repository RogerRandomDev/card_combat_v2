extends StaticBody2D




@onready var movement = Classes.world_movement.new()

var target_pos =Vector2.ZERO
func _ready():
	movement.root = self
	target_pos=position
	movement.map = get_parent().get_node("ConvertedMap")
	

func _input(_event):
	if movement_pressed():$AnimationPlayer.play("move")
	else:$AnimationPlayer.stop()

#returns if any movement is pressed
func movement_pressed():
	return (Input.is_action_pressed("w")||Input.is_action_pressed("a")||Input.is_action_pressed("s")||Input.is_action_pressed("d"))


#moves the player based on inputs
func check_move():
	if position!=target_pos:return
	
	
	var move_dir = Vector2.ZERO
	move_dir.y =int(Input.is_action_pressed("s"))-int(Input.is_action_pressed("w"))
	if move_dir.y==0:move_dir.x =int(Input.is_action_pressed("d"))-int(Input.is_action_pressed("a"))
	
	if move_dir==Vector2.ZERO:return
	
	#updates the movement direction if it can, and will update target pos as well if it does move
	var did_move = movement.move_in_direction(move_dir)
	
	if did_move:
		$moveparticles.emitting=true
		target_pos+=move_dir*movement.world_tile_size
