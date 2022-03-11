extends Node



const action_player = preload("res://Scenes/game_combat/attackanimator.tscn")

#plays animations for actions
func activate_action(name_of,target_enemy,trigger_person):
	var player = action_player.instantiate()
	add_child(player)
	player.target_enemy=target_enemy
	player.trigger_person=trigger_person
	player.play(name_of)
