extends Node



var active_hover = null
var current_target_type="Enemy"

var selected_now = {}

func set_hovered(target,type):
	if current_target_type!=type:return false
	if target==active_hover:return false
	
	#stops targeting current hover target
	if active_hover!=null:
		var tween:Tween=active_hover.create_tween()
		tween.tween_property(active_hover,"rect_scale",Vector2(1.0,1.0),0.125)
		
		if active_hover.has_method("stop_hovering"):
			active_hover.stop_hovering()
	
	#if there is a target, it will scale them up
	if target!=null:
		var tween:Tween=target.create_tween()
		tween.parallel().tween_property(target,"rect_scale",Vector2(1.5,1.5),0.125)
	active_hover = target
	return true



#inputs for the game
func _input(_event):
	#if hovering, then it selects this for the current target
	if Input.is_action_just_pressed("left_mouse")&&active_hover!=null:
		selected_now[current_target_type]=active_hover
		current_target_type = active_hover.get_next_target()
		stop_hovering()



func stop_hovering():
	active_hover.stop_hovering()
	active_hover=null
