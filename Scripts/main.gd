extends Control


var shuffle_count = 0
@export var hand_size=7

#needs to set the combat ally_count
func _ready():
	randomize()
	$AnimationPlayer.play("flipcards")
	Combat.camera=$Camera
	Combat.root = self


#plays the enemy's turn
func enemy_turn_trigger():
	enemy_actions = 0
	$action_stopper.visible=true
	$AnimationPlayer.play("enemy_turn")
#empty and refill the player's hand
func reload_hand():
	$action_stopper.visible=true
	$AnimationPlayer.play("flipcards")
	for card in $CardList.get_children():
		card.flipping_card()
	for ally in $AllyList.get_children():
		var do=true
		for ally_check in Combat.action_list:
			if ally_check.Self == ally:
				do=false;break
		if do:ally.base.selected = false

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
	get_node("Turn").text = "Ally's Turn"
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
	Data.shuffle_deck()
	var cards_removed=[]
	for card_id in $storestack.get_children():
		if card_id.get_class()=="Label":continue
		cards_removed.append(card_id.card_data.name)
	
	Data.set_unavailable_cards(cards_removed)
	var n_card = card_object.new()
	$CardList.add_child(n_card)
	if $CardList.get_child_count()>=hand_size-$storestack.get_child_count():
		$AnimationPlayer.stop()
		$action_stopper.visible=false
		if Combat.action_list.size()>=Combat.ally_count:
			get_node("AnimationPlayer").play("activate_action")
		return


#triggers combat global function for actions
func trigger_action():
	Combat.call_deferred('activate_actions')


var enemy_actions = 0
#does the enemy actions
func trigger_enemy_action():
	if enemy_actions >= $EnemyList.get_child_count():
		reload_hand()
		return
	else:
		get_node("Turn").text = "Enemy's Turn"
	var me = $EnemyList.get_child(enemy_actions)
	Combat.do_enemy_turns(me,$EnemyList.get_children(),$AllyList.get_children())
	enemy_actions+=1


#shows the card's description
func show_card_description(card_data=""):
	$card_description.text=card_data
