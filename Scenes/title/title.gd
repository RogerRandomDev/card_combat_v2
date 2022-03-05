extends Control




func quit_pressed():
	get_tree().quit()

func more_pressed():
	pass # Replace with function body.


func credits_pressed():
	pass # Replace with function body.


func settings_pressed():
	pass # Replace with function body.


func play_pressed():
	get_tree().change_scene("res://Scenes/base/main_game.tscn")
