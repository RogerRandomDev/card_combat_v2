extends Node2D
const base_combat_scene=preload("res://Scenes/game_combat/combat_scene.tscn")
var combat_scene = null
var first_time=true
func _ready():
	show_current_enemies()
	next_round()
	load_transition()
	reset_score()

#resets combat score
func reset_score() -> void:
	Combat.total_damage=0
	Combat.cards_used=0
	Combat.allies_dead=0

#transition screen
func load_transition() -> void:
	
	var tween:Tween=create_tween()
	tween.tween_callback($levelcontainer.show)
	tween.tween_method(update_rect,-1.,1.,1.0)
	tween.tween_interval(1)
	if !first_time&&cur_round<=max_rounds:
		tween.tween_callback(next_round)
		tween.tween_callback(show_current_enemies)
	else:first_time=false
	
	if cur_round<max_rounds:
		tween.tween_interval(1)
		tween.tween_callback(load_combat_scene)
		tween.tween_method(update_rect,1.,3.,1.0)
		tween.tween_callback($levelcontainer.hide)
	else:
		tween.tween_interval(0.25)
		tween.tween_callback(show_end_panel)

var cur_round = 0
var max_rounds = 3
#loads next round
func next_round() -> void:
	cur_round+=1
	$levelcontainer/levelscreen/container/current_level.text="ROUND: %s/%s"%[str(min(cur_round,max_rounds)),str(max_rounds)]
	

func load_combat_scene() -> void:
	if combat_scene!=null:
		combat_scene.queue_free()
	Combat.can_select=true
	Combat.action_list=[]
	Combat.stored_actions=[]
	combat_scene = base_combat_scene.instantiate()
	combat_scene.get_node("CombatContainer/game_combat").root=self
	add_child(combat_scene)

func update_rect(val) -> void:
	$levelcontainer.material.set_shader_param("cutoff",val)


#shows current enemies to fight
func show_current_enemies() -> void:
	for item in $levelcontainer/levelscreen/container/enemylist.get_item_count():
		$levelcontainer/levelscreen/container/enemylist.remove_item(0)
	for enemy in Combat.cur_enemies:
		var enemydat=Data.entities[enemy]
		var tex = load("res://Textures/entities/%s.png"%enemydat.texture)
		$levelcontainer/levelscreen/container/enemylist.add_item(enemy,tex)

#gains spoils for the round
func get_spoils() -> void:
	var is_card=true
	var texture = load("res://Textures/Card.png")
	var spoillist = $levelcontainer/levelscreen/container/obtainlist
	if cur_round!=max_rounds:
		Combat.current_spoils.append(choose_random_card_from_enemy())
	else:
		Combat.current_spoils.append(choose_random_enemy_from_dungeon())
		var name_of = Combat.current_spoils[Combat.current_spoils.size()-1]
		texture = load("res://Textures/entities/%s.png"%Data.entities[name_of].texture)
		is_card=false
	spoillist.add_item(Combat.current_spoils[Combat.current_spoils.size()-1],texture)
	if is_card:
		var color = Data.cards[Combat.current_spoils[Combat.current_spoils.size()-1]].color
		spoillist.set_item_icon_modulate(spoillist.get_item_count()-1,color)
	
#chooses card from enemy deck
func choose_random_card_from_enemy():
	var deck = Combat.enemy_deck.size()-1
	return Combat.enemy_deck[randi_range(0,deck)]

#chooses enemy from the dungeon you are in
func choose_random_enemy_from_dungeon():
	var cur_enemies = Data.dungeon_enemies
	return cur_enemies[randi_range(0,cur_enemies.size()-1)]



#shows panel for when completing the stage
func show_end_panel() -> void:
	var tween:Tween=create_tween()
	var ending_panel = $levelcontainer/levelscreen/end_panel
	var score_out = round(Combat.total_damage/(1.+pow(Combat.allies_dead,2.))*(1./max(Combat.cards_used-15.,1.)))
	
	ending_panel.get_node("body/score").text="Score:%s"%str(score_out)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(ending_panel,"rect_position",Vector2(128,48),0.5)
	tween.tween_interval(2.0)
	tween.tween_callback(combat_scene.get_node("CombatContainer/game_combat").return_to_title)
