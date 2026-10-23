extends CanvasLayer

@onready var _start_button: Button = $StartButton
const MAIN_LEVEL: String = "res://Scenes/main.tscn"

@onready var _authors_button: Button = $AuthorsButton
const AUTHOR_SCENE: String = "res://Scenes/authors_scene.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_start_button.pressed.connect(_on_start_game_pressed)
	_authors_button.pressed.connect(_on_authors_button_pressed)

func _on_start_game_pressed() -> void:
	_change_scene(MAIN_LEVEL)
	
func _on_authors_button_pressed() -> void:
	_change_scene(AUTHOR_SCENE)

func _change_scene(scene_path: String) -> void:
	if not FileAccess.file_exists(scene_path):
		push_error("MainMenu: файл сцены не найден — %s" % scene_path)
		return
	var error: int = get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("MainMenu: ошибка смены сцены, код %d" % error)
