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
func damage_modified_by_bonus(card_data,user,target):
	var bonus_actions = card_data.bonusactions.split(",")
	
	var bonus_modified_damage = 0
	for action in bonus_actions:
		bonus_modified_damage+=modify_by_action(action,card_data,user,target)
	return bonus_modified_damage



#action power by percent modifiers
func change_target_percent(value,target,card_data=null):
	var stre = 1
	if card_data!=null:
		stre = card_data.strength
	if value.contains("%"):
		value=target.base.stats.maxHp*(str2var(value.replace("%",""))/100.)
	else:value=str2var(value)*stre
	return round(value)


#action modifier logic is done here
func modify_by_action(action_name,card_data,user,target):
	var base = action_name.split(":")
	var changer = 1
	if base.size()!=1:
		changer = base[1]
	var action = base[0]
	match action:
		"return_damage_mult":
			return round(card_data.stored_damage*str2var(changer))
		"hurt_user_mult":
			if(user!=null):
				changer=change_target_percent(changer,target,card_data)
				Combat.hit_target(user,changer)
		"inflict_effect_on_target":
			if(user!=null&&target!=null):
				var effect_data = {
					"effect":changer.split("|")[0],"strength":change_target_percent(changer.split("|")[1],target),
					"duration_left":randi_range(1,str2var(changer.split("|")[2])),"target":target
				}
				var do=true
				#removes previous effect to ensure it doesnt stack two of the same type
				for effect_already in Combat.persisting_actions:
					if effect_already.target==target&&effect_already.effect==effect_data.effect:
						do=false;break
				if do:
					target.base.apply_effect(effect_data.effect)
					Combat.persisting_actions.append(effect_data)
		
	return 0
