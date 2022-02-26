extends Control


var current_mode = "Creatures"

#loads Entities into the list
func _ready():
	selected_tab(0)


#puts item into the list
func load_item_to_list(name_of,texture):
	$CharacterList.add_item(name_of,load(texture))

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



func show_Creatures(data):
	pass
func show_Cards(data):
	pass

#shows the entity data
func _on_character_list_item_selected(index):
	if current_mode=="Creatures":
		call("show_"+current_mode,Data.entities[$CharacterList.get_item_text(index)])
	else:
		call("show_"+current_mode,Data.cards[$CharacterList.get_item_text(index)])
