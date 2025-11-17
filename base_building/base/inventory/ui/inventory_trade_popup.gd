extends Control

@onready var player_inv = $HBoxContainer/chest/chest
@onready var chest_inv = $HBoxContainer/inventory/inventory
@onready var btn_to_chest = $HBoxContainer/arrow/Button
@onready var btn_to_player = $HBoxContainer/arrow/Button2
@onready var close_button = $close

var player_ref = null
var chest_ref = null

func _ready():
	hide()
	close_button.pressed.connect(_on_close_pressed)
	btn_to_chest.pressed.connect(_transfer_to_chest)
	btn_to_player.pressed.connect(_transfer_to_player)

func open_trade(player, chest):
	player_ref = player
	chest_ref = chest
	player_ref.disable_movement(true)
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_close_pressed():
	hide()
	if player_ref:
		player_ref.disable_movement(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _transfer_to_chest():
	print("Transferindo item do player para o baú")
	# futuramente: lógica de mover item selecionado

func _transfer_to_player():
	print("Transferindo item do baú para o player")
	# futuramente: lógica de mover item selecionado
