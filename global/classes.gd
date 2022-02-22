extends Node





class combat_object extends Node:
	var root=null
	var object_type="Ally"
	var selected=false
	
	var stats = {
		"Hp":50,
		"Str":5,
		"Def":5,
		"Sup":5
		}
	
	
	func hover():return Combat.set_hovered(root,object_type)
	
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
	
	func next_target(cur_turn):
		if cur_turn==object_type:
			return "next_turn"
		else:
			if Combat.active_target==object_type:return "next_turn"
			return "Card"


class float_text extends Label:
	var float_dir=Vector2.ZERO
	var grav = Vector2.ZERO
	func load_self(textnew="Blank",direction=Vector2(0,-64),gravity=Vector2(0,128),heal=false):
		text = textnew
		float_dir=direction
		grav=gravity
		if heal:modulate=Color.GREEN
		else:modulate=Color.RED
	func _process(delta):
		float_dir += grav*delta
		rect_position += float_dir*delta








