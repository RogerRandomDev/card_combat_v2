extends Node2D
const base_combat_scene=preload("res://Scenes/game_combat/combat_scene.tscn")
var combat_scene = null
var first_time=true
func _ready():
	show_current_enemies()
	next_round()
	load_transition()
	

#transition screen
func load_transition():
	
	var tween:Tween=create_tween()
	tween.tween_callback($levelcontainer.show)
	tween.tween_method(update_rect,-1.,1.,1.0)
	tween.tween_interval(1)
	if !first_time:
		tween.tween_callback(next_round)
		tween.tween_callback(show_current_enemies)
	else:first_time=false
	
	tween.tween_interval(1)
	tween.tween_callback(load_combat_scene)
	tween.tween_method(update_rect,1.,3.,1.0)
	tween.tween_callback($levelcontainer.hide)

var cur_round = 0
var max_rounds = 3
#loads next round
func next_round():
	cur_round+=1
	$levelcontainer/levelscreen/container/current_level.text="ROUND: %s/%s"%[str(cur_round),str(max_rounds)]
	

func load_combat_scene():
	if combat_scene!=null:
		combat_scene.queue_free()
	Combat.can_select=true
	combat_scene = base_combat_scene.instantiate()
	combat_scene.get_node("CombatContainer/game_combat").root=self
	add_child(combat_scene)

func update_rect(val):
	$levelcontainer.material.set_shader_param("cutoff",val)


#shows current enemies to fight
func show_current_enemies():
	for item in $levelcontainer/levelscreen/container/enemylist.get_item_count():
		$levelcontainer/levelscreen/container/enemylist.remove_item(0)
	for enemy in Combat.cur_enemies:
		var enemydat=Data.entities[enemy]
		var tex = load("res://Textures/entities/%s.png"%enemydat.texture)
		$levelcontainer/levelscreen/container/enemylist.add_item(enemy,tex)

#gains spoils for the round
func get_spoils():
	if cur_round!=max_rounds:
		Combat.current_spoils.append(choose_random_card_from_enemy())
	else:
		Combat.current_spoils.append(choose_random_enemy_from_dungeon())
	print(Combat.current_spoils)
#chooses card from enemy deck
func choose_random_card_from_enemy():
	var deck = Combat.enemy_deck.size()-1
	return Combat.enemy_deck[randi_range(0,deck)]

#chooses enemy from the dungeon you are in
func choose_random_enemy_from_dungeon():
	var cur_enemies = Data.dungeon_enemies
	return cur_enemies[randi_range(0,cur_enemies.size()-1)]
