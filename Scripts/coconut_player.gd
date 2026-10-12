# Coconut.gd
extends CharacterBody3D

@export var SPEED: float = 1.0
@export var JUMP_VELOCITY: float = 3.0
@export var SPIN_BOOST: float = 6.0

# === Настройки сообщения о смерти ===
@export_group("Message Settings")
@export var MESSAGE_TEXT: String = "Кокос разбился!"
@export var MESSAGE_FONT_SIZE: int = 64
@export var MESSAGE_COLOR: Color = Color.RED
@export var MESSAGE_BG_COLOR: Color = Color(0, 0, 0, 0.7)  # полупрозрачный чёрный
@export var MESSAGE_DELAY: float = 3.0
# =====================================

@onready var coconut_mesh: MeshInstance3D = $RollPivot/Coconut224Tris
@onready var roll_pivot: Node3D = $RollPivot
@onready var message_label: Label = $CanvasLayer/MessageLabel

# Компоненты
var _movement: CoconutMovement
var _roller: CoconutRoller
var _health: CoconutHealth
var _collision_handler: CoconutCollisionHandler

func _ready() -> void:
	# Инициализация логики
	_health = CoconutHealth.new()
	_health.broken.connect(_on_broken)
	
	_movement = CoconutMovement.new(self)
	_movement.speed = SPEED
	_movement.jump_velocity = JUMP_VELOCITY
	
	_roller = CoconutRoller.new(roll_pivot, coconut_mesh)
	_roller.spin_boost = SPIN_BOOST
	
	_collision_handler = CoconutCollisionHandler.new(self, _health)
	
	# Настраиваем сообщение
	_apply_message_style()

func _apply_message_style() -> void:
	message_label.visible = false
	message_label.text = MESSAGE_TEXT
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Размер шрифта (Godot 4 — через theme override)
	message_label.add_theme_font_size_override("font_size", MESSAGE_FONT_SIZE)
	
	# Цвет текста
	message_label.add_theme_color_override("font_color", MESSAGE_COLOR)
	
	# Цвет фона (если нужен) — через StyleBox
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = MESSAGE_BG_COLOR
	style_box.corner_radius_top_left = 10
	style_box.corner_radius_top_right = 10
	style_box.corner_radius_bottom_left = 10
	style_box.corner_radius_bottom_right = 10
	style_box.content_margin_left = 40
	style_box.content_margin_right = 40
	style_box.content_margin_top = 20
	style_box.content_margin_bottom = 20
	message_label.add_theme_stylebox_override("normal", style_box)

func _physics_process(delta: float) -> void:
	if _health.is_broken():
		return

	# Делегируем задачи
	_movement.update(delta)
	_roller.update(velocity, delta)
	_collision_handler.check_collisions()

func _on_broken() -> void:
	# Показываем сообщение
	message_label.visible = true
	
	# Ставим игру на паузу
	get_tree().paused = true
	
	# Таймер тикает даже во время паузы
	await get_tree().create_timer(MESSAGE_DELAY, true).timeout
	
	print("Кокос разбился!")
	
	# Переключаем трек ПЕРЕД перезапуском
	MusicManager.next_track()
	
	# Снимаем паузу и перезагружаем сцену
	get_tree().paused = false
	get_tree().call_deferred("reload_current_scene")
