extends Line2D


@onready var player = get_parent().get_node("Player")
@onready var map = get_parent().get_node("ConvertedMap")
var start = Vector2i.ZERO


func _do():
	clear_points()
	var target = pos_to_points(player.position)
	var mpos=pos_to_points(start);
	var out = map.astar.get_id_path(target,mpos)
	for point in out:
		add_point(map.astar.get_point_position(point)*8)
	print(out)

func pos_to_points(pos):
	var out = 0
	var n_pos = Vector2(round(pos.x/8),round(pos.y/8))
	out=n_pos.x+(n_pos.y*map.mapsize.x)
	print(n_pos.y*map.mapsize.x)
	return out
