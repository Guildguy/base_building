extends Node3D

@export var interaction_key := "E"
var player_body = null
var player_in_range := false
var is_animating := false
var is_open := false
#var popup_instance: Control

@onready var label := $Label3D
@onready var static_body := $StaticBody3D
@onready var closed := static_body.get_node("closed_chest")
@onready var half := static_body.get_node("half_chest")
@onready var open := static_body.get_node("open_chest")
@onready var area := $Area3D

func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	label.visible = false
	_show_only(closed)

	#var popup_scene = preload("res://scenes/base_building/base/inventory/inventory-popup.tscn")
	#popup_instance = popup_scene.instantiate()
#	get_tree().root.call_deferred("add_child", popup_instance)
#	popup_instance.hide()

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed(interaction_key):
		_interact()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		label.visible = true
	if body.name == "Player":
		player_in_range = true
		player_body = body

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		label.visible = false
		if is_open and not is_animating:
			_close_chest()

func _interact():
	if is_animating:
		return
	if not is_open:
		_open_trade()
	else:
		_close_chest()
	if player_body:
		player_body.open_trade_popup(self)

func _open_trade():
	is_animating = true
	is_open = true
	label.visible = false

	_show_only(half)
	await get_tree().create_timer(0.1).timeout
	_show_only(open)

	#popup_instance.show()
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	is_animating = false
	var player = get_tree().get_first_node_in_group("player")
	# OU use body passado no _body_entered, se preferir

	if player:
		player.open_trade_popup(self)
		

func _close_chest():
	is_animating = true
	is_open = false

	#popup_instance.hide()
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	_show_only(half)
	await get_tree().create_timer(0.1).timeout
	_show_only(closed)

	is_animating = false

func _show_only(target: Node):
	closed.visible = false
	half.visible = false
	open.visible = false
	target.visible = true
