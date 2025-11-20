extends CharacterBody3D

@export var speed: float = 5.0
@export var gravity: float = 9.8

var can_move := true
var input_enabled := true

@onready var sprite: AnimatedSprite3D = get_node_or_null("AnimatedSprite3D")
@onready var inventory_popup = get_node_or_null("CanvasLayer/InventoryPopup")
@onready var trade_popup = get_node_or_null("CanvasLayer/InventoryTradePopup")

var body_ref = null
var near_npc: Node = null

func set_near_npc(npc: Node) -> void:
	near_npc = npc

func clear_near_npc() -> void:
	near_npc = null

func set_input_enabled(enabled: bool) -> void:
	input_enabled = enabled

func _ready():
	add_to_group("player")
	# initialize inventory/trade UI if present
	if inventory_popup:
		inventory_popup.visible = false
	if trade_popup:
		trade_popup.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# connect Area3D signals if the node exists
	if has_node("Area3D"):
		$Area3D.body_entered.connect(_on_body_entered)
		$Area3D.body_exited.connect(_on_body_exited)

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	if Input.is_action_just_pressed("inventory"):
		if trade_popup and trade_popup.visible:
			if trade_popup.has_method("close_trade"):
				trade_popup.close_trade()
			return

		if inventory_popup:
			if inventory_popup.visible:
				inventory_popup.hide()
				can_move = true
			else:
				inventory_popup.show()
				if inventory_popup.has_method("focus_first_slot"):
					inventory_popup.focus_first_slot()
				can_move = false

func _unhandled_input(event):
	if event.is_action_pressed("Interact") and input_enabled:
		if near_npc != null:
			# disable input while interacting
			input_enabled = false
			if near_npc.has_method("start_dialogue"):
				near_npc.start_dialogue()
			else:
				print("NPC não tem start_dialogue()")

func _physics_process(delta: float) -> void:
	# If input is disabled for dialogue or inventory movement locked, only apply gravity when in air
	if not input_enabled or not can_move:
		if not is_on_floor():
			velocity.y -= gravity * delta
			move_and_slide()
		return

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := Vector3.ZERO
	var camera := get_viewport().get_camera_3d()

	if camera and input_dir.length() > 0:
		var cam_transform := camera.global_transform
		var cam_right := cam_transform.basis.x
		var cam_forward := -cam_transform.basis.z
		cam_right.y = 0
		cam_forward.y = 0
		cam_right = cam_right.normalized()
		cam_forward = cam_forward.normalized()
		direction = (cam_right * input_dir.x) + (cam_forward * -input_dir.y)
		direction = direction.normalized()

	# Sprite animation handling (if an AnimatedSprite3D exists)
	if sprite:
		var desired_anim := "idle"
		if input_dir.length() > 0:
			if abs(input_dir.x) >= abs(input_dir.y):
				if input_dir.x < 0:
					desired_anim = "move_left"
				elif input_dir.x > 0:
					desired_anim = "move_right"
			else:
				if input_dir.y < 0:
					desired_anim = "move_right"
				elif input_dir.y > 0:
					desired_anim = "move_left"

		if sprite.animation != desired_anim:
			sprite.play(desired_anim)

	# Vertical movement / gravity
	if is_on_floor() and velocity.y > 0:
		velocity.y = 0
	else:
		velocity.y -= gravity * delta


	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	move_and_slide()

func disable_movement(state: bool):
	# keep compatible API with existing code (state=true disables movement)
	can_move = not state

func open_trade_popup(chest):
	if inventory_popup:
		inventory_popup.visible = false
	if trade_popup and trade_popup.has_method("open_trade"):
		trade_popup.open_trade(self, chest)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("npc"):
		print("npc in range:", body.name)
		body_ref = body
		if body.has_method("set_player_near"):
			body.set_player_near(self)
		set_near_npc(body)

func _on_body_exited(body: Node) -> void:
	if body == body_ref:
		print("left npc:", body.name)
		body_ref = null
		clear_near_npc()
