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
#attribute icon
var attribute_icon = TextureRect.new()

func _ready():
	randomize()
	
	card_backing.texture=texture
	card_backing.ignore_texture_size=true
	card_backing.rect_size = Vector2(64,94)
	card_backing.rect_position -= Vector2(32,47)
	add_child(card_backing)
	card_backing.add_child(name_of)
	rect_min_size=Vector2(64,32)
	set_text_format(name_of)
	attribute_icon.rect_min_size = Vector2(16,16)
	attribute_icon.texture = load("res://Textures/attributes/%s.png"%card_data.attribute.split(",")[0])
	
	card_backing.add_child(attribute_icon)
	attribute_icon.rect_position = Vector2(40,6)
	connect("mouse_entered",hover_over)
	connect("mouse_exited",stop_hover)
	set_data(Data.get_card_from_deck())
func remove_listeners():
	disconnect("mouse_entered",hover_over)
	disconnect("mouse_exited",stop_hover)

func set_text_format(ob,scale_rate=1.5):
	ob.rect_size = Vector2(56,84)*scale_rate
	ob.rect_position=Vector2(4,4)
	ob.modulate=Color(0,0,0,1)
	ob.rect_scale=Vector2(1,1)/scale_rate
	ob.text ="hello there"
	ob.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	ob.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	ob.autowrap_mode=name_of.AUTOWRAP_WORD_SMART
	
	
	mouse_filter=Control.MOUSE_FILTER_PASS
	

func flipping_card():
	attribute_icon.visible=false
	modulate = card_backing.self_modulate
	card_backing.remove_child(attribute_icon)
	add_child(attribute_icon)
	card_backing.self_modulate = Color("#ffffff")
	

#selects the new target after using a card
func get_next_target(_a):
	if card_data.type=="Harmful":
		Combat.active_target="Enemy"
		return "Enemy"
	else:
		Combat.active_target="Ally"
		return "Ally"

func hover_over():
	if "storestack"==get_parent().name||"cardstack"==get_parent().name:return
	get_parent().get_parent().call_deferred('show_card_description',card_data.description)
	var success = Combat.set_hovered(self,"Card")
	Combat.set_deferred('hovering_card',self)
	if success:
		var tween:Tween=card_backing.create_tween()
		tween.tween_property(card_backing,"rect_position",Vector2(-32,-77),0.125)

func stop_hover():
	get_parent().get_parent().call_deferred('show_card_description',"")
	if Combat.hovering_card==self||Combat.active_hover==self:
		stop_hovering()
		reset()
		Combat.active_hover=null
		Combat.hovering_card=null


func stop_hovering():
	Combat.hovering_card=null
	if Combat.current_target_type=="Card"&&get_parent().name=="CardList":
		get_parent().get_parent().show_card_description(card_data.description)
		var tween:Tween=card_backing.create_tween()
		tween.tween_property(card_backing,"rect_position",Vector2(-32,-47),0.125)

func reset():
	var tween:Tween=card_backing.create_tween()
	tween.tween_property(card_backing,"rect_position",Vector2(-32,-47),0.125)
	tween.parallel().tween_property(self,'rect_scale',Vector2.ONE,0.125)


#data value types
func harmful():return card_data.type.split(",").has("Harmful")
func heals():return card_data.type.split(",").has("Healing")

#select and deselect
func select():return
func deselect():return


#hide and show the content
func hide_content():
	name_of.visible=false
func show_content():
	name_of.visible=true

#gets the output strength of the action
func get_output_value():
	return round(card_data.strength+randf_range(-card_data.variance,card_data.variance))


#changes the card data
func set_data(data):
	card_data=data
	name_of.text=data.name
	if !data.has("delay"):card_data.delay = 0
	card_backing.self_modulate = Color(data.color)
	attribute_icon.texture = load("res://Textures/attributes/%s.png"%card_data.attribute.split(",")[0])
