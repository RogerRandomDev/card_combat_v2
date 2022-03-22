extends AnimationPlayer


var target_enemy=null
var trigger_person=null


var pull_color = Color.RED
var data=null


var my_object=null
var object_size=Vector2.ONE

const particle_object=preload("res://shaders/explosions.tscn")

func load_object(path:String="",trigger_next:String="",extra_rot:float=0.0):
	if !valid_action():return
	if path=="":
		path="attackicons/"+data.Card.icon
	var object_visual = Sprite2D.new()
	object_visual.texture = load("res://Textures/%s.png"%path)
	get_parent().get_parent().add_child(object_visual)
	object_visual.position = trigger_person.rect_global_position
	my_object=object_visual
	my_object.scale=Vector2.ZERO
	var size_scalar=min(64/object_visual.texture.get_width(),64/object_visual.texture.get_height())
	object_size = Vector2(size_scalar,size_scalar)
	var tween:Tween=my_object.create_tween()
	tween.tween_property(my_object,"scale",object_size,0.25)
	my_object.look_at(target_enemy.rect_global_position)
	my_object.rotation+=(int(trigger_person.base.object_type=="Ally")*2-1)*extra_rot
	if trigger_person.base.object_type=="Enemy":my_object.rotation+=PI
	
	if trigger_next!="":call(trigger_next)

func load_moving_particles(particle_shader:String,particle_count:int=12,lifetime:float=0.5,color:Color=Color.WHITE):
	if !valid_action():return
	
	var particle_shower = particle_object.instantiate()
	get_parent().get_parent().add_child(particle_shower)
	if color.a==0.0:
		color = pull_color
	particle_shower.one_shot=false;
	particle_shower.explosiveness=0.0;
	particle_shower.process_material=load("res://shaders/%s.tres"%particle_shader)
	particle_shower.global_position=trigger_person.rect_global_position
	particle_shower.amount=particle_count
	particle_shower.material.particles_anim_h_frames=1
	particle_shower.lifetime=lifetime
	particle_shower.emitting=true
	
	particle_shower.scale=Vector2.ONE
	particle_shower.position = trigger_person.rect_global_position
	particle_shower.local_coords=false
	if trigger_person.base.object_type=="Enemy":particle_shower.rotation+=PI
	my_object=particle_shower
	particle_shower.self_modulate=color



func fire_at_target(delay:float=0.0,speed:float=1.0):
	if !valid_action():return
	var tween:Tween=my_object.create_tween()
	tween.tween_interval(delay)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(my_object,"position",target_enemy.rect_global_position,speed)




#particle effect at the owner of the action
func particles_around_self(particle_shader:String,particle_count:int=12,lifetime:float=0.5,animated_frames:int=1):
	if !valid_action():return
	var particle_shower = particle_object.instantiate()
	if particle_shader.contains("COL"):
		particle_shower.self_modulate=my_object.self_modulate
	particle_shower.process_material=load("res://shaders/%s.tres"%particle_shader)
	particle_shower.global_position=trigger_person.rect_global_position
	particle_shower.amount=particle_count
	particle_shower.lifetime=lifetime
	if animated_frames<=1:
		particle_shower.material.particles_animation=false
	particle_shower.material.particles_anim_h_frames=animated_frames
	particle_shower.emitting=true
	get_parent().get_parent().add_child(particle_shower)
	

#plays a particle shader for the action at the collision location
func particles_around_target(particle_shader:String="explosion0",particle_count:int=12,lifetime:float=0.5,animated_frames:int=1):
	if !valid_action():return
	var particle_shower = particle_object.instantiate()
	particle_shower.process_material=load("res://shaders/%s.tres"%particle_shader)
	particle_shower.global_position=target_enemy.rect_global_position
	particle_shower.amount=particle_count
	if particle_shader.contains("COL"):
		particle_shower.self_modulate=my_object.self_modulate
	if animated_frames<=1:
		particle_shower.material.particles_animation=false
	particle_shower.lifetime=lifetime
	particle_shower.material.particles_anim_h_frames=animated_frames
	particle_shower.emitting=true
	get_parent().get_parent().add_child(particle_shower)
	

#screen go jello
func shake_screen(strength:float=0.0):
	Combat.shake_camera(strength)

#triggers actions
func complete_action():
	if !valid_action():return
	var stored = Combat.action_list.duplicate(true)
	stored.erase(data)
	if trigger_person.base.object_type!="Ally":
		Combat.action_list=[data]
	Combat.activate_actions(trigger_person.base.object_type!="Ally")
	Combat.action_list=stored

#removes object
func remove_object():my_object.queue_free()

#frees self when it has completed its animation
func _on_animation_player_animation_finished(_anim_name):
	queue_free()


#makes sure it is a valid attack still
func valid_action():
	if !is_instance_valid(trigger_person)||!is_instance_valid(target_enemy):
		if my_object!=null:my_object.queue_free()
		queue_free()
		return false
	return true

#play sound effect
func play_sound(sound_name:String="attackmove",sound_ending:String="wav"):
	if sound_ending=="":sound_ending="wav"
	Sound.play_sound(sound_name,sound_ending)
