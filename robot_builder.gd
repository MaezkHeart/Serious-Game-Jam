extends Node2D

signal robot_completed(robot_node: Node2D)

@export var snap_distance := 28.0

@export var body_head_socket_offset := Vector2(0, -48)
@export var head_neck_socket_offset := Vector2(0, 48)

@export var correct_head_name := "CorrectHead"

@onready var body_part: Sprite2D = $BodyPart
@onready var head_choices: Node2D = $HeadChoices
@onready var wire_minigame: WireMinigame = $WireMinigame
@onready var label: Label = $Label

var head_parts: Array[Sprite2D] = []
var starting_positions := {}

var dragging_head: Sprite2D = null
var drag_offset := Vector2.ZERO

var pending_head: Sprite2D = null
var builder_locked := false
var robot_is_finished := false


func _ready() -> void:
	label.text = "Choose the correct head and connect it to the body."

	body_part.centered = true

	for child in head_choices.get_children():
		if child is Sprite2D:
			var head := child as Sprite2D
			head.centered = true
			head_parts.append(head)
			starting_positions[head] = head.global_position

			var is_correct := head.name == correct_head_name
			head.set_meta("is_correct", is_correct)

	wire_minigame.wiring_completed.connect(_on_wiring_completed)


func _unhandled_input(event: InputEvent) -> void:
	if robot_is_finished:
		return

	if builder_locked:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_drag()
			else:
				_stop_drag()

	if event is InputEventMouseMotion:
		if dragging_head != null:
			dragging_head.global_position = get_global_mouse_position() + drag_offset


func _start_drag() -> void:
	var mouse_pos := get_global_mouse_position()

	dragging_head = _get_head_under_mouse(mouse_pos)

	if dragging_head != null:
		drag_offset = dragging_head.global_position - mouse_pos
		dragging_head.z_index = 10


func _stop_drag() -> void:
	if dragging_head == null:
		return

	dragging_head.z_index = 2

	_try_connect_head(dragging_head)

	dragging_head = null


func _get_head_under_mouse(mouse_pos: Vector2) -> Sprite2D:
	for head in head_parts:
		if head.visible and _mouse_is_over_sprite(head, mouse_pos):
			return head

	return null


func _mouse_is_over_sprite(sprite: Sprite2D, mouse_pos: Vector2) -> bool:
	if sprite.texture == null:
		return false

	var local_mouse_pos := sprite.to_local(mouse_pos)
	var texture_size := sprite.texture.get_size()

	var sprite_rect := Rect2(
		-texture_size / 2.0,
		texture_size
	)

	return sprite_rect.has_point(local_mouse_pos)


func _try_connect_head(head: Sprite2D) -> void:
	var body_socket_global := body_part.to_global(body_head_socket_offset)
	var head_socket_global := head.to_global(head_neck_socket_offset)

	var distance := body_socket_global.distance_to(head_socket_global)

	if distance <= snap_distance:
		_snap_head_to_body(head)

		pending_head = head
		builder_locked = true

		label.text = "Part connected. Now wire it together."

		print("Calling wire minigame")
		wire_minigame.start_minigame()
	else:
		label.text = "That part is not lined up with the body yet."


func _snap_head_to_body(head: Sprite2D) -> void:
	var body_socket_global := body_part.to_global(body_head_socket_offset)
	var head_socket_global := head.to_global(head_neck_socket_offset)

	var movement_needed := body_socket_global - head_socket_global
	head.global_position += movement_needed


func _on_wiring_completed(success: bool) -> void:
	if pending_head == null:
		builder_locked = false
		return

	if not success:
		label.text = "Wiring failed. Try connecting the part again."
		_return_head_to_start(pending_head)
		pending_head = null
		builder_locked = false
		return

	var part_is_correct: bool = pending_head.get_meta("is_correct")

	if part_is_correct:
		_finish_robot()
	else:
		label.text = "The wiring worked, but this is the wrong part."
		_return_head_to_start(pending_head)
		pending_head = null
		builder_locked = false


func _return_head_to_start(head: Sprite2D) -> void:
	if starting_positions.has(head):
		head.global_position = starting_positions[head]


func _finish_robot() -> void:
	robot_is_finished = true
	builder_locked = true

	label.text = "Robot complete!"

	var finished_robot := Node2D.new()
	finished_robot.name = "FinishedRobot"

	add_child(finished_robot)

	body_part.reparent(finished_robot, true)
	pending_head.reparent(finished_robot, true)

	for head in head_parts:
		if head != pending_head:
			head.visible = false

	finished_robot.set_meta("unit_type", "wind_up_robot")
	finished_robot.set_meta("damage", 10)
	finished_robot.set_meta("move_speed", 80)
	finished_robot.set_meta("lane_cost", 1)

	emit_signal("robot_completed", finished_robot)
