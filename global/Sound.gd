extends Node


var cur_music = null
var last_music=null

#plays default song
func _ready():load_song("song_1")


#loads new song to play and removes last song
func load_song(song_name):
	var tween:Tween=create_tween()
	if cur_music!=null:tween.tween_property(cur_music,"volume_db",-40,0.5)
	last_music=cur_music
	cur_music=AudioStreamPlayer.new()
	cur_music.stream=load("res://Audio/Songs/%s.mp3"%song_name)
	add_child(cur_music)
	cur_music.volume_db=-40
	cur_music.play()
	tween.parallel().tween_property(cur_music,"volume_db",0.0,0.5)
	tween.tween_callback(remove_last_song)
	
#removes prior song
func remove_last_song():if last_music!=null:
	last_music.queue_free();last_music=null


#plays sound and then removes it
func play_sound(sound_name,extension="wav"):
	if extension=="":extension="wav"
	var n_sound = AudioStreamPlayer.new()
	n_sound.connect("finished",remove_sound,[n_sound])
	n_sound.stream=load("res://Audio/sfx/%s.%s"%[sound_name,extension])
	add_child(n_sound)
	n_sound.play()

func remove_sound(obj):
	obj.disconnect('finished',remove_sound)
	obj.queue_free()
