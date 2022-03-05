extends Control


var characters_at_once = 10

func _ready():
	for chars in characters_at_once:
		var n_char =create_character()
		add_child(n_char)
		n_char.position.x=1088./characters_at_once*chars-64.

func _process(delta):
	for chars in get_children():
		chars.position.x-=delta*64
		if chars.position.x < -64.:
			chars.position.x = 1024.
			change_char_tex(chars)


func change_char_tex(chars):
	var char_tex_name = Data.entities.keys()
	var char_tex = Data.entities[char_tex_name[randi_range(0,char_tex_name.size()-1)]].texture
	chars.texture = load("res://Textures/entities/"+char_tex+".png")
func create_character():
	var s = Sprite2D.new()
	s.scale = Vector2(4.57,4.57)
	s.centered = false
	s.z_index = 0
	change_char_tex(s)
	return s
