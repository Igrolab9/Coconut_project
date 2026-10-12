extends Node

# Массив с путями к трекам
var tracks: Array[String] = [
	"res://Sounds/Music/Island Breeze.mp3",
	"res://Sounds/Music/Island Dash.mp3",
	"res://Sounds/Music/Island Rush.mp3",
	"res://Sounds/Music/Tropic Bounce.mp3",
	"res://Sounds/Music/Tropic Rush (1).mp3",
	"res://Sounds/Music/Island Breeze.mp3"  # Добавь 6-й трек
]

var current_track_index: int = 0
var fade_time: float = 0.3

func _ready() -> void:
	# Загружаем индекс из файла (если есть)
	_load_track_index()
	# Запускаем музыку
	_play_current_track()

func _play_current_track() -> void:
	var audio_player: AudioStreamPlayer = get_node("/root/Main/AudioStreamPlayer")
	if audio_player == null:
		return
	
	# Загружаем трек
	var stream = load(tracks[current_track_index])
	if stream:
		audio_player.stream = stream
		audio_player.play()
		print("Играет трек: ", tracks[current_track_index])

func next_track() -> void:
	current_track_index = (current_track_index + 1) % tracks.size()
	_save_track_index()
	_play_current_track()

func _save_track_index() -> void:
	var file = FileAccess.open("user://track_index.txt", FileAccess.WRITE)
	if file:
		file.store_line(str(current_track_index))

func _load_track_index() -> void:
	if FileAccess.file_exists("user://track_index.txt"):
		var file = FileAccess.open("user://track_index.txt", FileAccess.READ)
		if file:
			current_track_index = file.get_line().to_int()
