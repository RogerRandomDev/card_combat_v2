extends AnimationPlayer


var target_enemy=null
var trigger_person=null


var my_object=null
var object_size=Vector2.ONE

const particle_object=preload("res://shaders/explosions.tscn")

func load_object(path:String="",trigger_next:String="",extra_rot:float=0.0):
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



func fire_at_target(delay:float=0.0,speed:float=1.0):
	var tween:Tween=my_object.create_tween()
	tween.tween_interval(delay)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(my_object,"position",target_enemy.rect_global_position,speed)




#particle effect at the owner of the action
func particles_around_self(particle_shader:String,particle_count:int=12,lifetime:float=0.5,animated_frames:int=1):
	var particle_shower = particle_object.instantiate()
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
	var particle_shower = particle_object.instantiate()
	particle_shower.process_material=load("res://shaders/%s.tres"%particle_shader)
	particle_shower.global_position=target_enemy.rect_global_position
	particle_shower.amount=particle_count
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
	Combat.activate_actions()

#removes object
func remove_object():my_object.queue_free()

#frees self when it has completed its animation
func _on_animation_player_animation_finished(_anim_name):queue_free()
