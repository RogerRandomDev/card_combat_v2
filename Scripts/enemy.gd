extends Control


var last_anim=false





func hover_over():
	var succeeded = Combat.set_hovered(self,"Enemy")
	if succeeded:$AnimationPlayer.play("hovered")

func stop_hover():
	Combat.set_hovered(null,"Enemy")


func stop_hovering():
	last_anim=true
	$AnimationPlayer.stop()
	var tween:Tween=create_tween()
	tween.tween_property($SpriteHolder,"rect_scale",Vector2.ONE,0.125)
	tween.parallel().tween_property($SpriteHolder,"rect_rotation",0.0,0.125)


func animation_over():
	if last_anim:
		$AnimationPlayer.stop()
		last_anim=false



func get_next_target():
	return "next_turn"
