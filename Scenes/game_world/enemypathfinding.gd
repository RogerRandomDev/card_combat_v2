extends Node2D


@onready var player = get_parent().get_node("Player")
@onready var map = get_parent().get_node("ConvertedMap")
var start = Vector2i.ZERO
const death = preload("res://Scenes/game_world/exploding_enemy.tscn")
var enemy_positions = []
func _ready():
	for enemy in get_parent().get_node("Entities").get_children():
		enemy_positions.append(enemy.position)
	start_off = get_parent().get_node("Entities").get_child_count()
var index_offset =0
var start_off = 0
func _do():
	var target = pos_to_points(player.position)
	var offset = 0
	for enemy in get_parent().get_node("Entities").get_children():
		var mpos=pos_to_points(enemy.position);
		var out = map.astar.get_id_path(mpos,target)
		if out.size()<2:continue
		var move_to=map.astar.get_point_position(out[1])*8
		var tween:Tween=enemy.create_tween()
		tween.tween_property(enemy,"position",move_to,0.25)
		
		enemy_positions[enemy.get_index()]=move_to


func pos_to_points(pos):
	var out = 0
	var n_pos = Vector2(round(pos.x/8),round(pos.y/8))
	out=n_pos.x+(n_pos.y*map.mapsize.x)
	return out
