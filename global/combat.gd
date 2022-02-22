extends Node


var active_hover = null
var current_target_type="Ally"


var selected_now = {}

var current_turn = 0

var whos_turn="Ally"

var active_target=""

func set_hovered(target,type):
	if current_target_type.replace("Target",whos_turn)!=type:return false
	var n_target = current_target_type
	current_target_type=current_target_type.replace("Target",whos_turn)
	if current_target_type!=type&&current_target_type!=whos_turn:return false
	if target==active_hover:return false
	if current_target_type==whos_turn&&selected_now.size()==0:
		current_target_type="Target"
	
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
		
		#sets the action header to be better read by the code
		var header = current_target_type
		match current_target_type:
			"Target":header="Self"
			"Ally":header="Target"
			"Enemy":header="Target"
		selected_now[header]=active_hover
		
		#changes the target to the new target
		current_target_type = active_hover.get_next_target(current_target_type)
		#selects and stops hovering the current target
		active_hover.select()
		stop_hovering()
		#if its the next turn action, reloads the actions
		if current_target_type=="next_turn":
			current_target_type="Ally"
			current_turn+=1
			activate_actions()
			



func stop_hovering():
	active_hover.stop_hovering()
	active_hover=null




#actions for the combat events

#triggers the actions
func activate_actions():
	active_target=""
	var card = selected_now.Card
	var does_action = selected_now.Self
	var recieves_action = selected_now.Target
	card.deselect()
	card.stop_hovering()
	does_action.reset()
	recieves_action.reset()
	
	
	if card.harmful():hit_target(recieves_action)
	selected_now={}


#makes them red and push back slightly
func hit_target(target=null):
	if(target==null):return false
	var tween:Tween=target.create_tween()
	tween.parallel().tween_property(target,"rect_position",target.hit_direction(),0.125)
	tween.parallel().tween_property(target,"modulate",Color(1.0,0.5,0.5),0.125)
	tween.tween_property(target,"rect_position",target.rect_position,0.125)
	tween.tween_property(target,"modulate",Color(1.0,1.0,1.0),0.125)

