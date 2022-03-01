extends Node


var cards={}
var entities={}


var current_deck={
	"Punch":5,
	"Weak Healing":5,
	"Fireball":5,
	"Static Shock":5
}
var current_char_deck=[]


var available_cards = []





#initializes data
func _ready():
	randomize()
	var file = File.new()
	file.open("res://Data.tres",File.READ)
	
	var file_data = parse_data(file.get_as_text())
	#builds the cards data
	for card in file_data["Cards"]:
		var card_name = card.name
		cards[card_name]=card
	#builds entity data
	for entity in file_data["Entities"]:
		var entity_name = entity.name
		entities[entity_name]=entity
	#builds the type combat data
	for type_rate in file_data["TypeMatches"]:
		var type_name = type_rate.type
		type_name[0]=type_name[0].to_upper()
		Combat.type_matches[type_name]=type_rate

func parse_data(data):
	return str2var(data.replace("\t","").replace("\n",""))


func shuffle_deck():
	for card in current_deck.keys():
		for card_count in current_deck[card]:
			available_cards.append(card)

func set_unavailable_cards(cardse=[]):
	for card in cardse:available_cards.remove_at(available_cards.find(card))
	

func get_card_from_deck():
	var selected_card = randi_range(0,available_cards.size()-1)
	var output = cards[available_cards[selected_card]]
	available_cards.remove_at(selected_card)
	return output


func random_entity():
	return entities.values()[randi_range(0,entities.size()-1)]
