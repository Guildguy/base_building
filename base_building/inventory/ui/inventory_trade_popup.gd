extends Control

@onready var player_inv_view = $Panel/MarginContainer/HBoxContainer/inventory_player
@onready var chest_inv_view = $Panel/MarginContainer/HBoxContainer/inventory_chest
@onready var btn_to_chest = $Panel/MarginContainer/HBoxContainer/arrow/Button
@onready var btn_to_player = $Panel/MarginContainer/HBoxContainer/arrow/Button2

var selected_slot_index: int = -1
var selected_origin: String = ""

var player_ref = null
var chest_ref = null

func _ready():
	hide()
	player_inv_view.visible = false
	chest_inv_view.visible = false
	
	if player_inv_view.has_signal("slot_clicked"):
		player_inv_view.connect("slot_clicked", _on_inventory_slot_clicked)
	if chest_inv_view.has_signal("slot_clicked"):
		chest_inv_view.connect("slot_clicked", _on_inventory_slot_clicked)
		
	btn_to_chest.pressed.connect(_transfer_to_chest)
	btn_to_player.pressed.connect(_transfer_to_player)

func open_trade(player, chest):
	player_ref = player
	chest_ref = chest
	
	player_inv_view.setup("player")
	chest_inv_view.setup("chest")
	
	show()
	player_ref.disable_movement(true)
	player_inv_view.focus_first_slot()

func close_trade():
	hide()
	selected_slot_index = -1
	selected_origin = ""
	
	if player_ref:
		player_ref.disable_movement(false)
	if chest_ref and chest_ref.has_method("_close_chest"):
		chest_ref._close_chest()

func _on_close_pressed():
	close_trade()

func _on_inventory_slot_clicked(index: int, type: String):
	print("Slot selecionado: ", index, " | Origem: ", type)
	selected_slot_index = index
	selected_origin = type

func _transfer_to_chest():
	if selected_origin == "player" and selected_slot_index != -1:
		print("Transferind o item do slot ", selected_slot_index, " para o baú")
	else:
		print("Selecione um item do player primeiro.")

func _transfer_to_player():
	if selected_origin == "chest" and selected_slot_index != -1:
		print("Transferindo item do slot ", selected_slot_index, " para o player")
	else:
		print("Selecione um item do baú primeiro.")
