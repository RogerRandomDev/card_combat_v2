extends TextureRect





var hovered = false




func hover_over():hovered = true

func stop_hover():hovered = false



func _input(_event):
	if !hovered:return
	if get_child_count()==0:return
	if get_parent().get_node("CardList").get_child_count()>=9:return
	if Input.is_action_just_pressed("left_mouse"):
		var moving = get_child(get_child_count()-1)
		var start_pos = moving.rect_global_position
		remove_child(moving)
		get_parent().get_node("CardList").add_child(moving)
