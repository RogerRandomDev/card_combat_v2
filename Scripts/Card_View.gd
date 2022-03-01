extends Control


var current_mode = "Creatures"
var deck_size=0
#loads Entities into the list
func _ready():
	selected_tab(0)
	$CharacterList.select(0)
	_on_character_list_item_selected(0)
	load_typelist()
	load_deck()
	update_creature_deck()

#loads the types to the typelist
func load_typelist():
	for type in Combat.type_matches.keys():
		$Type_Matches/TypeList.add_item(type,load("res://Textures/attributes/"+type+".png"))
	for item in $Type_Matches/TypeList.get_item_count():
		$Type_Matches/TypeList.set_item_tooltip_enabled(item,false)

#puts item into the list
func load_item_to_list(name_of,texture):
	$CharacterList.add_item(name_of,load(texture))
	$CharacterList.set_item_tooltip_enabled($CharacterList.get_item_count()-1,false)

#empties the item list
func empty_list():
	for item in $CharacterList.get_item_count():
		$CharacterList.remove_item(0)

#shows the bar on left's types at the moment
func selected_tab(tab):
	if tab==0:
		current_mode="Creatures"
	else:
		current_mode="Cards"
	load_new_items()



func load_new_items():
	empty_list()
	var list_used = null
	if current_mode=="Creatures":
		list_used=Data.entities.values()
	else:
		list_used=Data.cards.values()
	for object in list_used:
		var tex_to_use="res://Textures/Card.png"
		if object.keys().has("texture"):
			tex_to_use="res://Textures/entities/"+object.texture+".png"
		load_item_to_list(object.name,tex_to_use)


#shows the creature data for the datashower
func show_Creatures(data):
	$DataShower/Name.text = data.name
	$DataShower/Texture.texture = load("res://Textures/entities/"+data.texture+".png")
	var all_types = data.attribute.split(",")
	for type in all_types:
		var Sprite = TextureRect.new()
		Sprite.rect_min_size=Vector2(64,64)
		Sprite.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		Sprite.ignore_texture_size=true
		Sprite.texture = load("res://Textures/attributes/"+type+".png")
		$DataShower/ent/TypeList.add_child(Sprite)
	$DataShower/ent/StatList.add_item("Strength: "+str(data.str))
	$DataShower/ent/StatList.add_item("Defense: "+str(data.def))
	$DataShower/ent/StatList.add_item("Support: "+str(data.sup))
	$DataShower/ent/StatList.add_item("Magic: "+str(data.mag))
	$DataShower/card.hide()
	$DataShower/ent.show()


func show_Cards(data):
	$DataShower/Name.text = data.name
	$DataShower/Texture.texture = load("res://Textures/Card.png")
	$DataShower/Texture.modulate = Color(data.color)
	var all_types = data.attribute.split(",")
	for type in all_types:
		var Sprite = TextureRect.new()
		Sprite.rect_min_size=Vector2(64,64)
		Sprite.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		Sprite.ignore_texture_size=true
		Sprite.texture = load("res://Textures/attributes/"+type+".png")
		$DataShower/card/Attributelist.add_child(Sprite)
	$DataShower/card/Description_out.text = "(a)".replace("a",data.type)+"\n"+data.description
	$DataShower/card/power_out.text = str(data.strength-data.variance)+"-"+str(data.strength+data.variance)
	$DataShower/card.show()
	$DataShower/ent.hide()


var cur_data = null
#shows the entity data
func _on_character_list_item_selected(index):
	$DataShower/Texture.modulate = Color.WHITE
	remove_datashower_data()
	if current_mode=="Creatures":
		call("show_"+current_mode,Data.entities[$CharacterList.get_item_text(index)])
		cur_data = Data.entities[$CharacterList.get_item_text(index)]
	else:
		call("show_"+current_mode,Data.cards[$CharacterList.get_item_text(index)])
		cur_data = Data.cards[$CharacterList.get_item_text(index)]


#removes data from datashower
func remove_datashower_data():
	for item in $DataShower/ent/TypeList.get_child_count():
		$DataShower/ent/TypeList.get_child(item).queue_free()
	for item in $DataShower/ent/StatList.get_item_count():
		$DataShower/ent/StatList.remove_item(0)
	for item in $DataShower/card/Attributelist.get_child_count():
		$DataShower/card/Attributelist.get_child(item).queue_free()

#the list of types that gets shown
func typelist_selected(index):
	var matches = [[],[]]
	var type = $Type_Matches/TypeList.get_item_text(index)
	for type_matchup in Combat.type_matches[type].keys():
		if type_matchup.to_lower()=='type':continue
		if Combat.type_matches[type][type_matchup]<1:
			matches[0].append(type_matchup)
		if Combat.type_matches[type][type_matchup]>1:
			matches[1].append(type_matchup)
	$Type_Matches/Strong_against/Content.text = "Weak Against:\n"
	for weak_to in matches[1]:
		$Type_Matches/Strong_against/Content.text+=weak_to+"\n"
	$Type_Matches/Strong_against/Content.text += "\nStrong Against:\n"
	for strong_to in matches[0]:
		$Type_Matches/Strong_against/Content.text+=strong_to+"\n"


#loads the deck
func load_deck():
	for card in $in_use/cur_deck/deck_container/deck_grid.get_children():
		card.queue_free()
	var prev_children = $in_use/cur_deck/deck_container/deck_grid.get_child_count()
	for card in Data.current_deck.keys():
		for nth_card in Data.current_deck[card]:
			var n_card = deck_grid_card.new()
			n_card.card_color = Data.cards[card].color
			n_card.card_name=card
			n_card.card_attribute=Data.cards[card].attribute.split(",")[0]
			$in_use/cur_deck/deck_container/deck_grid.add_child(n_card)
	$in_use/cur_deck/counter.text = str($in_use/cur_deck/deck_container/deck_grid.get_child_count()-prev_children)+"/30"
	deck_size = $in_use/cur_deck/deck_container/deck_grid.get_child_count()-prev_children
	if deck_size < 10:
		$in_use/cur_deck/cant_label.show()
	else:
		$in_use/cur_deck/cant_label.hide()


#updates card counter
func update_counter(val=0):
	$in_use/cur_deck/counter.text = str($in_use/cur_deck/deck_container/deck_grid.get_child_count()+val)+"/30"
	deck_size = $in_use/cur_deck/deck_container/deck_grid.get_child_count()+val
	if deck_size < 10:
		$in_use/cur_deck/cant_label.show()
	else:
		$in_use/cur_deck/cant_label.hide()
func use_bar_tab_changed(tab):
	$in_use/cur_deck.visible=false
	$in_use/cur_chars.visible=false
	$in_use.get_child(tab+1).visible=true

#adds an item to the decks
func add_item_to_dek():
	if cur_data ==null:return
	if current_mode=="Creatures" && "texture" in cur_data.keys():
		if Data.current_char_deck.size()>=3:return
		Data.current_char_deck.append(cur_data.name)
		update_creature_deck()
	else:
		var cur_card_count = 0
		for card_count in Data.current_deck.values():
			cur_card_count+=card_count
		if cur_card_count>=30:return
		if !Data.current_deck.has(cur_data.name):
			Data.current_deck[cur_data.name]=0
		if Data.current_deck[cur_data.name]>=5:return
		Data.current_deck[cur_data.name]+=1
		load_deck()

#update the creature deck
func update_creature_deck():
	for item in $in_use/cur_chars/charlist.get_item_count():
		$in_use/cur_chars/charlist.remove_item(0)
	for item in Data.current_char_deck:
		$in_use/cur_chars/charlist.add_icon_item(load("res://Textures/entities/aaa.png".replace("aaa",Data.entities[item].texture)))
	if Data.current_char_deck.size() <=0:
		$in_use/cur_chars/cant_label.show()
	else:
		$in_use/cur_chars/cant_label.hide()


func _on_charlist_item_selected(index):
	Data.current_char_deck.remove_at(index)
	$in_use/cur_chars/charlist.remove_item(index)
	if Data.current_char_deck.size() <=0:
		$in_use/cur_chars/cant_label.show()
	else:
		$in_use/cur_chars/cant_label.hide()
