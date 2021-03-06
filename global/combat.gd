extends Node


var active_hover = null
var current_target_type="Target"

#type fight modifiers
var type_matches = {}

var can_select=false

var cur_enemies=["Angel","Frog","Flortle"]

#spoils of the current level
var current_spoils=[]


var selected_now = {}
var action_list=[]
var stored_enemy_actions = []
var persisting_actions = []


var current_turn = 0
var whos_turn="Ally"
var active_target=""
var ally_count = 3
var enemy_count = 3

var default_deck = []
var enemy_deck=[
	"Punch",
	"Weak Healing",
	"Fireball"
]

var total_damage=0;
var allies_dead=0;
var cards_used=0;


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
	if root==null||!is_instance_valid(root):return
	#lets you store a card for the next turn
	if Input.is_action_just_pressed("right_mouse")&&hovering_card!=null:
		var start_pos = hovering_card.rect_global_position
		var move_to = root.get_node("storestack")
		if move_to.get_child_count()>=4:return
		hovering_card.get_parent().remove_child(hovering_card)
		move_to.add_child(hovering_card)
		hovering_card.rect_global_position=start_pos
		var tween:Tween=hovering_card.create_tween()
		tween.tween_property(hovering_card,"rect_position",Vector2(32,47),0.25)
		tween.tween_callback(hovering_card.reset)
	
	
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
			selected_now[header]=CardFunc.build_full_card(active_hover.card_data)
			active_hover.get_parent().get_parent().show_card_description("")
			var tween:Tween=active_hover.create_tween()
			var target_of = active_hover.get_parent().get_parent().get_node("cardstack")
			var start_at = active_hover.rect_global_position
			active_hover.get_parent().remove_child(active_hover)
			target_of.add_child(active_hover)
			active_hover.flipping_card()
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
		root.get_node("cur_action").text="SELECT AN ALLY"
		match current_target_type:
			"Card":
				root.get_node("cur_action").text="SELECT CARD"
			"Enemy":
				root.get_node("cur_action").text="SELECT AN ENEMY"
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
			for card in root.get_node("CardList").get_children():
				card.reset()
			selected_now={}
			if action_list.size()>=ally_count:
				root.get_node("cur_action").visible=false
				root.get_node("AnimationPlayer").play("activate_action")
				
		Sound.play_sound("plink")



func stop_hovering():
	active_hover.stop_hovering()
	active_hover=null




#actions for the combat events
var stored_actions = []
#triggers the actions
func activate_actions(enemy_turn=false):
	active_target=""
	if action_list.size()==0:return
	selected_now = action_list[0].duplicate(true)
	var card = selected_now.Card
	var does_action = selected_now.Self
	var recieves_action = selected_now.Target
	
	#if the delay is not met, then it will repeat itself
	if(card.delay>0):
		selected_now.Card.delay-=1
		stored_actions.append(selected_now.duplicate(true))
		action_list.remove_at(0)
		selected_now = {}
		if root.has_method("enemy_turn_trigger")&&action_list.size()==0:
			action_list.append_array(stored_actions.duplicate(true))
			stored_actions=[]
			#ensures the enemy turn wont repeat forever
			if !enemy_turn:
				root.enemy_turn_trigger()
				
		return action_list
	
	#stops action if one of the required is invalid
	if is_instance_valid(does_action)&&is_instance_valid(recieves_action):
		does_action.reset()
		recieves_action.reset()
		if does_action.base.stats.Hp>0&&recieves_action.base.stats.Hp>0:
			var out = CardFunc.get_output_values(card)
			var recieves_action_defense = recieves_action.base.stats.Def
			
			#gets the attribute to use for the action
			var does_action_power = action_strength_modifier(does_action.base.stats,card)
			
			#determines if it should be modified by the final stat check
			var stats_modifier_switch = card.type!="Healing"
			#bonus action modifiers are done here
			var bonus_modifiers = CardFunc.damage_modified_by_bonus(card,does_action,recieves_action)
			#final modifier for the strength of the action
			out = round(bonus_modifiers+does_action.base.modify_action_power(out,card.attribute,does_action_power,recieves_action_defense,stats_modifier_switch,does_action.base.stats.Attribute,recieves_action.base.stats.Attribute,does_action.base.buffs,recieves_action.base.buffs))
			#applies healing based modifiers
			if card.type=="Healing":
				out=round((out*sqrt(does_action.base.stats.Sup)))
			
			#finishes the action
			if CardFunc.type(card.type,"Harmful"):hit_target(recieves_action,out)
			elif CardFunc.type(card.type,"Healing"):heal_target(recieves_action,out)
	if action_list.size()!=0:
		action_list.remove_at(0)
	selected_now={}
	
	#changes current action
	if root.has_method("enemy_turn_trigger")&&action_list.size()==0:
		action_list.append_array(stored_actions.duplicate(true))
		stored_actions=[]
		if !enemy_turn:
			root.enemy_turn_trigger()
	return action_list
#enemy actions
func do_enemy_turns(enemy_neighbor,ally_neighbors):
	while stored_enemy_actions.size()==0&&enemy_neighbor.size()!=0:
		var ally_priorities ={}
		var ally_to_choose=[]
		var placehold=[]
		for ally in ally_neighbors:
			var stats = add_stats(ally.base.stats)
			ally_priorities[ally]=stats
			ally_to_choose.append(stats)
		ally_to_choose.sort_custom(sorter)
		for choice in ally_to_choose:
			for ally in ally_priorities.keys():
				if ally_priorities[ally]==choice:
					placehold.append(ally);break
		for enemy in enemy_neighbor:
			var enemy_neighbors=enemy_neighbor.duplicate(true)
			enemy_neighbors.erase(enemy)
			
			#returns if enemy is in the middle of an action
			for action in stored_enemy_actions:if action.Self == enemy:return
			
			var target_now = null;
			
			#health ratios of self and ally enemies
			var ally_health_ratios = []
			
			
			#chooses to heal an ally of itself
			if enemy_neighbors!=null:
				for ally in enemy_neighbors:
					ally_health_ratios.append(float(ally.base.stats.Hp)/float(ally.base.stats.maxHp))
			
			var target_action = "hit_target"
			#will repeat until it has a target, and will target an enemy
			while target_now==null:
				var heal_requirement_this_turn = 1-pow(randf_range(0.95,1.0),pow(enemy.base.stats.Sup/2,1.25))
				var least_health=1.0
				
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
				for enemyy in placehold:
					enemy_health_ratios.append(enemyy.base.stats.Hp/enemyy.base.stats.maxHp)
				
				
				#prior method to choose to attack player, now it does a stat check as the base
	#			var attack_enemy=randf_range(0.5,1.0)
	#			var lowest_ally_hp = 100000.0
	#			var target_now_a=null
	#			var attack_enemy_stat_check=randi_range(placehold[placehold.size()-1],placehold[0])
				
	#			for enemyy in enemy_health_ratios.size():
	#				var health = enemy_health_ratios[enemyy]
	#
	#				if health <=attack_enemy&&health <=lowest_ally_hp||(target_now==null&&target_now_a==null):
	#					if target_now_a==null||target_now_a.base.stats.maxHp<ally_neighbors[enemyy].base.stats.maxHp*randf_range(0.5,1.5):
	#						target_now_a=ally_neighbors[enemyy]
	#						lowest_ally_hp=health
				#chooses if it will do a hurt action or heal action
				var dir =round(pow(randf_range(0,1),0.5));
				var chosen = abs(round((dir-pow(randf_range(0.,1.),0.25))*(ally_to_choose.size()-1)))
				if add_stats(enemy.base.stats) > ally_to_choose[chosen]*randf_range(0.75,1.0):
					target_now=placehold[chosen]
					target_action="hit_target"
			
			
			#gets the attribute to use for the action
			var card = choose_card_to_use(enemy.base.stats,target_now.base.stats,target_action!="hit_target").duplicate(true)
			
			
			#runs the base action code since CONVENIENCE
			#storing previous information to re-apply after the action
			var store_action = [{"Self":enemy,"Card":card,"Target":target_now}]
			
			
			
			stored_enemy_actions.append_array(store_action)

func do_enemy_action_in_full(data):
	var card = data.Card
	var n_card = card_object.new()
	card = CardFunc.build_full_card(card.duplicate(true))
	n_card.call_deferred('set_data',card)
	n_card.rect_position=Vector2(480,-64)
	root.add_child(n_card)
	var tween:Tween=n_card.create_tween()
	tween.tween_property(n_card,"rect_position",Vector2(480,248),0.125)
	tween.tween_interval(0.125)
	tween.tween_callback(trigger_enemy_action)
	tween.tween_interval(0.375)
	tween.tween_property(n_card,"rect_scale",Vector2(0,0),0.125)
	tween.tween_callback(n_card.queue_free)
	if card.delay>0:return 0
	return 1


var enemy_turn_actions = []
#enemy action trigger
func trigger_enemy_action():
	call_deferred('full_enemy_trigger')
func full_enemy_trigger():
	var stored=action_list.duplicate(true)
	enemy_action_list = stored_enemy_actions.duplicate(true)
	action_list=stored_enemy_actions
	if action_list.size()==0:action_list.append(null)
	var done = trigger_action_enemy()
	if done!=null:
		stored_enemy_actions[0]=done
	else:
		stored_enemy_actions.erase(stored_enemy_actions[0])
	if enemy_turn_actions.size()!=0:
		enemy_turn_actions.remove_at(0)
	action_list = stored

#chooses card from enemy deck to use by the enemy
func choose_card_to_use(my_stats,target_stats,do_heal=false):
	#object to do the calculations for me
	var basic_helper = Classes.combat_object.new()
	
	basic_helper.stats = target_stats
	var max_output=0.0
	var max_output_card="Punch"
	var recieves_action_defense = target_stats.Def
	#loops through cards and skips if it is the wrong type
	for card_names in enemy_deck:
		var card = CardFunc.build_full_card(Data.cards[card_names])
		if card.type=="Harmful"&&do_heal||card.type=="Healing"&&!do_heal:continue
		
		var output_power = abs(full_enemy_action_calculation(card,recieves_action_defense,do_heal,my_stats,target_stats,basic_helper))
		if output_power>max_output:
			max_output=output_power
			max_output_card=card
	return max_output_card

#enemy damage calculation
func full_enemy_action_calculation(card,recieves_action_defense,do_heal,my_stats,target_stats,basic_helper):
	var bonus_modifiers = CardFunc.damage_modified_by_bonus(card,null,null)
	var does_action_power = action_strength_modifier(my_stats,card)
	var output_power = round(bonus_modifiers+basic_helper.modify_action_power(card.strength,card.attribute,does_action_power,recieves_action_defense,!do_heal,my_stats.Attribute,target_stats.Attribute))
	return output_power


#gets the stats to use for the strength of the action
func action_strength_modifier(does_action,card):
	var does_action_power = 0
	var modifiers={"Physical":1,"Holy":1,"Magic":1}
	for type_split in card.attribute.split(","):
		if type_split == "Physical":
			does_action_power += does_action.Str*modifiers.Physical
			modifiers.Physical*=0.5
		elif type_split =="Holy":
			does_action_power += does_action.Sup*modifiers.Holy
			modifiers.Holy*=0.5
		else:
			does_action_power += does_action.Mag*modifiers.Magic
			modifiers.Magic*=0.5
	return does_action_power




#makes them red and push back slightly
func hit_target(target=null,strength_of=1):
	if(target==null):return false
	target.base.hurt(max(abs(strength_of),1))
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
	


#persisting effect actions
func activate_persistent_action(id):
	var action_data = persisting_actions[id]
	#removal conditions
	if (
		!is_instance_valid(action_data.target)||
		action_data.duration_left <=0
	):
		#actions if the objects is valid still
		if(is_instance_valid(action_data.target))&&!action_data.target.is_queued_for_deletion():
			action_data.target.base.remove_effect_icon(action_data.effect)
		persisting_actions.remove_at(id)
		return 0
	hit_target(action_data.target,action_data.strength)
	action_data.duration_left-=1
	persisting_actions[id]=action_data
	return 1




var camera = null
#camera to be shaken
func shake_camera(val):
	if camera==null:return
	camera.add_shake(val)

#makes sure the taret works as it should
func update_target():
	if current_target_type=="Ally"&&selected_now.size()==0:
		current_target_type="Target"

var enemy_action_list = []
#does action visuals for enemies
func trigger_action_enemy():
	if action_list.size()==0:return
	var action = action_list[0]
	if action.Card.delay>0:
		action.Card.delay-=1
		action_list[0]=action
		return action
	action.Card=CardFunc.build_full_card(action.Card)
	root.get_node("AttackPlayer").activate_action(action.Card.appearance,action.Target,action.Self,action.Card,action)
	return null

#does action visuals
func trigger_action():
	if action_list.size()==0:return
	var action = action_list[0].duplicate(true)
	if !(is_instance_valid(action.Target)&&is_instance_valid(action.Self)):
		action_list.remove_at(0)
		if root.has_method("enemy_turn_trigger")&&action_list.size()==0:
			action_list.append_array(stored_actions.duplicate(true))
			stored_actions=[]
			root.enemy_turn_trigger()
		return
	if action.Card.delay!=0:
		activate_actions()
		action.Card.delay-=1
		return action
	root.get_node("AttackPlayer").activate_action(action.Card.appearance,action.Target,action.Self,action.Card,action)



#checks if the round should end or not
func check_teams():
	if enemy_count<=0:
		enemy_count=3
		root.root.get_spoils()
		root.root.load_transition()
		persisting_actions=[]
		stored_enemy_actions=[]
		action_list=[]
		enemy_turn_actions=[]
		enemy_action_list=[]


#adds up stats
func add_stats(stats):
	var out=0
	out+=stats.Str
	out+=stats.Def
	out+=stats.Sup
	out+=stats.Mag
	return str2var(str(out))


func sorter(a,b):
	return a>b
