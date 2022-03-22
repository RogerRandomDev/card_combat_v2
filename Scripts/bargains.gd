extends PanelContainer




func _on_abyssbargains_pressed():
	var tween:Tween=create_tween()
	tween.tween_property(self,"rect_position",Vector2(256,150),0.25)



func _on_closebargains_pressed():
	var tween:Tween=create_tween()
	tween.tween_property(self,"rect_position",Vector2(256,632),0.25)
