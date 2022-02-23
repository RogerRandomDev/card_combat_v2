extends Camera2D


var shake = 0.0
var shake_decay=0.25
var max_offset=32

func _ready():randomize()

func _process(delta):
	if shake:
		shake_screen()
		shake=max(0,shake-(delta*shake_decay*max(shake,1.0)))

func add_shake(val):shake=min(shake+val,1.5)


func shake_screen():
	offset.x=randi_range(-max_offset,max_offset)*pow(shake,1.25)
	offset.y=randi_range(-max_offset,max_offset)*pow(shake,1.25)
