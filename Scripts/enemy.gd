extends Control


var last_anim=false

var base = Classes.combat_object.new()

func _ready():
	base.root=self
	base.object_type="Enemy"
	if Combat.cur_enemies.size()<get_index():
		self.queue_free()
	else:
		var my_data = Data.entities[Combat.cur_enemies[self.get_index()]]
		base.set_data(my_data)
		base.load_texture()
	#used for testing purposes, makes going through the game easier
#	base.stats.Hp=1


func hover_over():
	var succeeded = base.hover()
	if succeeded:$AnimationPlayer.play("hovered")

func stop_hover():base.stop_hover()


func stop_hovering():
	last_anim=true
	base.reset_position()


func animation_over():
	if last_anim:
		$AnimationPlayer.stop()
		last_anim=false



func get_next_target(cur_turn):
	return base.next_target(cur_turn)



#returns position to hit self to
func hit_direction():
	return rect_position-Vector2(32,0)


#selects and deselects
func select():base.selected=true
func deselect():base.selected=false

func been_seleced():return base.selected

#resets scaling
func reset():
	base.next_reset()

func set_data(data):
	base.set_data(data)
