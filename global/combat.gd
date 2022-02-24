extends Node


var active_hover = null
var current_target_type="Target"


var selected_now = {}
var action_list=[]

var current_turn = 0
var whos_turn="Ally"
var active_target=""
var ally_count = 3

var default_deck = []

var hovering_card = null


var store_for_next_turn=[]

var cur_enemy_turn = 0




#preload scenes
var combatParticles = preload("res://Scenes/combat_select_particle.tscn")





func set_hovered(target,type,animate=true):
	if current_target_type.replace("Target",whos_turn)!=type:return false
	current_target_type=current_target_type.replace("Target",whos_turn)
	if current_target_type!=type&&current_target_type!=whos_turn:return false
	if target==active_hover:return false
	if current_target_type==whos_turn&&selected_now.size()<=1:
		current_target_type="Target"
	
	#stops targeting current hover target
	if active_hover!=null:
		var tween:Tween=active_hover.create_tween()
		tween.tween_property(active_hover,"rect_scale",Vector2(1.0,1.0),0.125)
		
		if active_hover.has_method("stop_hovering"):
			active_hover.stop_hovering()
	#if there is a target, it will scale them up
	if animate:
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
			#tweens the colors and actions for the select of a card
			#moves it over to the deck and flips it so a lot of tweening
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
		if header!="Card":
			var particles = combatParticles.instantiate()
			active_hover.get_parent().get_parent().add_child(particles)
			particles.global_position = active_hover.rect_global_position
		stop_hovering()
		
		#if its the next turn action, reloads the actions
		if current_target_type=="next_turn":
			selected_now.Self.base.reset_scale()
			current_target_type="Target"
			action_list.append(selected_now)
			selected_now["Card"].reset()
			selected_now={}
			if action_list.size()>=ally_count:
				get_tree().current_scene.get_node("AnimationPlayer").play("activate_action")
				



func stop_hovering():
	active_hover.stop_hovering()
	active_hover=null




#actions for the combat events

#triggers the actions
func activate_actions():
	active_target=""
	selected_now = action_list[0]
	var card = selected_now.Card
	var does_action = selected_now.Self
	var recieves_action = selected_now.Target
	
	#stops action if one of the required is invalid
	if is_instance_valid(card)&&is_instance_valid(does_action)&&is_instance_valid(recieves_action):
		card.reset()
		does_action.reset()
		recieves_action.reset()
		var out = card.get_output_value()
		if card.harmful():hit_target(recieves_action,out)
		elif card.heals():heal_target(recieves_action,out)
	action_list.erase(action_list[0])
	selected_now={}
	if get_tree().current_scene.has_method("enemy_turn_trigger")&&action_list.size()==0:
		get_tree().current_scene.enemy_turn_trigger()


#makes them red and push back slightly
func hit_target(target=null,strength_of=1):
	if(target==null):return false
	target.base.hurt(strength_of)
	shake_camera(0.125)
	var tween:Tween=target.create_tween()
	tween.parallel().tween_property(target,"rect_position",target.hit_direction(),0.125)
	tween.parallel().tween_property(target,"modulate",Color(1.0,0.5,0.5),0.125)
	tween.tween_property(target,"rect_position",target.rect_position,0.125)
	tween.tween_property(target,"modulate",Color(1.0,1.0,1.0),0.125)

#same as hit_target but green and heals
func heal_target(target=null,strength_of=1):
	if(target==null):return false
	target.base.hurt(-strength_of)
	var tween:Tween=target.create_tween()
	tween.parallel().tween_property(target,"rect_scale",Vector2(1.25,1.25),0.125)
	tween.parallel().tween_property(target,"modulate",Color(0.5,1.0,0.5),0.125)
	tween.tween_property(target,"rect_scale",Vector2.ONE,0.125)
	tween.tween_property(target,"modulate",Color(1.0,1.0,1.0),0.125)
	



#enemy actions
func do_enemy_turns(enemy,enemy_neighbors,ally_neighbors):
	if enemy==null:return
	
	#health ratios of self and ally enemies
	var ally_health_ratios = []
	if enemy_neighbors!=null:
		for ally in enemy_neighbors:
			ally_health_ratios.append(ally.base.stats.Hp/ally.base.stats.maxHp)
	var heal_requirement_this_turn = randf_range(0.0,0.875)
	var least_health=1.0
	var target_now = null
	var target_action = "hit_target"
	
	for ally in ally_health_ratios.size():
		var health = ally_health_ratios[ally]
		if health <= heal_requirement_this_turn&&health<=least_health:
			if target_now==null||target_now.base.stats.maxHp < enemy_neighbors[ally].base.stats.maxHp*randf_range(0.5,1.5):
				target_now=enemy_neighbors[ally]
				target_action="heal_target"
				least_health=health
	
	
	#health ratios for the allies of the player
	var enemy_health_ratios = []
	for enemyy in ally_neighbors:
		enemy_health_ratios.append(enemyy.base.stats.Hp/enemyy.base.stats.maxHp)
	var attack_enemy=randf_range(0.5,1.0)
	var lowest_ally_hp = 100.0
	var target_now_a=null
	for enemyy in enemy_health_ratios.size():
		var health = enemy_health_ratios[enemyy]
		if health <=attack_enemy&&health <=lowest_ally_hp:
			if target_now_a==null||target_now_a.base.stats.maxHp<ally_neighbors[enemyy].base.stats.maxHp*randf_range(0.5,1.5):
				target_now_a=ally_neighbors[enemyy]
				lowest_ally_hp=health
	#chooses if it will do a hurt action or heal action
	if lowest_ally_hp*randf_range(0.625,0.875) < least_health&&target_now_a!=null:
		target_action="hit_target"
		target_now = target_now_a
	var output_strength = enemy.base.stats.Str+randi_range(-enemy.base.stats.Def,enemy.base.stats.Def)
	if target_action=="heal_target":
		output_strength = enemy.base.stats.Sup+randi_range(-enemy.base.stats.Def,enemy.base.stats.Def)
	call(target_action,target_now,output_strength)






var camera = null
#camera to be shaken
func shake_camera(val):
	if camera==null:return
	camera.add_shake(val)

#makes sure the taret works as it should
func update_target():
	if current_target_type=="Ally"&&selected_now.size()==0:
		current_target_type="Target"
