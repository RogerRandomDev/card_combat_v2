@tool
class_name card_object 
extends Control 
const italian_chef="SPAGHETTI"


var card_data = {
	"name":"Punch",
	"description":"Punch Hard",
	"strength":10,
	"variance":5,
	"attribute":"Physical",
	"type":'Harmful',
	"color":"#ffffff"
}

#sets up the back texture
var texture = preload("res://Textures/Card.png")
var card_backing = TextureRect.new()
#the text for it
var name_of=Label.new()
var description=Label.new()

func _ready():
	randomize()
	
	card_backing.texture=texture
	card_backing.ignore_texture_size=true
	card_backing.rect_size = Vector2(64,94)
	card_backing.rect_position -= Vector2(32,47)
	add_child(card_backing)
	card_backing.add_child(name_of)
	card_backing.add_child(description)
	rect_min_size=Vector2(64,32)
	set_text_format(name_of)
	set_text_format(description)
	description.rect_position+=Vector2(0,12)
	connect("mouse_entered",hover_over)
	set_data(Data.get_card_from_deck())

func set_text_format(ob):
	ob.rect_size = Vector2(56,86)
	ob.rect_position=Vector2(4,4)
	ob.modulate=Color(0,0,0,1)
	ob.text ="hello there"
	ob.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	ob.autowrap_mode=name_of.AUTOWRAP_WORD_SMART
	
	
	mouse_filter=Control.MOUSE_FILTER_PASS
	



#selects the new target after using a card
func get_next_target(_a):
	if card_data.type=="Harmful":
		Combat.active_target="Enemy"
		return "Enemy"
	else:
		Combat.active_target="Ally"
		return "Ally"

func hover_over():
	var success = Combat.set_hovered(self,"Card")
	Combat.set_deferred('hovering_card',self)
	if success:
		var tween:Tween=card_backing.create_tween()
		tween.tween_property(card_backing,"rect_position",Vector2(-32,-77),0.125)

func stop_hovering():
	Combat.hovering_card=null
	if Combat.current_target_type=="Card":
		var tween:Tween=card_backing.create_tween()
		tween.tween_property(card_backing,"rect_position",Vector2(-32,-47),0.125)

func reset():
	var tween:Tween=card_backing.create_tween()
	tween.tween_property(card_backing,"rect_position",Vector2(-32,-47),0.125)
	tween.parallel().tween_property(self,'rect_scale',Vector2.ONE,0.125)


#data value types
func harmful():return card_data.type=="Harmful"
func heals():return card_data.type=="Healing"

#select and deselect
func select():return
func deselect():return


#hide and show the content
func hide_content():
	name_of.visible=false
	description.visible=false
func show_content():
	name_of.visible=true
	description.visible=true


#gets the output strength of the action
func get_output_value():
	return card_data.strength+randi_range(-card_data.variance,card_data.variance)


#changes the card data
func set_data(data):
	card_data=data
	name_of.text=data.name
	description.text = data.description
	modulate = Color(data.color)
