@tool
class_name card_object 
extends Control 

var card_data = {
	"Name":"Punch",
	"Description":"Punch Hard",
	"Strength":10,
	"Variance":5,
	"Attribute":"Physical",
	"Type":'Harmful'
}


#sets up the back texture
var texture = preload("res://Textures/Card.png")
var card_backing = TextureRect.new()
func _ready():
	card_backing.texture=texture
	card_backing.ignore_texture_size=true
	card_backing.rect_size = Vector2(64,94)
	card_backing.rect_position -= Vector2(32,47)
	add_child(card_backing)
	connect("mouse_entered",hover_over)



#selects the new target after using a card
func get_next_target(_a):
	if card_data.Type=="Harmful":
		Combat.active_target="Enemy"
		return "Enemy"
	else:
		Combat.active_target="Ally"
		return "Ally"

func hover_over():
	var success = Combat.set_hovered(self,"Card")
	if success:
		var tween:Tween=card_backing.create_tween()
		tween.tween_property(card_backing,"rect_global_position",Vector2(512-32,300-47),0.125)
		

func stop_hovering():
	pass



#data value types
func harmful():return card_data.Type=="Harmful"


#select and deselect
func select():return
func deselect():return
