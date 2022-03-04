extends Node


var file = File.new()
func _ready():
	load_save()




func store_save():
	file.open("user://SaveGame.dat",file.WRITE)
	var store_data = {
		"deck":Data.current_deck,
		"char_deck":Data.current_char_deck
		
		
		
	}
	file.store_line(var2str(store_data))
	file.close()

func load_save():
	if !file.file_exists("user://SaveGame.dat"):return
	file.open("user://SaveGame.dat",file.READ)
	var stored_data = str2var(file.get_as_text())
	Data.current_deck=stored_data.deck
	Data.current_char_deck=stored_data.char_deck
	file.close()
