extends Node


var active_hover = null
var current_target_type="Target"

#type fight modifiers
var type_matches = {
	"Earth":{"Water":0.5,"Air":0.75,"Fire":1.25,"Plant":0.75,"Electric":0.75},
	"Water":{"Earth":1.25,"Air":1.25,"Fire":1.25,"Plant":0.5,"Electric":0.5},
	"Fire":{"Earth":0.5,"Water":0.5,"Plant":1.5,"Air":1.25},
	"Air":{"Water":0.5,"Plant":0.75,"Fire":1.25,"Earth":1.5,"Sky":0.5},
	"Plant":{"Water":1.5,"Air":1.25,"Fire":0.25,"Earth":0.75,"Sky":1.75},
	"Blood":{"Soul":2.5,"Holy":1.5,"Evil":0.75,"Dark":0.75,"Physical":1.5,"Electric":0.75},
	"Sky":{"Air":0.75,"Water":1.25,"Earth":1.25,"Fire":1.5,"Plant":0.5,"Electric":1.25},
	"Physical":{"Soul":0.0,"Air":0.5,"Fire":0.75,"Light":0.5,"Dark":0.5,"Physical":5.0,"Electric":0.75},
	"Soul":{"Physical":0.0,"Holy":1.5,"Light":1.5,"Evil":1.5,"Dark":1.5,"Blood":0.75,"Electric":0.5},
	"Holy":{"Evil":2.0,"Dark":1.5,"Light":0.5,"Holy":0.0,"Soul":1.5,"Electric":0.75},
	"Evil":{"Holy":2.0,"Light":1.5,"Dark":0.5,"Evil":0.0,"Soul":1.5},
	"Dark":{"Evil":0.5,"Holy":1.5,"Light":1.25},
	"Light":{"Holy":0.5,"Evil":1.5,"Dark":1.25},
	"Electric":{"Water":2.5}
}




var selected_now = {}
var action_list=[]

var current_turn = 0
var whos_turn="Ally"
var active_target=""
var ally_count = 3
var enemy_count = 3

var default_deck = []

var hovering_card = null


var store_for_next_turn=[]

var cur_enemy_turn = 0


var root = null

#preload scenes
var combatParticles = preload("res://Scenes/game_combat/combat_select_particle.tscn")





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
	if get_tree().current_scene.get_node_or_null("CombatContainer")==null:return
	#lets you store a card for the next turn
	if Input.is_action_just_pressed("right_mouse")&&hovering_card!=null:
		var start_pos = hovering_card.rect_global_position
		var move_to = get_tree().current_scene.get_node("CombatContainer/game_combat/storestack")
		if move_to.get_child_count()>=4:return
		hovering_card.get_parent().remove_child(hovering_card)
		move_to.add_child(hovering_card)
		hovering_card.rect_global_position=start_pos
		var tween:Tween=hovering_card.create_tween()
		tween.tween_property(hovering_card,"rect_position",Vector2(32,47),0.25)
	
	
	#if hovering, then it selects this for the current target
	if Input.is_action_just_pressed("left_mouse")&&active_hover!=null:
		root.get_node("selectable_particles").emitting=false
		root.get_node("Turn/Enemy").modulate=Color.WHITE
		root.get_node("Turn/Ally").modulate=Color.WHITE
		#sets the action header to be better read by the code
		var header = current_target_type
		match current_target_type:
			"Target":header="Self"
			"Ally":
				header="Target"
			"Enemy":
				header="Target"
			"Card":
				var will_harm = active_hover.card_data.type=="Harmful"
				root.get_node("Turn/Enemy").modulate=Color(1.0,int(!will_harm),int(!will_harm))
				root.get_node("Turn/Ally").modulate=Color(1.0,int(will_harm),int(will_harm))
				if !will_harm:
					root.get_node("selectable_particles").scale.y = ally_count/3.0
				else:
					root.get_node("selectable_particles").scale.y = enemy_count/3.0
				root.get_node("selectable_particles").position = Vector2(96+int(!will_harm)*800,224)
				root.get_node("selectable_particles").emitting=true
		selected_now[header]=active_hover
		if header=="Card":
			active_hover.get_parent().get_parent().show_card_description("")
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
				get_tree().current_scene.get_node("CombatContainer/game_combat/AnimationPlayer").play("activate_action")
				



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
		if does_action.base.stats.Hp>0&&recieves_action.base.stats.Hp>0:
			var out = card.get_output_value()
			
			var recieves_action_defense = recieves_action.base.stats.Def
			
			#gets the attribute to use for the action
			var does_action_power = 0
			var modifiers={"Physical":1,"Holy":1,"Magic":1}
			for type_split in card.card_data.attribute.split(","):
				if type_split == "Physical":
					does_action_power += does_action.base.stats.Str*modifiers.Physical
					modifiers.Physical*=0.5
				elif type_split =="Holy":
					does_action_power += does_action.base.stats.Sup*modifiers.Holy
					modifiers.Holy*=0.5
				else:
					does_action_power += does_action.base.stats.Mag*modifiers.Magic
					modifiers.Magic*=0.5
			
			
			#determines if it should be modified by the final stat check
			var stats_modifier_switch = does_action.base.object_type!=recieves_action.base.object_type
			
			#final modifier for the strength of the action
			out = does_action.base.modify_action_power(out,card.card_data.attribute,does_action_power,recieves_action_defense,stats_modifier_switch,does_action.base.stats.Attribute,recieves_action.base.stats.Attribute)
			#finishes the action
			if card.harmful():hit_target(recieves_action,out)
			elif card.heals():heal_target(recieves_action,out)
	action_list.erase(action_list[0])
	selected_now={}
	#changes current action
	if get_tree().current_scene.get_node("CombatContainer/game_combat").has_method("enemy_turn_trigger")&&action_list.size()==0:
		get_tree().current_scene.get_node("CombatContainer/game_combat").enemy_turn_trigger()


#makes them red and push back slightly
func hit_target(target=null,strength_of=1):
	if(target==null):return false
	target.base.hurt(max(strength_of,1))
	shake_camera(0.125)
	var tween:Tween=target.create_tween()
	tween.parallel().tween_property(target,"rect_position",target.hit_direction(),0.125)
	tween.parallel().tween_property(target,"modulate",Color(1.0,0.5,0.5),0.125)
	tween.tween_property(target,"rect_position",target.rect_position,0.125)
	tween.tween_property(target,"modulate",Color(1.0,1.0,1.0),0.125)

#same as hit_target but green and heals
func heal_target(target=null,strength_of=1):
	if(target==null):return false
	target.base.hurt(max(abs(strength_of),1),false)
	var tween:Tween=target.create_tween()
	tween.parallel().tween_property(target,"rect_scale",Vector2(1.25,1.25),0.125)
	tween.parallel().tween_property(target,"modulate",Color(0.5,1.0,0.5),0.125)
	tween.tween_property(target,"rect_scale",Vector2.ONE,0.125)
	tween.tween_property(target,"modulate",Color(1.0,1.0,1.0),0.125)
	



#enemy actions
func do_enemy_turns(enemy,enemy_neighbors,ally_neighbors):
	if enemy==null:return
	var target_now = null;
	#health ratios of self and ally enemies
	var ally_health_ratios = []
	if enemy_neighbors!=null:
		for ally in enemy_neighbors:
			ally_health_ratios.append(float(ally.base.stats.Hp)/float(ally.base.stats.maxHp))
	while target_now==null:
		var heal_requirement_this_turn = 1-pow(randf_range(0.95,1.0),pow(enemy.base.stats.Sup/2,1.25))
		var least_health=1.0
		var target_action = "hit_target"
		
		for ally in ally_health_ratios.size():
			var health = ally_health_ratios[ally]
			if randf_range(0.0,1.0)<=health:continue
			if health <= heal_requirement_this_turn&&health<=least_health||target_now==null:
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
			if health <=attack_enemy&&health <=lowest_ally_hp||(target_now==null&&target_now_a==null):
				if target_now_a==null||target_now_a.base.stats.maxHp<ally_neighbors[enemyy].base.stats.maxHp*randf_range(0.5,1.5):
					target_now_a=ally_neighbors[enemyy]
					lowest_ally_hp=health
		#chooses if it will do a hurt action or heal action
		
		if lowest_ally_hp*randf_range(1.0,0.875) < least_health&&target_now_a!=null:
			target_action="hit_target"
			target_now = target_now_a
		var output_strength = 0.0
		var recieves_action_defense = target_now.base.stats.Def
			
		#gets the attribute to use for the action
		var does_action_power = 0
		var card = Data.cards[enemy.base.stats.HurtCard]
		if target_action!="hit_target":
			card = Data.cards[enemy.base.stats.HealCard]
		var modifiers={"Physical":1,"Holy":1,"Magic":1}
		for type_split in card.attribute.split(","):
				if type_split == "Physical":
					does_action_power += enemy.base.stats.Str*modifiers.Physical
					modifiers.Physical*=0.5
				elif type_split =="Holy":
					does_action_power += enemy.base.stats.Sup*modifiers.Holy
					modifiers.Holy*=0.5
				else:
					does_action_power += enemy.base.stats.Mag*modifiers.Magic
					modifiers.Magic*=0.5
		var out_card = enemy.base.stats.HurtCard
		#switches stat to support to enure it heals correctly
		if target_action=="heal_target":
			does_action_power = pow(enemy.base.stats.Sup,0.375)
			out_card = enemy.base.stats.HealCard
		out_card = Data.cards[out_card]
		#determines if it should be modified by the final stat check
		var stats_modifier_switch = enemy.base.object_type!=target_now.base.object_type
		
		output_strength = enemy.base.modify_action_power(out_card.strength,out_card.attribute,does_action_power,recieves_action_defense,stats_modifier_switch,enemy.base.stats.Attribute,target_now.base.stats.Attribute)
		
		if target_now!=null:
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
