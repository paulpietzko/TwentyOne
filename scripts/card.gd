extends Button

@export var angle_x_max_deg: float = 5.0
@export var angle_y_max_deg: float = 5.0
@export var max_offset_shadow: float = 50.0

@export var suit: String = "C"  # Colors: C (Clubs), D (Diamonds), H (Hearts), S (Spades)
@export var rank: String = "A"  # Ranks: 2-10, J, Q, K, A

var tween_hover: Tween
var tween_rot: Tween

@onready var card_texture: TextureRect = $CardTexture
@onready var shadow = $Shadow

func _ready() -> void:
	update_card_texture()

# Color and Rank
func update_card_texture() -> void:
	var texture_path: String = "res://assets/cards/%s-%s.png" % [suit, rank]
	card_texture.texture = load(texture_path)

func set_card(suit: String, rank: String) -> void:
	self.suit = suit
	self.rank = rank
	update_card_texture()

# Shadow
func handle_shadow(delta: float) -> void:
	var center: Vector2 = get_viewport_rect().size / 2.0
	var distance: float = global_position.x - center.x
	shadow.position.x = lerp(0.0, -sign(distance) * max_offset_shadow, abs(distance / center.x))

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		update_card_rotation(get_local_mouse_position())

# Rotation effect
func update_card_rotation(mouse_pos: Vector2) -> void:
	var lerp_val_x: float = remap(mouse_pos.x, 0.0, size.x, 0, 1)
	var lerp_val_y: float = remap(mouse_pos.y, 0.0, size.y, 0, 1)
	var rot_x: float = rad_to_deg(lerp_angle(-deg_to_rad(angle_x_max_deg), deg_to_rad(angle_x_max_deg), lerp_val_x))
	var rot_y: float = rad_to_deg(lerp_angle(deg_to_rad(angle_y_max_deg), -deg_to_rad(angle_y_max_deg), lerp_val_y))

	card_texture.material.set_shader_parameter("x_rot", rot_y)
	card_texture.material.set_shader_parameter("y_rot", rot_x)


func reset_rotation() -> void:
	if tween_rot and tween_rot.is_running():
		tween_rot.kill()
	tween_rot = create_tween().set_parallel(true)
	tween_rot.tween_property(card_texture.material, "shader_parameter/x_rot", 0.0, 0.5)
	tween_rot.tween_property(card_texture.material, "shader_parameter/y_rot", 0.0, 0.5)
	
# Hover animation
func create_hover_tween(target_scale: Vector2, duration: float) -> void:
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween()
	tween_hover.tween_property(self, "scale", target_scale, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

func _on_mouse_entered() -> void:
	create_hover_tween(Vector2(1.05, 1.05), 0.5)

func _on_mouse_exited() -> void:
	create_hover_tween(Vector2.ONE, 0.55)
	reset_rotation()

