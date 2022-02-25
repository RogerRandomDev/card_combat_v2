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
		"Variance":1,
		"Weakens":null,
		"Strengthens":null,
		"AttackAttribute":"Physical",
		"HealAttribute":"Holy",
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
	func hurt(val):
		var floaty=Classes.float_text.new()
		floaty.rect_global_position=root.rect_global_position-Vector2(sign(root.hit_direction().x)*16,0)
		root.get_parent().get_parent().add_child(floaty)
		if stats.Hp-val <0||stats.Hp-val > stats.maxHp:
			val = stats.maxHp-stats.Hp
		stats.Hp=max(min(stats.Hp-val,stats.maxHp),0)
		root.get_node("Hp").text = "Hp:"+str(stats.Hp)
		
		floaty.load_self(str(abs(val)),Vector2(0,-64).rotated(randf_range(-PI/4,PI/4)),Vector2(0,128),val<0)
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
		stats.Variance = data.variance
		texture = data.texture
		stats.Strengthens = data.strengthens
		stats.Weakens = data.weakens
		#sets the action attributes for the character
		if !data.has("healattribute"):stats.HealAttribute="Holy"
		else:stats.HealAttribute=data.healattribute
		if !data.has("attackattribute"):stats.AttackAttribute=stats.Strengthens.split(",")[0]
		else:stats.AttackAttribute=data.attackattribute
		root.get_node("Hp").text = "Hp:"+str(stats.Hp)
	func load_texture():
		root.get_node("SpriteHolder/TextureRect").texture = load("res://Textures/entities/"+texture+".png")
	#modifies the action power
	func modify_action_power(base_power,attack_attribute,strength_of,defense_of,modify_with_stats=true):
		var modifier = 1.0
		attack_attribute=attack_attribute.split(",")
		var modifier_booster = 1.0
		var my_strengths = stats.Strengthens.split(",")
		var my_weaknesses = stats.Weakens.split(",")
		#modifies the output based on strengths and weaknesses
		for strength in my_strengths:
			if attack_attribute.has(strength):
				modifier+=modifier_booster
				modifier_booster = lerp(modifier_booster,0.0,0.5)
		modifier_booster = 0.5
		for weakness in my_weaknesses:
			if attack_attribute.has(weakness):
				modifier-=modifier_booster
				modifier_booster = lerp(modifier_booster,0.0,0.5)
		
		#modifier for the power of the enemy to the current defense of the target
		var modified_strength_to_defense=pow(strength_of/defense_of,0.75)
		if !modify_with_stats:modified_strength_to_defense=1.0
		
		return max(round(base_power*modifier*modified_strength_to_defense),1.0)

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








