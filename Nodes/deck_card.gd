@tool
class_name deck_grid_card
extends Control

var card_name="Punch"
var card_attribute="Physical"
var card_color="#ffffff"
var attribute_icon = TextureRect.new()
var backing = TextureRect.new()
var name_of = Label.new()
func _ready():
	rect_min_size = Vector2(64,94)
	format_texture_rect(backing)
	format_texture_rect(attribute_icon)
	backing.rect_min_size = Vector2(64,94)
	backing.texture = load("res://Textures/Card.png")
	backing.modulate = Color(card_color)
	add_child(backing)
	
	name_of.theme = load("res://fonts/minicard_theme.tres")
	add_child(name_of)
	name_of.modulate = Color("#000000")
	name_of.text = card_name
	name_of.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	name_of.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	name_of.autowrap_mode = name_of.AUTOWRAP_WORD_SMART
	name_of.rect_size = backing.rect_size
	attribute_icon.rect_min_size = Vector2(16,16)
	attribute_icon.texture = load("res://Textures/attributes/aaa.png".replace("aaa",card_attribute))
	attribute_icon.rect_position = Vector2(42,6)
	add_child(attribute_icon)
	connect("mouse_entered",enter_self)
	connect("mouse_exited",exit_self)

#determine if mouse is inside it
var entered = false
func enter_self():entered = true
func exit_self():entered=false
#if mouse is inside and clicks, will remove it from the deck
func _input(_event):
	if !entered:return
	if Input.is_action_just_pressed("left_mouse"):
		if Data.current_deck.keys().has(card_name):
			Data.current_deck[card_name]-=1
			if Data.current_deck[card_name]==0:Data.current_deck.erase(card_name)
		self.queue_free()
		get_parent().get_parent().get_parent().get_parent().get_parent().call_deferred('update_counter',-1)

func format_texture_rect(item):
	item.ignore_texture_size=true
	item.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
