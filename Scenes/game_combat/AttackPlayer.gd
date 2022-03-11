extends Node



const action_player = preload("res://Scenes/game_combat/attackanimator.tscn")

#plays animations for actions
func activate_action(name_of,target_enemy,trigger_person,card=null,action_data=null):
	var player = action_player.instantiate()
	add_child(player)
	player.target_enemy=target_enemy
	player.trigger_person=trigger_person
	if card!=null:
		player.pull_color=card.color
	player.data=action_data
	player.play(name_of)
