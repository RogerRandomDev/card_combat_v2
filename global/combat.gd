extends Node


var active_hover = null
var current_target_type="Ally"


var selected_now = {}
var action_list=[]

var current_turn = 0
var whos_turn="Ally"
var active_target=""
var ally_count = 3

var default_deck = []

var hovering_card = null


var store_for_next_turn=[]











func set_hovered(target,type):
	if current_target_type.replace("Target",whos_turn)!=type:return false
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
	if get_tree().current_scene.name!="game_combat":return
	#lets you store a card for the next turn
	if Input.is_action_just_pressed("right_mouse")&&hovering_card!=null:
		var start_pos = hovering_card.rect_global_position
		var move_to = get_tree().current_scene.get_node("storestack")
		if move_to.get_child_count()>=3:return
		hovering_card.get_parent().remove_child(hovering_card)
		move_to.add_child(hovering_card)
		hovering_card.rect_global_position=start_pos
		var tween:Tween=hovering_card.create_tween()
		tween.tween_property(hovering_card,"rect_position",Vector2(32,47),0.25)
	
	
	#if hovering, then it selects this for the current target
	if Input.is_action_just_pressed("left_mouse")&&active_hover!=null:
		#sets the action header to be better read by the code
		var header = current_target_type
		match current_target_type:
			"Target":header="Self"
			"Ally":header="Target"
			"Enemy":header="Target"
		selected_now[header]=active_hover
		if header=="Card":
			var tween:Tween=active_hover.create_tween()
			var target_of = active_hover.get_parent().get_parent().get_node("cardstack")
			var start_at = active_hover.rect_global_position
			active_hover.get_parent().remove_child(active_hover)
			target_of.add_child(active_hover)
			
			active_hover.rect_global_position=start_at
			tween.tween_property(active_hover,"rect_scale",Vector2(0,1.5),0.25)
			tween.parallel().tween_property(active_hover,"rect_position",active_hover.rect_position/2,0.25)
			tween.tween_property(active_hover,"modulate",Color8(128,108,88),0.0625)
			tween.tween_callback(active_hover.hide_content)
			tween.parallel().tween_property(active_hover,"rect_scale",Vector2(-1,1),0.25)
			tween.parallel().tween_property(active_hover,"rect_position",Vector2(0,0),0.25)
			tween.parallel().tween_property(active_hover.card_backing,"rect_position",Vector2(-32,-47),0.25)
			tween.tween_property(active_hover,"rect_scale",Vector2.ONE,0.0)
		#changes the target to the new target
		current_target_type = active_hover.get_next_target(current_target_type)
		#selects and stops hovering the current target
		active_hover.select()
		stop_hovering()
		#if its the next turn action, reloads the actions
		if current_target_type=="next_turn":
			do_enemy_turns()
			current_target_type="Ally"
			current_turn+=1
			action_list.append(selected_now)
			selected_now["Card"].reset()
			selected_now={}
			if action_list.size()>=ally_count:
				activate_actions()
			



func stop_hovering():
	active_hover.stop_hovering()
	active_hover=null




#actions for the combat events

#triggers the actions
func activate_actions():
	var timer = Timer.new()
	action_list[0].Self.get_parent().get_parent().add_child(timer)
	timer.wait_time = 0.375
	timer.one_shot=true
	active_target=""
	for selected in action_list:
		selected_now = selected
		
		
		var card = selected_now.Card
		var does_action = selected_now.Self
		var recieves_action = selected_now.Target
		#stops action if one of the required is invalid
		if !is_instance_valid(card):continue
		if !is_instance_valid(does_action):continue
		if !is_instance_valid(recieves_action):continue
		
		card.reset()
		does_action.reset()
		recieves_action.reset()
		var out = card.get_output_value()
		if card.harmful():hit_target(recieves_action,out)
		
		timer.start()
		await (timer.timeout)
		
	if is_instance_valid(timer):
		timer.queue_free()
	selected_now={}
	action_list = []
	if get_tree().current_scene.has_method("reload_hand"):
		get_tree().current_scene.reload_hand()


#makes them red and push back slightly
func hit_target(target=null,strength_of=1):
	if(target==null):return false
	target.base.hurt(strength_of)
	
	var tween:Tween=target.create_tween()
	tween.parallel().tween_property(target,"rect_position",target.hit_direction(),0.125)
	tween.parallel().tween_property(target,"modulate",Color(1.0,0.5,0.5),0.125)
	tween.tween_property(target,"rect_position",target.rect_position,0.125)
	tween.tween_property(target,"modulate",Color(1.0,1.0,1.0),0.125)
	

#enemy actions
func do_enemy_turns():
	pass
