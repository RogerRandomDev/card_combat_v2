extends Control


var shuffle_count = 0
@export var hand_size=7

#needs to set the combat ally_count
func _ready():
	randomize()
	$AnimationPlayer.play("flipcards")
	Combat.camera=$Camera
	Combat.root = self
	build_player_loadout()

#sets up the player deck and allies
func build_player_loadout():
	for ally in $AllyList.get_child_count():
		if ally >= Data.current_char_deck.size():
			$AllyList.get_child(ally).queue_free();continue
		else:
			$AllyList.get_child(ally).base.set_data(Data.entities[Data.current_char_deck[ally]])
			$AllyList.get_child(ally).base.load_texture()

#plays the enemy's turn
func enemy_turn_trigger():
	enemy_actions = 0
	
	Combat.do_enemy_turns($EnemyList.get_children(),$AllyList.get_children())
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
		for ally_check in Combat.stored_actions:
			if ally_check.Self == ally:
				ally.base.selected=true
				do=false;break
		if do:
			ally.deselect()
			ally.reset()

#removes a card
func remove_card():
	if $CardList.get_child_count()==0:
		shuffle_count=randi_range(10,20)
		$AnimationPlayer.play("shuffle")
		for child in $cardstack.get_children():
			if child.get_class()!="TextureRect":
				child.remove_listeners()
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
	call_deferred('move_card',n_card,$cardstack.rect_global_position)
	
	
	if $CardList.get_child_count()>=hand_size-$storestack.get_child_count():
		$AnimationPlayer.stop()
		$action_stopper.visible=false
		for ally in $AllyList.get_children():
			var do=true
			for ally_check in Combat.action_list:
				if ally_check.Self == ally:
					ally.base.selected=true
					do=false;break
			if do:
				ally.deselect()
				ally.reset()
		if Combat.action_list.size()>=Combat.ally_count:
			get_node("AnimationPlayer").play("activate_action")
		return


#triggers combat global function for actions
func trigger_action():
	if get_tree().get_nodes_in_group("action_trigger").size()!=0:return
	Combat.call_deferred('trigger_action')


var enemy_actions = 0
var offset=0
#does the enemy actions
func trigger_enemy_action():
	if get_tree().get_nodes_in_group("action_trigger").size()!=0:return
	if enemy_actions >= $EnemyList.get_child_count():
		offset=0
		$AnimationPlayer.play("trigger_persistent")
		return
	else:
		get_node("Turn").text = "Enemy's Turn"
	
	offset+=Combat.do_enemy_action_in_full(Combat.stored_enemy_actions[enemy_actions-offset])
	enemy_actions+=1
	


#shows the card's description
func show_card_description(card_data=""):
	$card_description.text=card_data


var persistent_id = 0
#triggers persistent effects
func trigger_persistent_effect():
	if persistent_id >= Combat.persisting_actions.size():
		persistent_id = 0
		reload_hand()
		return
	persistent_id += Combat.activate_persistent_action(persistent_id)

#plays a sound file
func play_sound(sound_name:String="attackhit",sound_end:String="wav"):
	if sound_end=="":sound_end="wav"
	Sound.play_sound(sound_name,sound_end)


#moves card
func move_card(n_card,origin):
	var target_pos = n_card.rect_global_position
	n_card.rect_global_position=origin
	var tween:Tween=n_card.create_tween()
	tween.tween_property(n_card,"rect_global_position",target_pos,0.225)
