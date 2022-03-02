extends Control





func return_card_pressed():
	var tween:Tween=$card_view.create_tween()
	tween.tween_property($card_view,"rect_position",Vector2(1024,0),0.5)
	tween.parallel().tween_property($Base,"rect_position",Vector2.ZERO,0.5)


func to_deck_pressed():
	var tween:Tween=$card_view.create_tween()
	tween.tween_property($card_view,"rect_position",Vector2.ZERO,0.5)
	tween.parallel().tween_property($Base,"rect_position",Vector2(-1024,0),0.5)
