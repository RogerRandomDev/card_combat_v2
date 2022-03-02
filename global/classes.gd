extends Node





#combat object that holds the stats and functions used by both player and enemies
class combat_object extends Node:
	
	
	
	
	
	
	
	var root=null
	var object_type="Ally"
	var selected=false
	
	var stats = {
		"maxHp":50,
		"Hp":50,
		"Str":5,
		"Def":5,
		"Mag":5,
		"Sup":5,
		"Weakens":null,
		"Strengthens":null,
		"AttackAttribute":"Physical",
		"HealAttribute":"Holy",
		"Attribute":"Physical",
		"HealCard":"Weak Healing",
		"HurtCard":"Punch"
		}
	func _ready():
		randomize()
	
	
	func hover(do_animate=true):return Combat.set_hovered(root,object_type,do_animate)
	
	func stop_hover():return Combat.set_hovered(null,object_type)
	
	
	
	func reset_position():
		root.get_node("AnimationPlayer").stop()
		var tween:Tween=root.get_node("SpriteHolder").create_tween()
		tween.tween_property(root.get_node("SpriteHolder"),"rect_scale",Vector2.ONE,0.125)
		tween.parallel().tween_property(root,"rect_scale",Vector2.ONE,0.125)
		tween.parallel().tween_property(root.get_node("SpriteHolder"),"rect_rotation",0.0,0.125)
	func next_reset():
		root.deselect()
		reset_position()
		root.stop_hovering()
		if selected:
			reset_scale()
	func reset_scale():
		var tween:Tween=root.get_node("SpriteHolder").create_tween()
		tween.parallel().tween_property(root,"rect_scale",Vector2.ONE,0.125)
	
	func next_target(cur_turn):
		if cur_turn==object_type:
			return "next_turn"
		else:
			return "Card"
	
	#deals damage and shows the float text
	func hurt(val,damaging=true):
		var floaty=Classes.float_text.new()
		floaty.rect_global_position=root.rect_global_position-Vector2(sign(root.hit_direction().x)*16,0)
		root.get_parent().get_parent().add_child(floaty)
		if stats.Hp-val <0||stats.Hp-val > stats.maxHp:
			val = stats.maxHp-stats.Hp
		val *= sign(int(damaging)*2-1)
		stats.Hp=max(min(stats.Hp-val,stats.maxHp),0)
		root.get_node("Hp").text = "Hp:"+str(stats.Hp)
		
		#store how much damage was taken since the action occured
		if val > 0:
			for action in Combat.action_list:
				if action.Self==root:
					action.Card.stored_damage+=val
					break
		
		
		floaty.load_self(str(abs(val)),Vector2(0,-64).rotated(randf_range(-PI/4,PI/4)),Vector2(0,128),!damaging)
		if stats.Hp <= 0:
			
			Combat.set(object_type.to_lower()+"_count",Combat.get(object_type.to_lower()+"_count")-1)
			
			root.queue_free()
	var texture = ""
	func set_data(data):
		stats.Str=data.str
		stats.Def=data.def
		stats.Mag=data.mag
		stats.Sup=data.sup
		stats.Hp=data.hp
		stats.maxHp=data.hp
		texture = data.texture
		stats.Attribute = data.attribute
		#sets the action attributes for the character
		if !data.has("healattribute"):stats.HealAttribute="Holy"
		else:stats.HealAttribute=data.healattribute
		if !data.has("attackattribute"):stats.AttackAttribute=stats.Attribute
		else:stats.AttackAttribute=data.attackattribute
		#the default action card for this character
		if data.has("healcard"):stats.HealCard=data.healcard
		if data.has("hurtcard"):stats.HurtCard=data.hurtcard
		
		root.get_node("Hp").text = "Hp:"+str(stats.Hp)
	func load_texture():
		root.get_node("SpriteHolder/TextureRect").texture = load("res://Textures/entities/"+texture+".png")
	#modifies the action power
	func modify_action_power(base_power,attack_attribute,strength_of,defense_of,modify_with_stats=true,attacker_attribute="physical",defend_attribute="physical"):
		var modifier = 1.0
		
		#attribute based modifiers
		var modifier_for_attribute = 1.0
		var my_attributes = attacker_attribute.split(",")
		var your_attributes = defend_attribute.split(",")
		var card_attributes = attack_attribute.split(",")
		var modified_attributes = []
		
		#modifies the power based on your attribute to your enemy attributes
		for attribute in your_attributes:
			if !Combat.type_matches.keys().has(attribute):continue
			for enemy_attribute in my_attributes:
				if modified_attributes.has(enemy_attribute):continue
				modified_attributes.append(enemy_attribute)
				if attribute==enemy_attribute:
					modifier_for_attribute*=0.75;continue
				if !Combat.type_matches[attribute].keys().has(enemy_attribute):continue
				modifier_for_attribute*=Combat.type_matches[attribute][enemy_attribute]
			for enemy_attribute in card_attributes:
				modified_attributes.append(enemy_attribute)
				if attribute==enemy_attribute:
					modifier_for_attribute*=0.75;continue
				if !Combat.type_matches[attribute].keys().has(enemy_attribute):continue
				modifier_for_attribute*=Combat.type_matches[attribute][enemy_attribute]
		#modifier for the power of the enemy to the current defense of the target
		var modified_strength_to_defense=max(sqrt(defense_of/max(strength_of,1)),0.5)
		if modified_strength_to_defense<=0.125:
			modified_strength_to_defense=0.125
		if !modify_with_stats:
			modifier_for_attribute=1.0
			modified_strength_to_defense=1.0
		return round(base_power*modifier*modified_strength_to_defense*modifier_for_attribute)
	
	
	
	var current_effects = []
	
	#inflicts status effects on self
	func inflict_effect(name_of):
		if current_effects.has(name_of):return false
		#needs to add to list container when added
		current_effects.append(name_of)
	#removes inflicted status effect
	func remove_effect(name_of):
		if !current_effects.has(name_of):return
		#needs to remove from list container when added
		current_effects.erase(name_of)
	





#floaty text
class float_text extends Label:
	var float_dir=Vector2.ZERO
	var grav = Vector2.ZERO
	var time = 0.0
	func load_self(textnew="Blank",direction=Vector2(0,-64),gravity=Vector2(0,128),heal=false):
		text = textnew
		float_dir=direction
		grav=gravity
		if heal:modulate=Color.GREEN
		else:modulate=Color.RED
	func _process(delta):
		float_dir += grav*delta
		rect_position += float_dir*delta
		time +=delta
		if time >=1:
			queue_free()







