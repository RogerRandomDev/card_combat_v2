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
		"Sup":5
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
		floaty.load_self(str(abs(val)),Vector2(0,-64).rotated(randf_range(-PI/4,PI/4)),Vector2(0,128),val<0)
		floaty.rect_global_position=root.rect_global_position
		root.get_parent().get_parent().add_child(floaty)
		stats.Hp-=val
	
	var texture = ""
	func set_data(data):
		stats.Str=data.str
		stats.Def=data.def
		stats.Sup=data.sup
		stats.Hp=data.hp
		stats.maxHp=data.hp
		texture = data.texture
	
	func load_texture():
		root.get_node("SpriteHolder/TextureRect").texture = load("res://Textures/entities/"+texture+".png")
	#modifies the action power
	func modify_action(power,attribute):
		var modifier = 1.0
		var stat_modified_by = stats.Str
		if attribute!="Physical":
			stat_modified_by=stats.Sup
		modifier=pow(sqrt(stat_modified_by),1.25)
		return round(power*modifier)


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








