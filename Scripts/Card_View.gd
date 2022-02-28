extends Control


var current_mode = "Creatures"

#loads Entities into the list
func _ready():
	selected_tab(0)
	$CharacterList.select(0)
	_on_character_list_item_selected(0)
	load_typelist()

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

#shows the entity data
func _on_character_list_item_selected(index):
	$DataShower/Texture.modulate = Color.WHITE
	remove_datashower_data()
	if current_mode=="Creatures":
		call("show_"+current_mode,Data.entities[$CharacterList.get_item_text(index)])
	else:
		call("show_"+current_mode,Data.cards[$CharacterList.get_item_text(index)])


#removes data from datashower
func remove_datashower_data():
	for item in $DataShower/ent/TypeList.get_child_count():
		$DataShower/ent/TypeList.get_child(item).queue_free()
	for item in $DataShower/ent/StatList.get_item_count():
		$DataShower/ent/StatList.remove_item(0)
	for item in $DataShower/card/Attributelist.get_child_count():
		$DataShower/card/Attributelist.get_child(item).queue_free()


func typelist_selected(index):
	var matches = ""
