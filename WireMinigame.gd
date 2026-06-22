extends CanvasLayer

class_name WireMinigame

signal wiring_completed(success: bool)

@export var max_mistakes := 3
@export var drop_distance := 55.0
@export var wire_thickness := 6.0

var panel: Panel
var title_label: Label
var feedback_label: Label
var cancel_button: Button

var left_buttons: Array[Button] = []
var right_buttons: Array[Button] = []

var wire_ids := ["red", "green", "blue"]

var selected_wire_id := ""
var selected_wire_button: Button = null
var current_drag_line: Line2D = null

var completed_connections := {}
var permanent_lines := {}

var mistakes := 0


func _ready() -> void:
	layer = 100
	_build_ui()
	hide()


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if selected_wire_id == "":
		return

	if event is InputEventMouseMotion:
		_update_drag_line(event.position)

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_finish_drag(event.position)


func _build_ui() -> void:
	panel = Panel.new()
	panel.name = "Panel"
	panel.position = Vector2(50, 150)
	panel.size = Vector2(430, 370)
	add_child(panel)

	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "Connect the wires"
	title_label.position = Vector2(40, 20)
	title_label.size = Vector2(330, 40)
	panel.add_child(title_label)

	feedback_label = Label.new()
	feedback_label.name = "FeedbackLabel"
	feedback_label.text = "Drag each wire to the matching socket."
	feedback_label.position = Vector2(40, 295)
	feedback_label.size = Vector2(240, 60)
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(feedback_label)

	var left_wire_1 := _make_button("LeftWire1", Vector2(40, 85))
	var left_wire_2 := _make_button("LeftWire2", Vector2(40, 155))
	var left_wire_3 := _make_button("LeftWire3", Vector2(40, 225))

	var right_socket_1 := _make_button("RightSocket1", Vector2(265, 85))
	var right_socket_2 := _make_button("RightSocket2", Vector2(235, 155))
	var right_socket_3 := _make_button("RightSocket3", Vector2(280, 225))

	left_buttons = [
		left_wire_1,
		left_wire_2,
		left_wire_3
	]

	right_buttons = [
		right_socket_1,
		right_socket_2,
		right_socket_3
	]

	for button in left_buttons:
		button.button_down.connect(_on_left_wire_button_down.bind(button))

	cancel_button = _make_button("CancelButton", Vector2(315, 315))
	cancel_button.size = Vector2(90, 35)
	cancel_button.text = "Cancel"
	cancel_button.pressed.connect(_fail_minigame)


func _make_button(button_name: String, button_position: Vector2) -> Button:
	var button := Button.new()
	button.name = button_name
	button.position = button_position
	button.size = Vector2(130, 40)
	button.text = button_name
	panel.add_child(button)
	return button


func start_minigame() -> void:
	print("Wire minigame started")

	show()
	panel.show()

	_clear_all_lines()

	selected_wire_id = ""
	selected_wire_button = null
	completed_connections.clear()
	permanent_lines.clear()
	mistakes = 0

	title_label.text = "Connect the wires"
	feedback_label.text = "Drag each wire to the matching socket."

	var right_order := _get_non_straight_socket_order()

	for i in range(left_buttons.size()):
		var wire_id: String = wire_ids[i]
		var button := left_buttons[i]

		button.disabled = false
		button.show()
		button.text = _get_wire_display_name(wire_id) + " Wire"
		button.set_meta("wire_id", wire_id)

	for i in range(right_buttons.size()):
		var wire_id: String = right_order[i]
		var button := right_buttons[i]

		button.disabled = false
		button.show()
		button.text = _get_wire_display_name(wire_id) + " Socket"
		button.set_meta("wire_id", wire_id)


func _get_non_straight_socket_order() -> Array:
	var order := wire_ids.duplicate()
	order.shuffle()

	# This prevents Red from being across from Red,
	# Green from being across from Green, etc.
	while _order_has_straight_match(order):
		order.shuffle()

	return order


func _order_has_straight_match(order: Array) -> bool:
	for i in range(order.size()):
		if order[i] == wire_ids[i]:
			return true

	return false


func _on_left_wire_button_down(button: Button) -> void:
	if button.disabled:
		return

	var wire_id: String = button.get_meta("wire_id")

	if completed_connections.has(wire_id):
		return

	selected_wire_id = wire_id
	selected_wire_button = button

	feedback_label.text = "Dragging " + _get_wire_display_name(wire_id) + " wire."

	_create_drag_line()


func _create_drag_line() -> void:
	if current_drag_line != null:
		current_drag_line.queue_free()

	current_drag_line = Line2D.new()
	current_drag_line.width = wire_thickness
	current_drag_line.default_color = _get_wire_color(selected_wire_id)
	current_drag_line.z_index = 200

	add_child(current_drag_line)

	var start_pos := _get_left_wire_anchor(selected_wire_button)
	var mouse_pos := get_viewport().get_mouse_position()

	current_drag_line.points = [
		start_pos,
		mouse_pos
	]


func _update_drag_line(mouse_pos: Vector2) -> void:
	if current_drag_line == null:
		return

	var start_pos := _get_left_wire_anchor(selected_wire_button)

	current_drag_line.points = [
		start_pos,
		mouse_pos
	]


func _finish_drag(mouse_pos: Vector2) -> void:
	var socket := _get_socket_at_position(mouse_pos)

	if socket == null:
		feedback_label.text = "Dropped too far from a socket. Try again."
		_clear_current_drag()
		return

	var socket_wire_id: String = socket.get_meta("wire_id")

	if selected_wire_id == socket_wire_id:
		_complete_connection(selected_wire_id, selected_wire_button, socket)
	else:
		mistakes += 1
		feedback_label.text = "Wrong socket. Mistakes: " + str(mistakes) + "/" + str(max_mistakes)
		_clear_current_drag()

		if mistakes >= max_mistakes:
			_fail_minigame()


func _get_socket_at_position(mouse_pos: Vector2) -> Button:
	for socket in right_buttons:
		if socket.disabled:
			continue

		var socket_anchor := _get_right_socket_anchor(socket)
		var distance := mouse_pos.distance_to(socket_anchor)

		if distance <= drop_distance:
			return socket

		var socket_rect := Rect2(socket.global_position, socket.size)
		if socket_rect.has_point(mouse_pos):
			return socket

	return null


func _complete_connection(wire_id: String, left_button: Button, right_button: Button) -> void:
	completed_connections[wire_id] = true

	left_button.disabled = true
	right_button.disabled = true

	feedback_label.text = _get_wire_display_name(wire_id) + " wire connected."

	if current_drag_line != null:
		current_drag_line.points = [
			_get_left_wire_anchor(left_button),
			_get_right_socket_anchor(right_button)
		]

		permanent_lines[wire_id] = current_drag_line
		current_drag_line = null

	selected_wire_id = ""
	selected_wire_button = null

	if completed_connections.size() >= wire_ids.size():
		_win_minigame()


func _clear_current_drag() -> void:
	if current_drag_line != null:
		current_drag_line.queue_free()
		current_drag_line = null

	selected_wire_id = ""
	selected_wire_button = null


func _clear_all_lines() -> void:
	if current_drag_line != null:
		current_drag_line.queue_free()
		current_drag_line = null

	for line in permanent_lines.values():
		if is_instance_valid(line):
			line.queue_free()

	permanent_lines.clear()


func _get_left_wire_anchor(button: Button) -> Vector2:
	return button.global_position + Vector2(button.size.x, button.size.y / 2.0)


func _get_right_socket_anchor(button: Button) -> Vector2:
	return button.global_position + Vector2(0, button.size.y / 2.0)


func _win_minigame() -> void:
	hide()
	emit_signal("wiring_completed", true)


func _fail_minigame() -> void:
	hide()
	emit_signal("wiring_completed", false)


func _get_wire_display_name(wire_id: String) -> String:
	match wire_id:
		"red":
			return "Red"
		"green":
			return "Green"
		"blue":
			return "Blue"
		_:
			return "Unknown"


func _get_wire_color(wire_id: String) -> Color:
	match wire_id:
		"red":
			return Color(1.0, 0.1, 0.1)
		"green":
			return Color(0.1, 0.9, 0.2)
		"blue":
			return Color(0.2, 0.45, 1.0)
		_:
			return Color.WHITE
