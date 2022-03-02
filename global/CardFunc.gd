extends Node

func _ready():randomize()

func get_output_values(card_data):
	return round(card_data.strength+randf_range(-card_data.variance,card_data.variance))
func type(input,check):
	return input.split(",").has(check)



#builds card data for the combat system
func build_full_card(card_data):
	var output_data = card_data
	if(!output_data.has("bonusactions")):output_data["bonusactions"]=""
	if(!output_data.has("description")):output_data["description"]="ERROR"
	if(!output_data.has("attribute")):output_data["attribute"]="Physical"
	if(!output_data.has("name")):output_data["name"]="Punch"
	if(!output_data.has("type")):output_data["type"]="Harmful"
	if(!output_data.has("delay")):output_data["delay"]=0
	if(!output_data.has("stored_damage")):output_data["stored_damage"]=0
	return output_data


#damage bonus modifiers are done here
func damage_modified_by_bonus(card_data,target,user):

	var bonus_actions = card_data.bonusactions.split(",")
	
	var bonus_modified_damage = 0
	for action in bonus_actions:
		bonus_modified_damage+=modify_by_action(action,card_data,target,user)
	return bonus_modified_damage


#action modifier logic is done here
func modify_by_action(action_name,card_data,target,user):
	var base = action_name.split(":")
	var changer = 1
	if base.size()!=1:
		changer = str2var(base[1])
	var action = base[0]
	match action:
		"return_damage_mult":
			return round(abs(card_data.stored_damage)*changer)
		"persist_effect":
			Combat.persisting_actions.append({target:persisting_action_from_card(card_data,changer)})
			target.base.inflict_effect(card_data.attribute)
		"hurt_user_mult":
			Combat.hit_target(user,int(card_data.strength*float(changer)))
	return 0



#generates the persisting card data
func persisting_action_from_card(data,persist_rate):
	var return_data = {}
	return_data.name=data.attribute
	return_data.attribute = data.attribute
	return_data.damage_value = data.strength
	return_data.persisting_turns=persist_rate
	return return_data
