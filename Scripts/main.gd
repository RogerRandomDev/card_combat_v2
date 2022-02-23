extends Control


var shuffle_count = 0
@export var hand_size=5

#needs to set the combat ally_count
func _ready():
	randomize()
	$AnimationPlayer.play("flipcards")




#empty and refill the player's hand
func reload_hand():
	$AnimationPlayer.play("flipcards")

#removes a card
func remove_card():
	if $CardList.get_child_count()==0:
		shuffle_count=randi_range(10,20)
		$AnimationPlayer.play("shuffle")
		for child in $cardstack.get_children():
			if child.get_class()!="TextureRect":
				child.queue_free()
		return
	var tween:Tween=$CardList.get_child(0).create_tween()
	var object = $CardList.get_child(0)
	var pos = object.rect_global_position
	$CardList.remove_child(object)
	$cardstack.add_child(object)
	object.rect_global_position = pos
	tween.tween_property(object,"rect_scale",Vector2(0,1.5),0.125)
	tween.parallel().tween_property(object,"rect_position",object.rect_position/2,0.125)
	tween.tween_property(object,"modulate",Color8(128,108,88),0.0)
	tween.tween_callback(object.hide_content)
	tween.parallel().tween_property(object,"rect_scale",Vector2(-1,1),0.125)
	tween.parallel().tween_property(object,"rect_position",Vector2(0,0),0.125)
#shuffle the deck of cards
func shuffle():
	if shuffle_count==0:
		$AnimationPlayer.play("fillhand")
		return
	
	var object = $cardstack.get_child(shuffle_count%3)
	var tween:Tween=object.create_tween()
	tween.tween_property(object,"rect_position",Vector2(-32,-141),0.0625+randf_range(0.0,0.0625))
	tween.tween_property(object,"rect_position",Vector2(-32,-47),0.0625+randf_range(0.0,0.0625))
	
	
	shuffle_count-=1


#adds the cards to your hand
func add_card_to_hand():
	if $CardList.get_child_count()>=hand_size-$storestack.get_child_count():
		$AnimationPlayer.stop()
		return
	var n_card = card_object.new()
	$CardList.add_child(n_card)
	n_card.set_data(Data.cards["Punch"])
	
