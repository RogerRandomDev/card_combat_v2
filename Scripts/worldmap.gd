extends Node2D
const base_combat_scene=preload("res://Scenes/game_combat/combat_scene.tscn")
var combat_scene = null

func _ready():
	load_transition()

#transition screen
func load_transition():
	
	var tween:Tween=create_tween()
	tween.tween_callback($levelcontainer.show)
	tween.tween_method(update_rect,-1.,1.,1.0)
	tween.tween_interval(1)
	tween.tween_callback(next_round)
	tween.tween_interval(1)
	tween.tween_callback(load_combat_scene)
	tween.tween_method(update_rect,1.,3.,1.0)
	tween.tween_callback($levelcontainer.hide)

var cur_round = 0
var max_rounds = 10
#loads next round
func next_round():
	cur_round+=1
	$levelcontainer/levelscreen/current_level.text="ROUND: %s/%s"%[str(cur_round),str(max_rounds)]
	

func load_combat_scene():
	if combat_scene!=null:
		combat_scene.queue_free()
	combat_scene = base_combat_scene.instantiate()
	add_child(combat_scene)

func update_rect(val):
	$levelcontainer.material.set_shader_param("cutoff",val)
