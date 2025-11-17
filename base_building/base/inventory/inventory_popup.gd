extends Control

@onready var grid = $Panel/GridContainer
@onready var close_button = $Panel/Button

func _ready():
	hide()
	close_button.pressed.connect(_on_close_pressed)

	# Conecta o clique de cada slot
	for i in range(grid.get_child_count()):
		var slot = grid.get_child(i)
		# Como s_0.tscn é um Button, não precisa procurar subnó "Button"
		if slot is Button:
			slot.pressed.connect(_on_slot_pressed.bind(i))

func _on_close_pressed():
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_slot_pressed(index: int) -> void:
	print("Slot clicado:", index)
	# Aqui vai sua lógica de inventário (abrir tooltip, pegar item, etc.)

func _update_all_slots():
	for i in range(grid.get_child_count()):
		var slot = grid.get_child(i)
		if slot.has_node("Icon"):
			var icon = slot.get_node("Icon")
			# Exemplo: limpar ou atualizar o ícone
			icon.texture = null
