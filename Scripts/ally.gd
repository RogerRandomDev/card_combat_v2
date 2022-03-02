extends Control


var last_anim=false

var base = Classes.combat_object.new()


func _ready():
	base.root=self
	base.object_type="Ally"
	$SpriteHolder/TextureRect.flip_h=true

func hover_over():
	Combat.update_target()
	if been_seleced()&&(Combat.current_target_type=="Card"||Combat.current_target_type=="Target"):return false
	var succeeded = base.hover(Combat.current_target_type!="Card")
	if succeeded:$AnimationPlayer.play("hovered")

func hover_anim():$AnimationPlayer.play("hovered")

func stop_hover():
	if been_seleced():return false
	base.stop_hover()


func stop_hovering():
	if been_seleced():
		if Combat.current_target_type!="Card":base.reset_scale()
		return false
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
	return rect_position+Vector2(32,0)


#selects and deselects
func select():
	if Combat.current_target_type=="Card":base.selected=true
func deselect():base.selected=false

func been_seleced():return base.selected

#resets scaling
func reset():
	base.next_reset()
