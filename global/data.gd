extends Node


var cards={}
var entities={}

#initializes data
func _ready():
	var file = File.new()
	file.open("res://Data.tres",File.READ)
	
	var file_data = parse_data(file.get_as_text())
	#builds the cards data
	for card in file_data["Cards"]:
		var card_name = card.name
		card.erase("name")
		cards[card_name]=card
	#builds entity data
	for entity in file_data["Entities"]:
		var entity_name = entity.name
		entity.erase("name")
		entities[entity_name]=entity


func parse_data(data):
	return str2var(data.replace("\t","").replace("\n",""))
