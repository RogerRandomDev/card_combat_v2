extends TileMap

@export   var map_w         = 80
@export   var map_h         = 50
@export   var iterations    = 20000
@export   var neighbors     = 4
@export   var ground_chance = 48
@export   var min_cave_size = 80


var caves = []
var unused_cell = Vector2.ZERO

var collision_shape = CollisionShape2D.new()
func _ready():
	randomize()
	collision_shape.shape=RectangleShape2D.new()
	collision_shape.shape.size=Vector2(8,8)
	generate()
	for ent in get_parent().get_node("Entities").get_children():
		var p = randi_range(0,caves.size()-1)
		ent.position = caves[p][randi_range(0,caves[p].size()-1)]*8
	get_parent().get_node("Player").position = unused_cell*Vector2i(8,8)
	#sets the region size for backing to the size of the map
	get_parent().get_node("ConvertedMap/Background").region_rect=Rect2(0,0,map_w*8,map_h*8)
	get_parent().get_node("ConvertedMap").mapsize=Vector2i(map_w,map_h)
	queue_free()
#utility
# the percent chance something happens
func chance(num):
	randomize()

	if randi() % 100 <= num:  return true
	else:                     return false

# Util.choose(["one", "two"])   returns one or two
func choose(choices):
	randomize()

	var rand_index = randi() % choices.size()
	return choices[rand_index]



func generate():
	clear()
	fill_roof()
	random_ground()
	dig_caves()
	get_caves()
	connect_caves()
	create_collision()
	convert_to_texture()

func fill_roof():
	for x in range(0, map_w):
		for y in range(0, map_h):
			set_cell(0,Vector2i(x,y),0,Vector2i(0,0),0)
			set_cell(1,Vector2i(x,y),1,Vector2i(0,0),0)

func random_ground():
	for x in range(1, map_w-1):
		for y in range(1, map_h-1):
			if chance(ground_chance):
				set_cell(0,Vector2i(x,y), -1,Vector2i(-1,-1),-1)
				


func dig_caves():
	randomize()
	for i in range(iterations):
		# Pick a random point with a 1-tile buffer within the map
		var x = floor(randf_range(1, map_w-1))
		var y = floor(randf_range(1, map_h-1))

		# if nearby cells > neighbors, make it a roof tile
		if check_nearby(x,y) > neighbors:
			set_cell(0,Vector2(x,y),0,Vector2i(0,0),0)

		# or make it the ground tile
		elif check_nearby(x,y) < neighbors:
			set_cell(0,Vector2(x,y), -1,Vector2i(-1,-1),-1)

func check_nearby(x, y):
	var count = 0
	if get_cell_source_id(0,Vector2i(x, y-1),false)   == 0:  count += 1
	if get_cell_source_id(0,Vector2i(x, y+1),false)   == 0:  count += 1
	if get_cell_source_id(0,Vector2i(x-1, y),false)   == 0:  count += 1
	if get_cell_source_id(0,Vector2i(x+1, y),false)   == 0:  count += 1
	if get_cell_source_id(0,Vector2i(x+1, y+1),false) == 0:  count += 1
	if get_cell_source_id(0,Vector2i(x+1, y-1),false) == 0:  count += 1
	if get_cell_source_id(0,Vector2i(x-1, y+1),false) == 0:  count += 1
	if get_cell_source_id(0,Vector2i(x-1, y-1),false) == 0:  count += 1
	return count
func get_caves():
	caves = []

	for x in range (0, map_w):
		for y in range (0, map_h):
			if get_cell_source_id(0,Vector2i(x, y),false) == -1:
				flood_fill(x,y)

	for cave in caves:
		for tile in cave:
			set_cell(0,tile, -1,Vector2i(-1,-1),-1)


func flood_fill(tilex, tiley):
	var cave = []
	var to_fill = [Vector2i(tilex, tiley)]
	while to_fill:
		var tile = to_fill.pop_back()

		if !cave.has(tile):
			cave.append(tile)
			set_cell(0,tile, 0,Vector2i(0,0),0)

			#check adjacent cells
			var north = Vector2i(tile.x, tile.y-1)
			var south = Vector2i(tile.x, tile.y+1)
			var east  = Vector2i(tile.x+1, tile.y)
			var west  = Vector2i(tile.x-1, tile.y)

			for dir in [north,south,east,west]:
				if get_cell_source_id(0,dir,false) == -1:
					if !to_fill.has(dir) and !cave.has(dir):
						to_fill.append(dir)

	if cave.size() >= min_cave_size:
		caves.append(cave)

func connect_caves():
	var prev_cave = null
	var tunnel_caves = caves.duplicate()

	for cave in tunnel_caves:
		if prev_cave:
			var new_point  = choose(cave)
			var prev_point = choose(prev_cave)

			# ensure not the same point
			if new_point != prev_point:
				create_tunnel(new_point, prev_point, cave)

		prev_cave = cave


# do a drunken walk from point1 to point2
func create_tunnel(point1, point2, cave):
	randomize()          # for randf
	var max_steps = 500  # so editor won't hang if walk fails
	var steps = 0
	var drunk_x = point2[0]
	var drunk_y = point2[1]

	while steps < max_steps and !cave.has(Vector2i(drunk_x, drunk_y)):
		steps += 1

		# set initial dir weights
		var n       = 1.0
		var s       = 1.0
		var e       = 1.0
		var w       = 1.0
		var weight  = 1

		# weight the random walk against edges
		if drunk_x < point1.x: # drunkard is left of point1
			e += weight
		elif drunk_x > point1.x: # drunkard is right of point1
			w += weight
		if drunk_y < point1.y: # drunkard is above point1
			s += weight
		elif drunk_y > point1.y: # drunkard is below point1
			n += weight

		# normalize probabilities so they form a range from 0 to 1
		var total = n + s + e + w
		n /= total
		s /= total
		e /= total
		w /= total

		var dx
		var dy

		# choose the direction
		var choice = randf()

		if 0 <= choice and choice < n:
			dx = 0
			dy = -1
		elif n <= choice and choice < (n+s):
			dx = 0
			dy = 1
		elif (n+s) <= choice and choice < (n+s+e):
			dx = 1
			dy = 0
		else:
			dx = -1
			dy = 0

		# ensure not to walk past edge of map
		if (2 < drunk_x + dx and drunk_x + dx < map_w-2) and \
			(2 < drunk_y + dy and drunk_y + dy < map_h-2):
			drunk_x += dx
			drunk_y += dy
			if get_cell_source_id(0,Vector2i(drunk_x, drunk_y),false) == 0:
				set_cell(0,Vector2i(drunk_x, drunk_y), -1,Vector2i(-1,-1),-1)

				# optional: make tunnel wider
				set_cell(0,Vector2i(drunk_x+1, drunk_y), -1,Vector2i(-1,-1),-1)
				set_cell(0,Vector2i(drunk_x+1, drunk_y+1), -1,Vector2i(-1,-1),-1)
				if Vector2i(unused_cell)==Vector2i(0,0)||randf_range(0.0,1.0)>0.975:
					unused_cell=Vector2i(drunk_x,drunk_y)



#converts to a texture to save on memory
func convert_to_texture():
	var tile = load("res://Textures/World/Tiles/CaveRock.png").get_image()
	var dat = tile.get_data()
	var n_dat=[]
	for x in dat.size():
		n_dat.append(dat[x])
		if x%3==0:n_dat.append(255)
	
	tile.create_from_data(8,8,false,Image.FORMAT_RGBA8,n_dat)
	var tex = ImageTexture.new()
	var img = Image.new()
	var size = Rect2(0,0,8,8)
	img.create(map_w*8,map_h*8,false,Image.FORMAT_RGBA8)
	
	img.premultiply_alpha()
	for x in map_w:for y in map_h:
		if get_cell_source_id(0,Vector2i(x,y),false)!=-1:
			
			img.blit_rect(tile,size,Vector2(x*8,y*8))
	tex.create_from_image(img)
	get_parent().get_node("ConvertedMap").texture = tex


var target_modifiers=[1,-1,map_w,-map_w]
#remakes collision for the sprite
func create_collision():
	var used = get_used_cells(0)
	var astar = AStar2D.new()
	for cell in used:
		get_parent().get_node("ConvertedMap").locked_motion.append(cell)
	for x in map_w:
		for y in map_h:
			if used.has(Vector2i(x,y)):continue
			astar.add_point(x+y*(map_w),Vector2(x,y))
	
	for x in map_w:for y in map_h:
		if used.has(Vector2i(x,y)):continue
		for w in range(0,3):for z in range(0,3):
			if (w+x-1>=map_w||w+x-1<0||y+z-1>=map_h||y+z-1<0||(w==1&&z==1)||
			w!=1&&z!=1
			):continue
			if used.has(Vector2i(x+w-1,y+z-1)):continue
			astar.connect_points(x+y*(map_w),(x+(w-1))+(y+(z-1))*(map_w),false)
	get_parent().get_node("ConvertedMap").astar = astar
