@tool
extends Path2D

## Creates an polygon collider that follows the enemy path and stops turret placement
## Then removes polygon overlap and creates thick line to visualize collider

# TEMPORARY SOLUTION : BREAKS IF NOT BEZIER, CANNOT DO CLOSED LOOPS,
# LOOPS CANNOT COME TOO CLOSE TO EACH OTHER -> POINTS GENERATING BEHIND SECOND LOOP

# TODO : check for what should be removed p11 or p22 (entry or exit) (?)
# TODO : Fix ghost segment at beginning of collider
# TODO : Fix curve loops intersecting with each other sometimes removing parts of the collider

signal generation_activated
signal path_ready

const TEST_SPRITE = preload("uid://c23oi54sjkxc2")

@export var is_polygon_gen_active: bool :
	set(value):
		if value == true:
			generation_activated.emit()
			if Engine.is_editor_hint():
				is_polygon_gen_active = false
			else:
				is_polygon_gen_active = value

@export var collider_width = 60.0
@export var path_width = 30.0

@onready var collision_polygon: CollisionPolygon2D = $NoPlacementZone/CollisionPolygon2D
@onready var visual_line: Line2D = $PathLine


func _process(_delta: float) -> void:
	if is_polygon_gen_active == false and not Engine.is_editor_hint():
		is_polygon_gen_active = true
		path_ready.emit()

func generate_path_block():
	
	var collider_shape : PackedVector2Array = generate_polygon(curve.tessellate())
	var intersections : Array = find_intersections(collider_shape)
	var cleaned_polygon = remove_overlap(collider_shape, intersections)
	#print("first : " + str(collider_shape[point]) + " last : " + str(collider_shape[-point]))
	
	collision_polygon.polygon = cleaned_polygon
	
	visual_line.width = path_width
	visual_line.points = curve.tessellate()


func generate_polygon(path) -> PackedVector2Array:
	var direction_of_next_point : Vector2
	var collider_shape : PackedVector2Array
	collider_shape.resize(path.size() * 2)
	
	## For every point in the curve, we check the direction of the next point
	## (except for last point which keeps the same orientation as last point)
	## we then set 2 points on each side of the curve perpendicular to the direction to next point
	## we then feed one of these points to the beginning of the Vector2Array and one at the end
	for point in path.size():
		if not point == path.size() - 1:
			direction_of_next_point = Vector2.from_angle(path[point].angle_to_point(path[point + 1]))
		
		collider_shape[point] = Vector2.ZERO
		collider_shape[point].x = (
				path[point].x +
				Vector2(direction_of_next_point.rotated(PI / 2)
				* collider_width).x
				)
		collider_shape[point].y = (
				path[point].y +
				Vector2(direction_of_next_point.rotated(PI / 2)
				* collider_width).y
				)
		collider_shape[-(point + 1)] = Vector2.ZERO
		collider_shape[-(point + 1)].x = (
				path[point].x + 
				Vector2(direction_of_next_point.rotated(-PI / 2)
				* collider_width).x
				)
		collider_shape[-(point + 1)].y = (
				path[point].y + 
				Vector2(direction_of_next_point.rotated(-PI / 2)
				* collider_width).y
				)
	
	#for point in collider_shape.size():
		#var new_label = Label.new()
		#add_child(new_label)
		#new_label.position = collider_shape[point]
		#new_label.position.y -= 30
		#new_label.text = str(point)
	return collider_shape


func find_intersections(points) -> Array :
	
	var p11 : Vector2
	var p12 : Vector2
	var p21 : Vector2
	var p22 : Vector2
	
	var checked_segments : Array
	var intersect_at : Array
	
	## Comparing each segment with each other
	for i in points.size():
		p11 = points[i]
		p12 = points[i + 1] if i + 1 < points.size() else points[0]
		for j in points.size():
			
			if j == i:
				continue
			
			p21 = points[j]
			p22 = points[j + 1] if j + 1 < points.size() else points[0]
			
			var intersect = Geometry2D.segment_intersects_segment(p11, p12, p21, p22)
			
			## Checking if intersection is not at junctions, that intersection hasn't been found before
			## and that intersection isn't inside polygon
			if (
					intersect
					and not intersect == p11
					and not intersect == p12
					and not checked_segments.has([j, i])
					#and Geometry2D.is_polygon_clockwise(points.slice(i, j + 1) if i < j else points.slice(j, i + 1))# not necessary
			):
				#print("intersection between : " + str(i) + " : " + str(j))
				
				##Checking for holes in polygon and only returning first intersection
				var is_within_poly = false
				for x in checked_segments.size():
					
					var current_checked_seg = range(checked_segments[x][0], checked_segments[x][1] + 1)
					var current_seg = range(i, j + 1)
					if current_seg.is_empty(): # temporary until begin bug fixed
						current_seg.append(0)
					
					if (
							current_checked_seg[0] < current_seg[0]
							and current_checked_seg[-1] > current_seg[-1]
					):
						checked_segments.append([i, j])
						is_within_poly = true
						break
					elif (
							current_checked_seg[0] > current_seg[0]
							and current_checked_seg[-1] < current_seg[-1]
					):
						checked_segments.remove_at(x)
						break
				
				if is_within_poly == false:
					checked_segments.append([i, j])
					intersect_at.append([i, intersect, j + 1])
				

	
	
	## VISUAL STUFF FOR DEBUG
	#for i in intersect_at.size():
		#var sprite1 = TEST_SPRITE.instantiate()
		#sprite1.position = intersect_at[i][1]
		#add_child(sprite1)
	#
	#for i in intersect_at.size():
		#if Geometry2D.is_point_in_polygon(points[intersect_at[i][0]], points):
			#var sprite1 = TEST_SPRITE.instantiate()
			#sprite1.position = points[intersect_at[i][0]]
			#sprite1.modulate = Color(0.878, 0.0, 0.824, 0.49)
			#add_child(sprite1)
	#
	#for i in intersect_at.size():
		#if Geometry2D.is_point_in_polygon(points[intersect_at[i][2]], points):
			#var sprite1 = TEST_SPRITE.instantiate()
			#sprite1.position = points[intersect_at[i][2]]
			#sprite1.modulate = Color(0.878, 0.0, 0.824, 0.49)
			#add_child(sprite1)
	#
	return intersect_at


func remove_overlap(polygon, intersections):
	
	## Iterating through intersections in reverse order
	for i in range(intersections.size() -1 , -1, -1):
		var points_to_remove = range(intersections[i][0] + 1, intersections[i][2])
		for j in range(points_to_remove.size() - 1, -1, -1):
			if polygon.size() - 1 > points_to_remove[j]:
				polygon.remove_at(points_to_remove[j])
		
		
		polygon.insert(intersections[i][0] + 1, intersections[i][1])
	return polygon
