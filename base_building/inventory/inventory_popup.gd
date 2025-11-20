extends Control

@onready var grid = $Panel/GridContainer

signal slot_clicked(index: int, type: String)

var inventory_owner: String = "player"

func _ready():
	for i in range(grid.get_child_count()):
		var slot = grid.get_child(i)
		if slot is Button:
			if slot.pressed.is_connected(_on_slot_pressed):
				slot.pressed.disconnect(_on_slot_pressed)
			slot.pressed.connect(_on_slot_pressed.bind(i))

func setup(type: String):
	inventory_owner = type
	show()

func focus_first_slot():
	if grid.get_child_count() > 0:
		var slot = grid.get_child(0)
		if slot is Button:
			slot.grab_focus()

func _on_slot_pressed(index: int) -> void:
	emit_signal("slot_clicked", index, inventory_owner)

func update_slots(_data := []):
	for i in range(grid.get_child_count()):
		var slot = grid.get_child(i)
		if slot.has_node("Icon"):
			slot.get_node("Icon").texture = null
